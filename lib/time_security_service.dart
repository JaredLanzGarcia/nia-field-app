import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kronos/flutter_kronos.dart';
import 'package:nia_project/auth_service.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/time_persistence_service.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeSecurityService {
  static const _channel = MethodChannel('app/monotonic_clock');

  static Future<int> getUptimeSeconds() async {
    final ms = await _channel.invokeMethod<int>('getUptimeMillis') ?? 0;
    return ms ~/ 1000;
  }

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
  /// Online: compares device time against NTP.
  /// Offline: falls back to heartbeat anchor comparison using native uptime.
  static Future<bool> isTimeTampered({
    required AppDatabase db,
    int thresholdMinutes = 1,
  }) async {
    try {
      // Get the exact time from Google's NTP server
      DateTime networkTime = await NTP.now();
      DateTime deviceTime = DateTime.now();

      // If the difference is more than 1 minute, the user is messing with the clock
      if (deviceTime.difference(networkTime).abs().inMinutes >
          thresholdMinutes) {
        print("🚨 NTP: Device time differs from network time.");
        return true;
      }
      await _updateAnchor(db: db, wallTime: networkTime);
      return false;
    } catch (e) {
      // If offline, we can't verify via NTP. Fallback to Heartbeat logic.
      return await _isTimeTamperedOffline(
        db: db,
        thresholdMinutes: thresholdMinutes,
      );
    }
  }

  /// Offline tamper detection using persisted wall + uptime anchor.
  static Future<bool> _isTimeTamperedOffline({
    required AppDatabase db,
    int thresholdMinutes = 1,
  }) async {
    final now = DateTime.now();
    final currentUptimeSeconds = await getUptimeSeconds();

    final lastAnchor =
        await (db.select(db.timeAnchors)
              ..orderBy([(t) => OrderingTerm.desc(t.lastTick)])
              ..limit(1))
            .getSingleOrNull();

    // No anchor yet — can't verify, give benefit of the doubt
    if (lastAnchor == null) {
      await _updateAnchor(db: db, wallTime: now);
      return false;
    }

    if (currentUptimeSeconds < lastAnchor.uptimeSeconds) {
      print("📱 Reboot detected — re-anchoring. Login required.");
      // Do NOT re-anchor here — let login handle it with server time
      return false;
    }

    final timeDiff = now.difference(lastAnchor.lastTick).inSeconds;
    final uptimeDiff = currentUptimeSeconds - lastAnchor.uptimeSeconds;
    final thresholdSeconds = (thresholdMinutes * 60);

    // Forward tamper: wall clock moved ahead more than real elapsed time
    if ((timeDiff - uptimeDiff) > thresholdSeconds) {
      print(
        "🚨 OFFLINE: Clock jumped forward! timeDiff=$timeDiff uptimeDiff=$uptimeDiff",
      );
      return true;
    }

    // Wall clock moved backward vs saved anchor → backward tamper
    if (now.isBefore(lastAnchor.lastTick)) {
      print("🚨 OFFLINE: Clock went backwards!");
      return true;
    }

    await _updateAnchor(db: db, wallTime: now);
    return false;
  }

  // On app launch, before anything else
  static Future<bool> hasDeviceRebooted() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUptimeSeconds = await getUptimeSeconds();
    final lastUptimeSeconds = prefs.getInt('last_uptime_seconds') ?? 0;

    // Uptime is less than last saved → reboot occurred
    if (currentUptimeSeconds < lastUptimeSeconds) {
      return true;
    }

    await prefs.setInt('last_uptime_seconds', currentUptimeSeconds);
    return false;
  }

  /// Saves the current wall time + native uptime as a new anchor.
  static Future<void> _updateAnchor({
    required AppDatabase db,
    required DateTime wallTime,
  }) async {
    final currentUptimeSeconds = await getUptimeSeconds();

    await db.upsertTimeAnchor(wallTime, currentUptimeSeconds);
  }

  /// Saves a server-verified anchor. Call this right after successful login.
  static Future<void> saveLoginAnchor({
    required AppDatabase db,
    required DateTime serverTime,
  }) async {
    await _updateAnchor(db: db, wallTime: serverTime);
    print("SAVED LOGIN ANCHOR");
  }

  static Future<void> performSecureSave({required AppDatabase db}) async {
    // 1. Check if hardware uptime matches the clock (Anti-Forward-Jump)
    bool isDrifting = await isTimeTampered(db: db);

    // 2. Check if current time is before last saved time (Anti-Backward-Jump)
    DateTime now = DateTime.now();
    DateTime last = await TimePersistenceService.getLastRecordedTime();
    // print(!isDrifting);
    // print("IS AFTER ${now.isAfter(last)}");
    // print("LAST ${last}");
    // print("NOW ${now}");

    if (!isDrifting && now.isAfter(last)) {
      // ONLY save if both hardware and history validate the current time
      await TimePersistenceService.saveCurrentActivityTime();
      print("✅ Securely anchored time at: $now");
    } else {
      print("❌ Refusing to save suspicious time. $now");
      // Trigger your "Lock" or "Warning" UI here
    }
  }
}
