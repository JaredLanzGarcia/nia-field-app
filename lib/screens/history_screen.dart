import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nia_project/auth_service.dart';
import 'package:nia_project/database.dart';
import 'package:nia_project/screens/full_image_viewer.dart';
import 'package:nia_project/screens/map_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.authService, required this.db});
  final AuthService authService;
  final AppDatabase db;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- APP BAR ----------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
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
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.green),
                                  SizedBox(width: 10),
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text(
                                "Are you sure you want to exit PULSE?",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              actionsPadding: const EdgeInsets.only(
                                right: 16,
                                bottom: 16,
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    widget.authService.logout(widget.db);
                                  },
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    icon: const Icon(Icons.logout_outlined, size: 22),
                  ),
                ],
              ),
            ),

            // ---------- TITLE + FILTER ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log History',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            // ---------- LIST ----------
            Expanded(
              child: StreamBuilder<List<CapturedImage>>(
                stream: widget.db.select(widget.db.capturedImages).watch(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final rawImages = snapshot.data!;
                  rawImages.sort(
                    (a, b) => b.deviceTimestamp.compareTo(a.deviceTimestamp),
                  );

                  if (rawImages.isEmpty) {
                    return Center(
                      child: Text(
                        'No log entries yet.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  final groups = _groupImagesByRelativeDate(rawImages);
                  final dateKeys = groups.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, index) {
                      final dateLabel = dateKeys[index];
                      final imagesForDay = groups[dateLabel]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- DATE GROUP HEADER ---
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  dateLabel.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),
                          ),

                          // --- ENTRIES FOR THIS DATE ---
                          ...imagesForDay.map((item) => _buildLogItem(item)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(CapturedImage item) {
    return GestureDetector(
      onTap: () => _viewActions(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImageThumbnail(item, size: 62),
            ),
            const SizedBox(width: 14),

            // Time + Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.jm().format(item.deviceTimestamp),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.place.replaceAll('\n', ', '),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Sync icon
            item.isSynced
                ? const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 22,
                )
                : const Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.green,
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _viewActions(BuildContext context, CapturedImage item) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text("View Image"),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => FullImageViewer(
                            imagePath:
                                item.imagePath.startsWith("http")
                                    ? item.imagePath
                                    : File(item.imagePath),
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text("View Location"),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => MapScreen(
                            db: widget.db,
                            item_lat: item.latitude,
                            item_long: item.longitude,
                            item_date: item.deviceTimestamp,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<CapturedImage>> _groupImagesByRelativeDate(
    List<CapturedImage> images,
  ) {
    final Map<String, List<CapturedImage>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var image in images) {
      final d = image.deviceTimestamp;
      final imageDay = DateTime(d.year, d.month, d.day);

      String dateKey;
      if (imageDay == today) {
        dateKey = 'Today';
      } else if (imageDay == yesterday) {
        dateKey = 'Yesterday';
      } else {
        dateKey = DateFormat.yMMMMd().format(d);
      }

      groups.putIfAbsent(dateKey, () => []).add(image);
    }
    return groups;
  }
}

Widget _buildImageThumbnail(CapturedImage item, {double size = 50}) {
  return item.imagePath.startsWith("http")
      ? CachedNetworkImage(
        imageUrl: item.imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => SizedBox(
              width: size,
              height: size,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        errorWidget:
            (context, url, error) =>
                const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        httpHeaders: const {},
      )
      : _LocalImageWidget(path: item.imagePath, size: size);
}

class _LocalImageWidget extends StatefulWidget {
  final String path;
  final double size;
  const _LocalImageWidget({required this.path, required this.size});

  @override
  State<_LocalImageWidget> createState() => _LocalImageWidgetState();
}

class _LocalImageWidgetState extends State<_LocalImageWidget> {
  late Future<bool> _fileExists;

  @override
  void initState() {
    super.initState();
    _fileExists = File(widget.path).exists();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _fileExists,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.file(
            File(widget.path),
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
          );
        }
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }
}
