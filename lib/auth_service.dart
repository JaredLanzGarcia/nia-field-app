import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nia_project/database.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // The Controller that broadcasts the session status
  final _authController = StreamController<bool>();

  // Expose the stream to the UI
  Stream<bool> get authStatus => _authController.stream;

  // Check initial state (call this when app starts)
  Future<void> checkStatus() async {
    String? token = await _storage.read(key: 'jwt_token');
    _authController.add(token != null);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> login(
    String token,
    List<dynamic> history,
    AppDatabase db,
  ) async {
    await _storage.write(key: 'jwt_token', value: token);

    for (var item in history) {
      await db
          .into(db.capturedImages)
          .insert(
            CapturedImagesCompanion.insert(
              // Note: You'll need to download the image or store the URL
              imagePath: item['image_path'],
              deviceTimestamp: DateTime.parse(item['timestamp']),
              lastActivity: DateTime.parse(item['last_activity']),
              timeOffset: parseDartDuration(item['time_offset']),
              latitude: item['latitude'],
              longitude: item['longitude'],
              place: item['place'],
              employeeId: item['employee_id'].toString(),
              isSynced: const Value(true), // It's already online!
            ),
          );
    }

    _authController.add(true); // Notify StreamBuilder

    
  }

  // Inside your AuthService class
  Future<void> logout(AppDatabase database) async {
    try {
      await database.clearUserData();
      print("Local database cleared.");

      // 1. Delete the token from secure storage
      await _storage.delete(key: 'jwt_token');

      // 2. Push 'false' to the stream so the UI reacts
      _authController.add(false);
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  Duration parseDartDuration(String input) {
    final isNegative = input.startsWith('-');
    // Remove the minus sign for parsing
    final absoluteInput = isNegative ? input.substring(1) : input;

    // Split into [hours, minutes, seconds.microseconds]
    final parts = absoluteInput.split(':');
    if (parts.length != 3) return Duration.zero;

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    // Split the seconds and microseconds (e.0. "00.994644")
    final secondsParts = parts[2].split('.');
    final seconds = int.parse(secondsParts[0]);
    int microseconds = 0;

    if (secondsParts.length > 1) {
      // Pad to 6 digits to ensure correct microsecond value
      String microStr = secondsParts[1].padRight(6, '0').substring(0, 6);
      microseconds = int.parse(microStr);
    }

    final duration = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      microseconds: microseconds,
    );

    return isNegative ? -duration : duration;
  }
}
