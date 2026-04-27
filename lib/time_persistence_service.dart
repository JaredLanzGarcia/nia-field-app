import 'package:flutter_kronos/flutter_kronos.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TimePersistenceService {
  static const String _timeKey = 'last_known_activity_time';
  static const _storage = FlutterSecureStorage();

  /// Saves the current "Reliable" time to disk.
  /// Call this whenever the user does something important (e.g., finishing a level, saving a record).
  static Future<void> saveCurrentActivityTime() async {
    // Use Kronos (NTP-anchored) time if available, fallback to system time
    final int? kronosTime = await FlutterKronos.getCurrentTimeMs;

    // Use the reliable time if available, otherwise fallback to system time
    // (But remember: system time is what we are verifying against later!)
    final DateTime now =
        kronosTime != null
            ? DateTime.fromMillisecondsSinceEpoch(kronosTime)
            : DateTime.now();

    await _storage.write(
      key: _timeKey,
      value: now.millisecondsSinceEpoch.toString(),
    );
  }

  /// Retrieves the last saved time from the disk.
  static Future<DateTime> getLastRecordedTime() async {
    final String? savedMs = await _storage.read(key: _timeKey);

    if (savedMs == null) {
      return DateTime(2000);
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(savedMs));
  }
}
