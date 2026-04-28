import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nia_project/auth_service.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/device_service.dart';
import 'package:nia_project/heartbeat_service.dart';
import 'package:nia_project/screens/full_image_viewer.dart';
import 'package:nia_project/screens/map_screen.dart';
import 'package:nia_project/time_persistence_service.dart';
import 'package:nia_project/time_security_service.dart';
import 'package:nia_project/url_of_db.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class MainScreen extends StatefulWidget {
  MainScreen({
    super.key,
    required this.authService,
    required this.cameras,
    required this.db,
  });
  final AuthService authService;
  final cameras;
  final AppDatabase db;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // To store the captured photo
  final ImagePicker _picker = ImagePicker();
  geocode.Placemark? place;
  WebSettings wsetting = WebSettings();
  final api_url = UrlOfDb.dbUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed) {
      await TimeSecurityService.performSecureSave(db: widget.db);
    }
  }

  void scheduleSync() {
    Workmanager().registerOneOffTask(
      "sync-task-id",
      "syncData",
      constraints: Constraints(
        networkType:
            NetworkType.connected, // The magic line: only runs when online
      ),
    );
  }

  Future<void> reconcileDatabase(String currentEmployeeId) async {
    try {
      const storage = FlutterSecureStorage();
      final String? token = await storage.read(key: 'jwt_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${api_url}/verify-sync'),
        headers: {'Authorization': 'Bearer $token'}, // ← add header
      );

      if (response.statusCode != 200) return;

      final List<String> serverKeys = List<String>.from(
        jsonDecode(response.body)['synced_keys'],
      );

      final DateFormat syncFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

      final localSyncedRecords =
          await (widget.db.select(widget.db.capturedImages)
            ..where((t) => t.isSynced.equals(true))).get();

      for (var record in localSyncedRecords) {
        String formattedDate = syncFormatter.format(record.deviceTimestamp);

        // Build the matching key: "EMP123_2026-02-25T09:47:00"
        // Note: Ensure the timestamp format matches your Python isoformat()
        String localKey = "${currentEmployeeId}_${formattedDate}";

        if (!serverKeys.contains(localKey)) {
          await (widget.db.update(widget.db.capturedImages)..where(
            (t) => t.id.equals(record.id),
          )).write(const CapturedImagesCompanion(isSynced: Value(false)));

          print(
            "Record ${record.id} missing on server. Resetting isSynced to false.",
          );
        }
      }

      scheduleSync();
    } catch (e) {
      print("Reconciliation failed: $e");
    }
  }

  Future<void> saveToDrift(XFile photo, Position pos) async {
    // 1. Move image to permanent storage
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(photo.path);
    final permanentFile = await File(
      photo.path,
    ).copy('${appDir.path}/$fileName');
    final deviceId = await DeviceService.getDeviceId();
    final currentUser =
        await widget.db.select(widget.db.users).getSingleOrNull();

    // 1. Get the time the user is CLAIMING it is right now
    DateTime deviceNow = DateTime.now();

    // 2. Get the last time we recorded them being active
    DateTime lastActivity = await TimePersistenceService.getLastRecordedTime();

    print(deviceNow);
    print(lastActivity);

    final anchors = await widget.db.select(widget.db.timeAnchors).get();
    print(anchors[anchors.length - 1].lastTick);

    if (currentUser != null) {
      final String empId = currentUser.employeeId;

      String shortPlace =
          place == null
              ? "No place found"
              : "name: ${place!.name}\nstreet: ${place!.street}\nlocality: ${place!.locality}\nSAA: ${place!.subAdministrativeArea}\npcode: ${place!.postalCode}";
      //change the "deviceTimestamp" and "geoTimestamp" values into deviceNow and lastActivity
      // 2. Insert into Drift
      await widget.db
          .into(widget.db.capturedImages)
          .insertOnConflictUpdate(
            CapturedImagesCompanion.insert(
              imagePath: permanentFile.path,
              deviceTimestamp: deviceNow,
              lastActivity: lastActivity,
              timeOffset: deviceNow.difference(lastActivity),
              latitude: pos.latitude,
              longitude: pos.longitude,
              place: shortPlace,
              employeeId: empId,
              deviceId: Value(deviceId),
            ),
          );
      setState(() {
        scheduleSync();
      });
    }

    print("Saved successfully!");
  }

  Future<void> _takePhoto() async {
    await TimeSecurityService.performSecureSave(db: widget.db);
    // 1. Check/Request Location Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // This line opens the camera directly
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (photo != null) {
      await geoCode(position.latitude, position.longitude);
      // await saveToGallery(photo.path);

      await saveToDrift(photo, position);
    }
  }

  Future<void> saveToGallery(String path) async {
    // Check/Request permission
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) await Gal.requestAccess();

    // Save the image to the actual phone gallery
    await Gal.putImage(path);
    print("Saved to Gallery!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NIA"),
        actions: [
          IconButton(
            onPressed: () async {
              final currentUser =
                  await widget.db.select(widget.db.users).getSingleOrNull();

              if (currentUser != null) {
                final String empId = currentUser.employeeId;

                await reconcileDatabase(empId);
              }
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return MapScreen(db: widget.db);
                  },
                ),
              );
            },
            icon: Icon(Icons.public),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to exit?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            widget.authService.logout(widget.db);
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CapturedImage>>(
              stream: widget.db.select(widget.db.capturedImages).watch(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rawImages = snapshot.data!;

                // Sort so newest dates appear at the top
                rawImages.sort(
                  (a, b) => b.deviceTimestamp.compareTo(a.deviceTimestamp),
                );

                final groups = groupImagesByDate(rawImages);
                final dateKeys = groups.keys.toList();

                return ListView.builder(
                  itemCount: dateKeys.length,
                  itemBuilder: (context, index) {
                    final dateLabel = dateKeys[index];
                    final imagesForDay = groups[dateLabel]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- STICKY-STYLE DATE HEADER ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color:
                              Colors
                                  .grey[200], // Slight background to distinguish the day
                          child: Text(
                            dateLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // --- IMAGES FOR THIS DATE ---
                        ...imagesForDay.map((item) {
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child:
                                  item.imagePath.startsWith("http")
                                      ? CachedNetworkImage(
                                        imageUrl: item.imagePath,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.fill,
                                        placeholder:
                                            (context, url) => SizedBox(
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.green,
                                                    ),
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) => Icon(
                                              Icons.broken_image,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                        httpHeaders: const {},
                                      )
                                      : _LocalImageWidget(path: item.imagePath),
                            ),
                            title: Text(
                              "Time: ${DateFormat.jm().format(item.deviceTimestamp)}",
                            ), // e.g. 1:45 PM
                            trailing: Text(
                              "${item.employeeId}",
                              style: const TextStyle(fontSize: 10),
                            ),
                            onTap: () {
                              viewActions(context, item);
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder:
                              //         (_) => FullImageViewer(
                              //           imagePath: File(item.imagePath),
                              //         ),
                              //   ),
                              // );
                            },
                          );
                        }).toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green.shade200,
            foregroundColor: Colors.grey.shade100,
            onPressed: () async {
              // await widget.db.delete(widget.db.timeAnchors).go();

              // await widget.heartbeat.debugTick();

              // final anchors =
              //     await widget.db.select(widget.db.timeAnchors).get();
              // print(anchors.length);

              // print(anchors[anchors.length - 1].lastTick);
              await TimeSecurityService.performSecureSave(db: widget.db);

              final deviceId = await DeviceService.getDeviceId();

              _takePhoto();
            },

            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  Future<dynamic> viewActions(BuildContext context, CapturedImage item) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("View Image"),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => FullImageViewer(
                            imagePath:
                                item.imagePath.startsWith("http")
                                    ? item.imagePath
                                    : File(item.imagePath),
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text("View Location"),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => MapScreen(
                            db: widget.db,
                            item_lat: item.latitude,
                            item_long: item.longitude,
                            item_date: item.deviceTimestamp,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<CapturedImage>> groupImagesByDate(
    List<CapturedImage> images,
  ) {
    final Map<String, List<CapturedImage>> groups = {};

    for (var image in images) {
      // Format the DateTime into a human-readable String for the header
      final String dateKey = DateFormat.yMMMMd().format(image.deviceTimestamp);

      if (groups[dateKey] == null) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(image);
    }
    return groups;
  }

  Future<void> geoCode(double latitude, double longitude) async {
    //Geocode
    var places;
    try {
      places = await geocode.placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      return;
    }
    place = places.first;
    setState(() {});
    // print(places);
  }
}

/// Safely loads a local file image, showing a fallback if file doesn't exist.
class _LocalImageWidget extends StatefulWidget {
  final String path;
  const _LocalImageWidget({required this.path});

  @override
  State<_LocalImageWidget> createState() => _LocalImageWidgetState();
}

class _LocalImageWidgetState extends State<_LocalImageWidget> {
  late Future<bool> _fileExists;

  @override
  void initState() {
    super.initState();
    _fileExists = File(widget.path).exists();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _fileExists,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.file(
            File(widget.path),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            // Catch any remaining decode errors
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
          );
        }
        // File doesn't exist — show placeholder instead of crashing
        return const SizedBox(
          width: 50,
          height: 50,
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }
}
