import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/url_of_db.dart';

class MapScreen extends StatefulWidget {
  MapScreen({
    super.key,
    required this.db,
    this.item_lat,
    this.item_long,
    this.item_date,
  });
  final AppDatabase db;
  double? item_lat;
  double? item_long;
  DateTime? item_date;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  late GoogleMapController mapController;
  final TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final api_url = UrlOfDb.dbUrl;
  LatLng? _userLatLng;

  // For the selected marker bottom card
  CapturedImage? _selectedItem;

  @override
  void initState() {
    super.initState();
    selectedDate =
        widget.item_date != null ? widget.item_date! : DateTime.now();
  }

  Future<void> _goToUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // Can't get location — just stay on the initial camera position
        return;
      }

      // If a specific item was passed in, go straight to it without needing GPS
      if (widget.item_lat != null) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(widget.item_lat!, widget.item_long!),
              zoom: 18,
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLatLng = userLatLng;
      });

      // Add the user dot marker
      _addUserDotMarker(userLatLng);

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 18),
        ),
      );
    } catch (e) {
      // Silently ignore — map stays on initial camera position
      print('Could not get user location: $e');
    }
  }

  Future<void> _addUserDotMarker(LatLng position) async {
    // Draw a blue dot as a BitmapDescriptor
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 40.0;

    // Outer white ring
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, whitePaint);

    // Inner blue dot
    final bluePaint = Paint()..color = const Color(0xFF1A73E8);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.8, bluePaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final userDotIcon = BitmapDescriptor.bytes(bytes!.buffer.asUint8List());

    setState(() {
      _markers.removeWhere(
        (m) => m.markerId == const MarkerId('user_location'),
      );
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: position,
          icon: userDotIcon,
          anchor: const Offset(0.5, 0.5), // Center the dot on the coordinate
          zIndex: 999, // Always on top
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    });
  }

  Future<void> _loadMarkers() async {
    final allImages = await widget.db.select(widget.db.capturedImages).get();

    final filtered =
        allImages.where((img) {
          return img.deviceTimestamp.year == selectedDate.year &&
              img.deviceTimestamp.month == selectedDate.month &&
              img.deviceTimestamp.day == selectedDate.day;
        }).toList();

    setState(() {
      _markers =
          filtered.map((item) {
            final bool isSelected = widget.item_lat == item.latitude;
            return Marker(
              markerId: MarkerId(item.id.toString()),
              position: LatLng(item.latitude, item.longitude),
              icon:
                  isSelected
                      ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      )
                      : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
              onTap: () {
                setState(() {
                  _selectedItem = item;
                });
              },
            );
          }).toSet();
    });
    if (_userLatLng != null) {
      _addUserDotMarker(_userLatLng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNavigatedFromHistory = widget.item_lat != null;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ---------- FULL SCREEN MAP ----------
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: (controller) async {
                  mapController = controller;
                  _goToUserLocation();
                  _loadMarkers();
                  final now = DateFormat.yMMMMd().format(DateTime.now());
                  _dateController.text = now;
                },
                initialCameraPosition: CameraPosition(
                  target: const LatLng(15.971134099999999, 120.5718656),
                  zoom: 2,
                ),
                markers: _markers,
                onTap: (_) {
                  setState(() {
                    _selectedItem = null;
                  });
                },
              ),
            ),

            // ---------- APP BAR OVERLAY ----------
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Back button if navigated from history
                    if (isNavigatedFromHistory)
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                    Image.asset(
                      'assets/images/pulse-logo-wo-name.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PULSE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          "Personnel's Updated Location & Site Evidence",
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.logout_outlined,
                      size: 22,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),

            // ---------- DATE PICKER CARD (kept from original) ----------
            Positioned(
              top: 80,
              left: 20,
              right: 80,
              child: GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                      _dateController.text = DateFormat.yMMMMd().format(picked);
                      _selectedItem = null;
                    });
                    _loadMarkers();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedDate.year == DateTime.now().year &&
                                selectedDate.month == DateTime.now().month &&
                                selectedDate.day == DateTime.now().day
                            ? "Today's Logs Only"
                            : DateFormat.yMMMd().format(selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- RIGHT-SIDE FLOATING BUTTONS ----------
            Positioned(
              top: 80,
              right: 16,
              child: Column(
                children: [
                  // Go to GPS location
                  GestureDetector(
                    onTap: _goToUserLocation,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // ---------- SELECTED MARKER BOTTOM CARD ----------
            if (_selectedItem != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image / Camera icon placeholder
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8ECF9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildMarkerThumbnail(_selectedItem!),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (_selectedItem!.place ?? 'Unknown Location')
                                        .replaceAll('\n', ', '),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCE8FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _selectedItem!.isSynced
                                        ? 'SYNCED'
                                        : 'ACTIVE',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3A6BDC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Logged via PULSE at ${DateFormat.jm().format(_selectedItem!.deviceTimestamp)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM d, y').format(
                                        _selectedItem!.deviceTimestamp,
                                      ) ==
                                      DateFormat(
                                        'MMMM d, y',
                                      ).format(DateTime.now())
                                  ? 'Today'
                                  : DateFormat(
                                    'MMMM d, y',
                                  ).format(_selectedItem!.deviceTimestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerThumbnail(CapturedImage item) {
    if (item.imagePath.startsWith('http')) {
      return Image.network(
        item.imagePath,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                const Icon(Icons.camera_alt_outlined, color: Color(0xFF6B7FD4)),
      );
    }
    final file = File(item.imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                const Icon(Icons.camera_alt_outlined, color: Color(0xFF6B7FD4)),
      );
    }
    return const Icon(Icons.camera_alt_outlined, color: Color(0xFF6B7FD4));
  }
}
