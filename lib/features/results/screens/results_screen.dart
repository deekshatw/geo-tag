import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geo_tag/core/shared_prefs/shared_prefs.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final String address;
  final String dateTime;
  final String latitude;
  final String longitude;
  final bool isUsernameEnabled;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.address,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.isUsernameEnabled,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _globalKey = GlobalKey();
  String? username;

  @override
  void initState() {
    widget.isUsernameEnabled ? _getUsername() : null;
    super.initState();
  }

  Future<void> _getUsername() async {
    username = await SharedPrefs.getUsernameSharedPreference();
    setState(() {});
  }

  Future<void> _saveImageWithText(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/geo_tag${DateTime.now().millisecondsSinceEpoch}.png';
      File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      // Save to gallery
      final result = await ImageGallerySaver.saveFile(filePath);

      // Show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery')),
      );
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text(
              'Save Image',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () => _saveImageWithText(context),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _globalKey,
          child: Stack(
            children: [
              if (widget.imagePath.isNotEmpty)
                Image.file(
                  File(widget.imagePath),
                ),
              Positioned(
                bottom: 40,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address: ${widget.address}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Latitude: ${widget.latitude},',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ' Longitude: ${widget.longitude}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Date: ${widget.dateTime}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.isUsernameEnabled)
                Positioned(
                  top: 20,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.camera,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          'Clicked by $username',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
