import 'dart:io';
import 'package:image/image.dart' as img;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:nia_project/screens/full_image_viewer.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _selectedCameraIndex = 0; // Start with the back camera
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    // 1. Initialize the controller with a specific camera (usually cameras[0] for back)
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose(); // CRITICAL: Always dispose!
    super.dispose();
  }

  Future<void> saveToGallery(String path) async {
    // Check/Request permission
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) await Gal.requestAccess();

    // Save the image to the actual phone gallery
    await Gal.putImage(path);
    print("Saved to Gallery!");
  }

  Future<void> _onCameraSwitch() async {
    // 1. Determine the next camera index
    _minAvailableZoom = await _controller.getMinZoomLevel();
    _maxAvailableZoom = await _controller.getMaxZoomLevel();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    CameraDescription nextCamera = widget.cameras[_selectedCameraIndex];

    // 2. Dispose of the current controller to free up memory
    await _controller.dispose();

    // 3. Create and initialize the new controller
    _controller = CameraController(nextCamera, ResolutionPreset.high);

    try {
      _initializeControllerFuture = _controller.initialize();
      if (mounted) setState(() {}); // Refresh the UI with the new preview
    } catch (e) {
      debugPrint("Error switching cameras: $e");
    }
  }

  // Future<File> _mirrorSelfie(XFile xFile) async {
  //   // 1. Read the bytes from the XFile
  //   final bytes = await xFile.readAsBytes();

  //   // 2. Decode the bytes into an image object
  //   img.Image? originalImage = img.decodeImage(bytes);

  //   if (originalImage == null) return File(xFile.path);

  //   // 3. Flip the image horizontally (left-to-right)
  //   img.Image mirroredImage = img.flipHorizontal(originalImage);

  //   // 4. Save the mirrored image back to a file
  //   // We can overwrite the original temporary file or create a new one
  //   final mirroredFile = File(xFile.path);
  //   await mirroredFile.writeAsBytes(img.encodeJpg(mirroredImage));

  //   return mirroredFile;
  // }

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (ctx) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // 2. Use a Stack to layer your UI over the preview

                return Stack(
                  children: [
                    GestureDetector(
                      onScaleStart: (_) => _baseZoomLevel = _currentZoomLevel,
                      onScaleUpdate: (details) async {
                        // Calculate the new zoom level based on the pinch gesture
                        double newZoom = (_baseZoomLevel * details.scale).clamp(
                          _minAvailableZoom,
                          _maxAvailableZoom,
                        );

                        if (newZoom != _currentZoomLevel) {
                          _currentZoomLevel = newZoom;
                          await _controller.setZoomLevel(_currentZoomLevel);
                          setState(
                            () {},
                          ); // Update UI if you have a zoom indicator
                        }
                      },
                      child: Center(child: CameraPreview(_controller)),
                    ),
                    Positioned(
                      bottom: 60,
                      right: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 25,
                        child: IconButton(
                          icon: const Icon(
                            Icons.cameraswitch_outlined,
                            color: Colors.white,
                          ),
                          onPressed:
                              _onCameraSwitch, // Call the switch method here
                        ),
                      ),
                    ),

                    // Shutter Button (Center)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: IconButton(
                          iconSize: 80,
                          icon: const Icon(Icons.circle, color: Colors.white),
                          onPressed:
                              () => _takePicture(
                                ctx,
                              ), // Moved logic to a separate method
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }

  void _takePicture(BuildContext ctx) async {
    final orientation = NativeDeviceOrientationReader.orientation(ctx);
    print(orientation);
    try {
      await _initializeControllerFuture;
      final XFile xFile = await _controller.takePicture();
      File finalFile = await _processCapturedImage(xFile, orientation);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            return FullImageViewer(
              imagePath: finalFile,
              orientation: orientation,
            );
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<File> _processCapturedImage(
    XFile xFile,
    NativeDeviceOrientation orientation,
  ) async {
    final bytes = await xFile.readAsBytes();
    img.Image? capturedImage = img.decodeImage(bytes);

    if (capturedImage == null) return File(xFile.path);

    // 1. Physical Rotation based on how the user held the phone
    if (orientation == NativeDeviceOrientation.landscapeLeft) {
      capturedImage = img.copyRotate(capturedImage, angle: 90);
    } else if (orientation == NativeDeviceOrientation.landscapeRight) {
      capturedImage = img.copyRotate(capturedImage, angle: -90);
    } else if (orientation == NativeDeviceOrientation.portraitDown) {
      capturedImage = img.copyRotate(capturedImage, angle: 180);
    }

    // 2. Mirroring (only for front camera)
    if (_controller.description.lensDirection == CameraLensDirection.front) {
      capturedImage = img.flipHorizontal(capturedImage);
    }

    // 3. Save the "Basked" image (it now has the correct orientation in the pixels)
    final processedFile = File(xFile.path);
    await processedFile.writeAsBytes(img.encodeJpg(capturedImage));

    return processedFile;
  }
}
