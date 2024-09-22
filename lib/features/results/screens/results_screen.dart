import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final String address;
  final String dateTime;
  final String latitude;
  final String longitude;

  ResultScreen({
    Key? key,
    required this.imagePath,
    required this.address,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  final GlobalKey _globalKey = GlobalKey();

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
        SnackBar(content: Text('Image saved to gallery')),
      );
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image')),
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
              if (imagePath.isNotEmpty)
                Image.file(
                  File(imagePath),
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
                        'Address: $address',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Latitude: $latitude,',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ' Longitude: $longitude',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Date: $dateTime',
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
            ],
          ),
        ),
      ),
    );
  }
}
