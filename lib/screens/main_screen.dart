import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nia_project/auth_service.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/screens/full_image_viewer.dart';
import 'package:nia_project/screens/map_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:workmanager/workmanager.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key, required this.authService, required this.cameras});
  final AuthService authService;
  final cameras;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _image;
  String _metadata = "No data captured yet";
  // To store the captured photo
  final ImagePicker _picker = ImagePicker();
  final database = AppDatabase();
  geocode.Placemark? place;
  WebSettings wsetting = WebSettings();

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

  Future<void> reconcileDatabase() async {
    try {
      // 1. Get the list of IDs actually in MySQL
      final response = await http.get(
        Uri.parse('http://192.168.1.32:8000/verify-ids'),
      );
      if (response.statusCode != 200) return;

      final List<int> serverIds = List<int>.from(
        jsonDecode(response.body)['synced_ids'],
      );

      // 2. Fetch all local records that THINK they are synced
      final localSyncedRecords =
          await (database.select(database.capturedImages)
            ..where((t) => t.isSynced.equals(true))).get();

      for (var record in localSyncedRecords) {
        // 3. If the server doesn't have it, mark it as NOT synced
        if (!serverIds.contains(record.id)) {
          await (database.update(database.capturedImages)..where(
            (t) => t.id.equals(record.id),
          )).write(CapturedImagesCompanion(isSynced: Value(false)));

          print("Record ${record.id} was out of sync. Resetting to false.");
        }
      }

      // 4. Trigger sync to fix the missing items
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
    String shortPlace =
        place == null
            ? "No place found"
            : "name: ${place!.name}\nstreet: ${place!.street}\nlocality: ${place!.locality}\nSAA: ${place!.subAdministrativeArea}\npcode: ${place!.postalCode}";

    // 2. Insert into Drift
    await database
        .into(database.capturedImages)
        .insert(
          CapturedImagesCompanion.insert(
            imagePath: permanentFile.path,
            deviceTimestamp: DateTime.now(),
            geoTimestamp: pos.timestamp.toLocal(),
            timeOffset: DateTime.now().difference(pos.timestamp.toLocal()),
            latitude: pos.latitude,
            longitude: pos.longitude,
            place: shortPlace,
          ),
        );
    setState(() {
      scheduleSync();
    });
    print("Saved successfully!");
  }

  Future<void> _takePhoto() async {
    // 1. Check/Request Location Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // This line opens the camera directly
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      String timestamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _image = File(photo.path);
        _metadata =
            "Time: $timestamp\nLat: ${position.latitude}, Long: ${position.longitude}";
      });
      await geoCode(position.latitude, position.longitude);
      // await saveToGallery(photo.path);

      // print("Current time of the geolocator: ${position.timestamp}");
      // print("Current time of the geolocator + 8 hours: ${position.timestamp.add(Duration(hours: 8))}",);
      // print("Current local time of geolocator: ${position.timestamp.toLocal()}",);
      // print("Current time of the device: ${DateTime.now()}");
      // print("Difference of dt.now and geolocator: ${DateTime.now().difference(position.timestamp.toLocal())}",);
      // print("Is equal? ${position.timestamp.add(Duration(hours: 8)) == DateTime.now()}",);
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
              await reconcileDatabase();
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return MapScreen();
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
                            widget.authService.logout();
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
              stream: database.select(database.capturedImages).watch(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

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
                              child: Image.file(
                                File(item.imagePath),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              "Time: ${DateFormat.jm().format(item.deviceTimestamp)}",
                            ), // e.g. 1:45 PM
                            trailing: CircleAvatar(
                              radius: 12,
                              child: Text(
                                "${item.id}",
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullImageViewer(
                                        imagePath: File(item.imagePath),
                                      ),
                                ),
                              );
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
            onPressed: _takePhoto,
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not find address")));
      return;
    }
    place = places.first;
    setState(() {});
    // print(places);
  }
}
