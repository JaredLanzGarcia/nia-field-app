import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/screens/(unused)camera_screen.dart';
import 'package:nia_project/screens/main_screen.dart';
import 'package:nia_project/screens/map_screen.dart';
import 'package:nia_project/screens/splash_screen.dart';
import 'package:nia_project/time_persistence_service.dart';
import 'screens/login_screen.dart';
import 'package:workmanager/workmanager.dart';

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

  // 2. Fetch unsynced records from Drift
  final unsynced =
      await (database.select(database.capturedImages)
        ..where((t) => t.isSynced.equals(false))).get();

  for (var record in unsynced) {
    try {
      // 3. Upload to your API
      final api_url = "http://192.168.1.70:8000";
      var request = http.MultipartRequest('POST', Uri.parse('${api_url}/sync'));

      request.fields['timestamp'] = record.deviceTimestamp.toIso8601String();
      request.fields['last_activity'] =
          record.lastActivity
              .toIso8601String(); //request.fields['last_activity']
      request.fields['time_offset'] = record.timeOffset.toString();
      request.fields['latitude'] = record.latitude.toString();
      request.fields['longitude'] = record.longitude.toString();
      request.fields['place'] = record.place.toString();
      request.files.add(
        await http.MultipartFile.fromPath('image', record.imagePath),
      );
      request.fields['employee_id'] = record.employeeId.toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        // 4. Update local Drift record as synced
        await (database.update(database.capturedImages)..where(
          (t) => t.id.equals(record.id),
        )).write(CapturedImagesCompanion(isSynced: Value(true)));
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
  Workmanager().initialize(callbackDispatcher);
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.cameras});
  final cameras;

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
            return MainScreen(authService: authService, cameras: cameras);
          }
          return LoginScreen(
            onLoginSuccess: (token, history) {
              final database = AppDatabase();
              authService.login(token, history, database);
            },
          );
        },
      ),
      debugShowCheckedModeBanner: false,
      title: "NIA App",
    );
  }
}
