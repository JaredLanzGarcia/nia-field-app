import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/heartbeat_service.dart';
import 'package:nia_project/screens/(unused)camera_screen.dart';
import 'package:nia_project/screens/main_screen.dart';
import 'package:nia_project/screens/map_screen.dart';
import 'package:nia_project/screens/register_screen.dart';
import 'package:nia_project/screens/splash_screen.dart';
import 'package:nia_project/time_persistence_service.dart';
import 'package:nia_project/time_security_service.dart';
import 'package:nia_project/url_of_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http_parser/http_parser.dart'; // for MediaType

import 'auth_service.dart';

// This must be a top-level function (outside any class)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // 1. Initialize your database inside the background process
    final database = AppDatabase();

    // 2. Reuse the sync logic we built
    // (Ensure you have a check for internet inside syncDataToRemote)
    await syncDataToRemote(database);

    return Future.value(true);
  });
}

Future<void> syncDataToRemote(AppDatabase database) async {
  // 1. Check Internet
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult.contains(ConnectivityResult.none)) return;

  const storage = FlutterSecureStorage();
  final String? token = await storage.read(key: 'jwt_token');
  if (token == null) {
    print("Sync skipped — no auth token found");
    return;
  }

  // 2. Fetch unsynced records from Drift
  final unsynced =
      await (database.select(database.capturedImages)
        ..where((t) => t.isSynced.equals(false))).get();

  for (var record in unsynced) {
    try {
      // 3. Upload to your API
      final api_url = UrlOfDb.dbUrl;
      var request = http.MultipartRequest('POST', Uri.parse('${api_url}/sync'));

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['timestamp'] = record.deviceTimestamp.toIso8601String();
      request.fields['last_activity'] =
          record.lastActivity
              .toIso8601String(); //request.fields['last_activity']
      request.fields['time_offset'] = record.timeOffset.toString();
      request.fields['latitude'] = record.latitude.toString();
      request.fields['longitude'] = record.longitude.toString();
      request.fields['place'] = record.place.toString();
      request.fields['device_id'] = record.deviceId;
      request.fields['status'] = record.status;

      final imageFile = File(record.imagePath);
      final mimeType = lookupMimeType(record.imagePath) ?? 'image/jpeg';
      final ext = extensionFromMime(mimeType); // gets jpg or png

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          record.imagePath,
          contentType: http.MediaType.parse(
            mimeType,
          ), // ← explicitly set MIME type
          filename: 'photo.$ext', // ← force clean filename
        ),
      );
      request.fields['employee_id'] = record.employeeId.toString();

      var response = await request.send();
      final responseBody = await response.stream.bytesToString(); // ← add this
      print(
        "Sync response ${response.statusCode}: $responseBody",
      ); // ← add this

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);

        await (database.update(database.capturedImages)
          ..where((t) => t.id.equals(record.id))).write(
          CapturedImagesCompanion(
            isSynced: const Value(true),
            // If your server returns the Cloudinary URL, store it:
            imagePath: Value(responseJson['image_url'] ?? record.imagePath),
          ),
        );
      }
    } catch (e) {
      print("Sync failed for record ${record.id}: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final cameras = await availableCameras();
  final db = AppDatabase();

  final rebooted = await TimeSecurityService.hasDeviceRebooted();
  if (rebooted) {
    final authService = AuthService();
    await authService.logout(db);
  }

  final heartbeat = HeartbeatService(
    db,
  ); // Stopwatch starts here on first reference
  heartbeat.start(); // ← begins the 30-second periodic check

  Workmanager().initialize(callbackDispatcher);
  runApp(MyApp(cameras: cameras, db: db));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.cameras, required this.db});
  final cameras;
  final AppDatabase db;

  // Colors
  // FF5B5B red
  // F0FFC3 cream
  // 9CCFFF light blue
  // 685AFF blue
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    authService.checkStatus();

    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: StreamBuilder<bool>(
        stream: authService.authStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          if (snapshot.data == true) {
            return MainScreen(
              authService: authService,
              cameras: cameras,
              db: db,
            );
          }
          return LoginScreen(
            onLoginSuccess: (token, history) {
              authService.login(token, history, db);
            },
            db: db,
            authService: authService,
          );
        },
      ),
      debugShowCheckedModeBanner: false,
      title: "NIA App",
    );
  }
}
