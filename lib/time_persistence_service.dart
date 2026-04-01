
import 'package:shared_preferences/shared_preferences.dart';

class TimePersistenceService {
  static const String _timeKey = 'last_known_activity_time';

  /// Saves the current "Reliable" time to disk. 
  /// Call this whenever the user does something important (e.g., finishing a level, saving a record).
  static Future<void> saveCurrentActivityTime() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Use the reliable time if available, otherwise fallback to system time
    // (But remember: system time is what we are verifying against later!)
    DateTime now = DateTime.now(); 
    await prefs.setInt(_timeKey, now.millisecondsSinceEpoch);
  }

  /// Retrieves the last saved time from the disk.
  static Future<DateTime> getLastRecordedTime() async {
    final prefs = await SharedPreferences.getInstance();
    int? savedMs = prefs.getInt(_timeKey);
    
    if (savedMs == null) {
      // If first time ever running the app, use current time
      return DateTime.now();
    }
    return DateTime.fromMillisecondsSinceEpoch(savedMs);
  }
}