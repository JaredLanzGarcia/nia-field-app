import 'package:flutter/material.dart';
import 'package:nia_project/auth_service.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/screens/history_screen.dart';
import 'package:nia_project/screens/home_screen.dart';
import 'package:nia_project/screens/map_screen.dart';

class PulseNavigationScreen extends StatefulWidget {
  const PulseNavigationScreen({
    super.key,
    required this.authService,
    required this.db,
  });
  final AuthService authService;
  final AppDatabase db;

  @override
  State<PulseNavigationScreen> createState() => _PulseNavigationScreenState();
}

class _PulseNavigationScreenState extends State<PulseNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(authService: widget.authService, db: widget.db),
      HistoryScreen(authService: widget.authService, db: widget.db),
      MapScreen(db: widget.db),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6B7FD4),
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 0
                          ? const Color(0xFF6B7FD4).withOpacity(0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.camera_alt_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7FD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.camera_alt_outlined),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 1
                          ? const Color(0xFF6B7FD4).withOpacity(0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.history),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7FD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.history),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 2
                          ? const Color(0xFF6B7FD4).withOpacity(0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.map_outlined), // Personnel Unified Location & Status Endpoint
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7FD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.map_outlined),
              ),
              label: 'Map',
            ),
          ],
        ),
      ),
    );
  }
}
