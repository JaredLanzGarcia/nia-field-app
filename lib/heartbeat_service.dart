import 'dart:async';
import 'package:drift/drift.dart';
import 'package:nia_project/database.dart';

class HeartbeatService {
  Timer? _timer;
  final AppDatabase db;

  // Stopwatch starts when the service is first created (app launch)
  static final Stopwatch _appUptime = Stopwatch()..start();

  HeartbeatService(this.db);

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _verifyAndTick();
    });
  }

  Future<void> _verifyAndTick() async {
    final now = DateTime.now();
    final currentUptimeSeconds = _appUptime.elapsed.inSeconds;

    final lastAnchor =
        await (db.select(db.timeAnchors)
              ..orderBy([(t) => OrderingTerm.desc(t.lastTick)])
              ..limit(1))
            .getSingleOrNull();

    if (lastAnchor != null) {
      final timeDiff = now.difference(lastAnchor.lastTick).inSeconds;
      final uptimeDiff = currentUptimeSeconds - lastAnchor.uptimeSeconds;

      // Wall clock jumped but app uptime didn't — tampered
      if ((timeDiff - uptimeDiff).abs() > 60) {
        print("🚨 TIME TAMPER DETECTED: Clock jumped!");
        return;
      }

      // Clock went backwards
      if (now.isBefore(lastAnchor.lastTick)) {
        print("🚨 TIME TAMPER DETECTED: Clock went backwards!");
        return;
      }
    }

    await db
        .into(db.timeAnchors)
        .insert(
          TimeAnchorsCompanion.insert(
            lastTick: now,
            uptimeSeconds: currentUptimeSeconds,
          ),
        );
    print("Inserted new time");
    // add a way to save the time if not tampered and use that time for "last_activity" value
    // tested 50x each for forward and backward tampering
    // had an idea for resetting tampered time if admin is called

    // Clear anchors and do a fresh tick
    // await db.delete(db.timeAnchors).go();
    // await heartbeat.debugTick(); // should insert cleanly with no warnings
  }

  Future<void> debugTick() => _verifyAndTick();

  void stop() => _timer?.cancel();
}
