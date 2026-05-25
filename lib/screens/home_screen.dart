import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:geocoding/geocoding.dart' as geocode;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nia_project/auth_service.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/device_service.dart';
import 'package:nia_project/main.dart';
import 'package:nia_project/screens/full_image_viewer.dart';

import 'package:nia_project/time_persistence_service.dart';
import 'package:nia_project/time_security_service.dart';
import 'package:nia_project/url_of_db.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.authService, required this.db});
  final AuthService authService;
  final AppDatabase db;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  geocode.Placemark? place;
  final api_url = UrlOfDb.dbUrl;

  // GPS state
  String _gpsStatus = 'Searching...';
  double? _currentLat;
  double? _currentLong;
  Color _gpsColor = Colors.orange;

  late String _timeStr;
  Timer? _timer;

  bool _isSyncing = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initGps();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runReconcileIfOnline();
      await _syncNow();
    });
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      _timeStr = DateFormat('hh:mm a').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel(); // Always cancel to avoid memory leaks
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_isCapturing) return;
    if (state == AppLifecycleState.resumed) {
      await TimeSecurityService.performSecureSave(db: widget.db);
      await _runReconcileIfOnline();
      if (!_isSyncing) await _syncNow();
    }
  }

  String toDMS(double decimal, bool isLatitude) {
    final direction =
        isLatitude ? (decimal >= 0 ? 'N' : 'S') : (decimal >= 0 ? 'E' : 'W');

    final abs = decimal.abs();
    final degrees = abs.truncate();
    final minutesDecimal = (abs - degrees) * 60;
    final minutes = minutesDecimal.truncate();
    final seconds = (minutesDecimal - minutes) * 60;

    return '$degrees° ${minutes}\' ${seconds.toStringAsFixed(2)}" $direction';
  }

  Future<void> _initGps() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsStatus = 'Denied';
          _gpsColor = Colors.red;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _geoCode(position.latitude, position.longitude);
      setState(() {
        _currentLat = position.latitude;
        _currentLong = position.longitude;
        _gpsStatus = 'Locked';
        _gpsColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _gpsStatus = 'Error';
        _gpsColor = Colors.red;
      });
    }
  }

  void scheduleSync() {
    Workmanager().registerOneOffTask(
      "sync-task-id",
      "syncData",
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> _runReconcileIfOnline() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;
    await _reconcileDatabase();
  }

  Future<void> _reconcileDatabase() async {
    try {
      final currentUser =
          await widget.db.select(widget.db.users).getSingleOrNull();
      if (currentUser == null) return;
      final String currentEmployeeId = currentUser.employeeId;

      const storage = FlutterSecureStorage();
      final String? token = await storage.read(key: 'jwt_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${api_url}/verify-sync'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) return;

      final List<String> serverKeys = List<String>.from(
        (response.body.isNotEmpty
                ? _decodeJson(response.body)
                : {})['synced_keys'] ??
            [],
      );

      final DateFormat syncFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final localSyncedRecords =
          await (widget.db.select(widget.db.capturedImages)
            ..where((t) => t.isSynced.equals(true))).get();

      for (var record in localSyncedRecords) {
        String formattedDate = syncFormatter.format(record.deviceTimestamp);
        String localKey = "${currentEmployeeId}_${formattedDate}";
        if (!serverKeys.contains(localKey)) {
          await (widget.db.update(widget.db.capturedImages)..where(
            (t) => t.id.equals(record.id),
          )).write(const CapturedImagesCompanion(isSynced: Value(false)));
        }
      }
      scheduleSync();
    } catch (e) {
      print("Reconciliation failed: $e");
    }
  }

  dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveToDrift(XFile photo, Position pos) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(photo.path);
    final permanentFile = await File(
      photo.path,
    ).copy('${appDir.path}/$fileName');
    final deviceId = await DeviceService.getDeviceId();
    final currentUser =
        await widget.db.select(widget.db.users).getSingleOrNull();

    DateTime deviceNow = DateTime.now();
    DateTime lastActivity = await TimePersistenceService.getLastRecordedTime();

    if (currentUser != null) {
      final String empId = currentUser.employeeId;
      String shortPlace =
          place == null
              ? "No place found"
              : "${place!.street}, ${place!.locality}";

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
      // setState(() {
      //   scheduleSync(); // just remove or only schedule when offline
      // });
    }
    print("Saved successfully!");
  }

  Future<void> _takePhoto() async {
    _isCapturing = true;
    try {
      await TimeSecurityService.performSecureSave(db: widget.db);
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (photo != null) {
        await _geoCode(position.latitude, position.longitude);
        await saveToDrift(photo, position);
        await _syncNow();
      }
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    print('🔄 _syncNow() started');
    try {
      await syncDataToRemote(widget.db);
    } catch (e) {
      print('Sync failed: $e');
    } finally {
      _isSyncing = false;
      print('🔄 _syncNow() finished');
    }
  }

  Future<void> _geoCode(double latitude, double longitude) async {
    try {
      final places = await geocode.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      setState(() {
        place = places.first;
      });
    } catch (e) {
      return;
    }
  }

  Widget _buildInfoCard({required String label, required Widget child}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMM dd, yyyy').format(now);

    final latStr =
        _currentLat != null
            ? '${toDMS(_currentLat!, true)}, ${toDMS(_currentLong!, false)}'
            : '--';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: StreamBuilder<List<CapturedImage>>(
          stream: widget.db.select(widget.db.capturedImages).watch(),
          builder: (context, snapshot) {
            final images = snapshot.data ?? [];
            images.sort(
              (a, b) => b.deviceTimestamp.compareTo(a.deviceTimestamp),
            );
            final lastEntry = images.isNotEmpty ? images.first : null;

            return Column(
              children: [
                // ---------- APP BAR ----------
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/pulse-logo-wo-name.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PULSE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            "Personnel's Updated Location & Site Evidence",
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.green),
                                      SizedBox(width: 10),
                                      Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: const Text(
                                    "Are you sure you want to exit PULSE?",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  actionsPadding: const EdgeInsets.only(
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                        widget.authService.logout(widget.db);
                                      },
                                      child: const Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: const Icon(Icons.logout_outlined, size: 22),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- INFO CARDS ROW ----------
                        Row(
                          children: [
                            _buildInfoCard(
                              label: 'CURRENT TIME',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _timeStr,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildInfoCard(
                              label: 'GPS STATUS',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _gpsColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _gpsStatus,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    latStr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ---------- CAMERA CAPTURE AREA ----------
                        GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            width: double.infinity,
                            height: 320,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B7B8D),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                // Corner brackets
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: _buildCornerBracket(
                                    isTop: true,
                                    isLeft: true,
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: _buildCornerBracket(
                                    isTop: true,
                                    isLeft: false,
                                  ),
                                ),
                                Positioned(
                                  bottom: 50,
                                  left: 16,
                                  child: _buildCornerBracket(
                                    isTop: false,
                                    isLeft: true,
                                  ),
                                ),
                                Positioned(
                                  bottom: 50,
                                  right: 16,
                                  child: _buildCornerBracket(
                                    isTop: false,
                                    isLeft: false,
                                  ),
                                ),

                                // Location badge
                                Positioned(
                                  top: 20,
                                  left: 24,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'VERIFIED SITE',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey.shade500,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            Text(
                                              place != null
                                                  ? ((place!.subLocality !=
                                                              null &&
                                                          place!.subLocality!
                                                              .trim()
                                                              .isNotEmpty)
                                                      ? place!.subLocality!
                                                      : (place!.locality !=
                                                              null &&
                                                          place!.locality!
                                                              .trim()
                                                              .isNotEmpty)
                                                      ? place!.locality!
                                                      : 'Current Location')
                                                  : 'Current Location',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Camera icon circle
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 32,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Bottom label
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Take a Picture',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ---------- LAST PULSE ENTRY ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Last PULSE Entry',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        if (lastEntry == null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'No entries yet. Tap the camera to capture!',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullImageViewer(
                                        imagePath:
                                            lastEntry.imagePath.startsWith(
                                                  'http',
                                                )
                                                ? lastEntry.imagePath
                                                : File(lastEntry.imagePath),
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Green left bar
                                  Container(
                                    width: 4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          lastEntry.isSynced
                                              ? Colors.green
                                              : Colors.orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImageThumbnail(
                                      lastEntry,
                                      size: 50,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PULSE Check-in Complete',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${DateFormat.jm().format(lastEntry.deviceTimestamp)} • ${lastEntry.place.replaceAll('\n', '').split(',').first.trim()}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ✅ Sync status badge (streamed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          lastEntry.isSynced
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          lastEntry.isSynced
                                              ? Icons.cloud_done_outlined
                                              : Icons.cloud_upload_outlined,
                                          size: 12,
                                          color:
                                              lastEntry.isSynced
                                                  ? Colors.green
                                                  : Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          lastEntry.isSynced
                                              ? 'SYNCED'
                                              : 'PENDING',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                lastEntry.isSynced
                                                    ? Colors.green
                                                    : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCornerBracket({required bool isTop, required bool isLeft}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _CornerPainter(isTop: isTop, isLeft: isLeft)),
    );
  }
}

Widget _buildImageThumbnail(CapturedImage item, {double size = 50}) {
  return item.imagePath.startsWith("http")
      ? CachedNetworkImage(
        imageUrl: item.imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => SizedBox(
              child: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        errorWidget:
            (context, url, error) =>
                Icon(Icons.broken_image, size: 40, color: Colors.grey),
        httpHeaders: const {},
      )
      : _LocalImageWidget(path: item.imagePath, size: size);
}

class _LocalImageWidget extends StatefulWidget {
  final String path;
  final double size;
  const _LocalImageWidget({required this.path, required this.size});

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
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
          );
        }
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
