import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/time_security_service.dart';

class HeartbeatService {
  final AppDatabase db;
  Timer? _timer;

  HeartbeatService(this.db);

  void start() {
    _verifyAndTick();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _verifyAndTick();
    });
  }

  Future<void> _verifyAndTick() async {
    final tampered = await TimeSecurityService.isTimeTampered(db: db);

    if (tampered) {
      print(
        "🚨 HEARTBEAT: Time tamper detected — not saving anchor. ${DateTime.now()}",
      );
      return;
    }
    print("✅ HEARTBEAT: Time looks clean. ${DateTime.now()}");
  }

  Future<void> debugTick() => _verifyAndTick();

  void stop() => _timer?.cancel();
}
