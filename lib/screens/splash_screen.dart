import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1. Initialize the controller
    _controller = AnimationController(
      duration: const Duration(seconds: 5), // Speed of rotation
      vsync: this,
    )..repeat(); // 2. Tell it to repeat infinitely
  }

  @override
  void dispose() {
    _controller.dispose(); // 3. Clean up to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform(
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_controller.value * 2 * math.pi),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: Image.asset("assets/images/pulse-logo-green.png"),
        ),
      ),
    );
  }
}
