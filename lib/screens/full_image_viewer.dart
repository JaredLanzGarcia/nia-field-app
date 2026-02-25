import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class FullImageViewer extends StatefulWidget {
  // Can be a File (local) or String (network URL)
  final dynamic imagePath;
  final String title;
  final orientation;

  const FullImageViewer({
    super.key,
    required this.imagePath,
    this.title = 'Image Preview',
    this.orientation,
  });

  @override
  State<FullImageViewer> createState() => _FullImageViewerState();
}

class _FullImageViewerState extends State<FullImageViewer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 2. IMPORTANT: Re-lock to portrait when leaving the viewer
    // to keep your camera screen stable.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (widget.imagePath is File) {
      // Local file
      imageWidget = Image.file(widget.imagePath as File, fit: BoxFit.contain);
    } else if (widget.imagePath is String) {
      // Network URL
      imageWidget = CachedNetworkImage(
        imageUrl: widget.imagePath as String,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else {
      imageWidget = const Center(
        child: Text(
          'Invalid image source.',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => saveToGallery(widget.imagePath.path as String),
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: fallback(imageWidget),
    );
  }

  Widget fallback(imageWidget) {
    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 4.0,
      child: Center(child: imageWidget),
    );
  }

  Future<void> saveToGallery(String path) async {
    // Check/Request permission
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) await Gal.requestAccess();

    // Save the image to the actual phone gallery
    await Gal.putImage(path);
    print("Saved to Gallery!");
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text("Saved to Gallery"),
      ),
    );
  }
}
