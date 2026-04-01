import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:intl/intl.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/screens/full_image_viewer.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key, this.item_lat, this.item_long, this.item_date});
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
  final database = AppDatabase();
  DateTime selectedDate = DateTime.now();
  final api_url = 'http://192.168.1.70:8000';

  @override
  void initState() {
    super.initState();
    selectedDate =
        widget.item_date != null ? widget.item_date! : DateTime.now();
  }

  Future<void> _goToUserLocation() async {
    // 1. Get current position
    Position position = await Geolocator.getCurrentPosition();

    // 2. Animate the camera to those coordinates
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              widget.item_lat != null
                  ? LatLng(widget.item_lat!, widget.item_long!)
                  : LatLng(position.latitude, position.longitude),
          zoom: 18,
        ),
      ),
    );
  }

  Future<void> _loadMarkers() async {
    // final response = await http.get(Uri.parse('$api_url/markers'));
    final allImages = await database.select(database.capturedImages).get();

    final filtered =
        allImages.where((img) {
          return img.deviceTimestamp.year == selectedDate.year &&
              img.deviceTimestamp.month == selectedDate.month &&
              img.deviceTimestamp.day == selectedDate.day;
        }).toList();

    setState(() {
      _markers =
          filtered.map((item) {
            String formatted = DateFormat.jm().format(item.deviceTimestamp);
            return Marker(
              markerId: MarkerId(item.id.toString()),
              position: LatLng(item.latitude, item.longitude),
              infoWindow: InfoWindow(
                title: "ID: ${item.id.toString()}",
                snippet: formatted,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return FullImageViewer(imagePath: File(item.imagePath));
                      },
                    ),
                  );
                  // showInfoDialog(item);
                },
              ),
              icon:
                  widget.item_lat == item.latitude
                      ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      )
                      : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
            );
          }).toSet();
    });
  }

  Future<dynamic> showInfoDialog(item) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("ID: ${item['id']}"),
          content: Column(
            children: [
              Text(
                "Lat: ${item['latitude']}\nLong: ${item['longitude']}\n-Place- \n${item['place']}",
              ),
              Expanded(child: Image.file(File(item['image_path']), width: 50)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map of Captured Images")),
      body: Stack(
        children: [
          Positioned(
            child: GoogleMap(
              onMapCreated: (controller) async {
                mapController = controller;
                _goToUserLocation();
                _loadMarkers();
                final now = DateFormat.yMMMMd().format(DateTime.now());

                _dateController.text = now;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(15.971134099999999, 120.5718656),
                zoom: 2,
              ),
              markers: _markers,
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
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
                  });
                  _loadMarkers(); // Reload markers for the new date
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat.yMMMMd().format(selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
