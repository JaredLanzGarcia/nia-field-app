import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
            onPressed: () {
              widget.imagePath.toString().startsWith("http")
                  ? print("Starts ${widget.imagePath as String}")
                  : print("Without ${widget.imagePath.path as String}");
              saveToGallery(
                widget.imagePath.toString().startsWith("http")
                    ? widget.imagePath as String
                    : widget.imagePath.path as String,
              );
            },
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

    if (path.startsWith("http")) {
      String fixedUrl = path.replaceAll('\\', '/');
      String fileName = p.basename(fixedUrl);
      // 1. Get temporary directory
      Directory directory = await getApplicationDocumentsDirectory();
      String localPath = p.join(directory.path, fileName);

      // 2. Download the bytes
      final response = await http.get(Uri.parse(fixedUrl));

      if (response.statusCode == 200) {
        // 3. Write to a local file
        File file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);

        // 4. Save to Gallery using the LOCAL path
        await Gal.putImage(file.path);
        print("Saved successfully!");
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed to download image"),
          ),
        );
        throw Exception("Failed to download image");
      }
    } else {
      await Gal.putImage(path);
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text("Saved to Gallery"),
      ),
    );
  }
}
