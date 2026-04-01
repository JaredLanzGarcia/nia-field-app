import 'package:flutter_kronos/flutter_kronos.dart';
import 'package:nia_project/time_persistence_service.dart';

class TimeSecurityService {
  /// Syncs with a trusted NTP server. Run this at least once when online.
  static Future<void> syncTrustedTime() async {
    // This fetches time from NTP pools and stores the delta against system uptime
    await FlutterKronos.sync;
  }

  /// Gets the reliable time, even if the user changed the system clock.
  /// Returns null if a sync has never occurred since the last reboot.
  static Future<DateTime?> getReliableTime() async {
    final int? kronosTime = await FlutterKronos.getCurrentTimeMs;
    if (kronosTime != null) {
      return DateTime.fromMillisecondsSinceEpoch(kronosTime);
    }
    return null;
  }

  /// Checks if the user's device clock is tampered.
  static Future<bool> isTimeTampered({int thresholdMinutes = 5}) async {
    DateTime? realTime = await getReliableTime();
    if (realTime == null) return false; // Cannot verify without a sync

    DateTime deviceTime = DateTime.now();
    Duration difference = deviceTime.difference(realTime).abs();

    return difference.inMinutes > thresholdMinutes;
  }

  static Future<void> performSecureSave() async {
    // 1. Check if hardware uptime matches the clock (Anti-Forward-Jump)
    bool isDrifting = await isTimeTampered(); 
    
    // 2. Check if current time is before last saved time (Anti-Backward-Jump)
    DateTime now = DateTime.now();
    DateTime last = await TimePersistenceService.getLastRecordedTime();
    
    if (!isDrifting && now.isAfter(last)) {
      // ONLY save if both hardware and history validate the current time
      await TimePersistenceService.saveCurrentActivityTime();
      print("✅ Securely anchored time at: $now");
    } else {
      print("❌ Refusing to save suspicious time.");
      // Trigger your "Lock" or "Warning" UI here
    }
  }
}