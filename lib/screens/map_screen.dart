import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:nia_project/screens/full_image_viewer.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};
  late GoogleMapController mapController;

  Future<void> _goToUserLocation() async {
    // 1. Get current position
    Position position = await Geolocator.getCurrentPosition();

    // 2. Animate the camera to those coordinates
    mapController.
    animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 20,
        ),
      ),
    );
  }

  Future<void> _loadMarkers() async {
    final url = 'http://192.168.1.32:8000';
    final response = await http.get(Uri.parse('$url/markers'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      setState(() {
        _markers =
            data.map((item) {
              return Marker(
                markerId: MarkerId(item['id'].toString()),
                position: LatLng(item['latitude'], item['longitude']),
                infoWindow: InfoWindow(
                  title: "ID: ${item['id']}",
                  snippet: "${File(item['image_path'])}",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return FullImageViewer(
                            imagePath: "$url/${item['image_path']}",
                          );
                        },
                      ),
                    );
                    // showInfoDialog(item);
                  },
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              );
            }).toSet();
      });
    }
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
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          _goToUserLocation();
          _loadMarkers();
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(15.971134099999999, 120.5718656),
          zoom: 2,
        ),
        markers: _markers,
      ),
    );
  }
}
