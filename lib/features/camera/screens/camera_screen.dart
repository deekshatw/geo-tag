import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geo_tag/features/results/screens/results_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class CameraScreen extends StatefulWidget {
  final bool isUsernameEnabled;

  const CameraScreen({super.key, required this.isUsernameEnabled});
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _image;
  List<CameraDescription>? _cameras;
  bool _isFrontCamera = false;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 4.0;

  String? _currentAddress;
  Position? _currentPosition;
  String? _currentDateTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
    _getCurrentDateTime();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _setCamera(_isFrontCamera ? _cameras![1] : _cameras![0]);
  }

  Future<void> _setCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    _minZoomLevel = await _controller!.getMinZoomLevel();
    _maxZoomLevel = await _controller!.getMaxZoomLevel();
    setState(() {});
  }

  void _getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    setState(() {
      _currentDateTime = formattedDateTime;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller!.takePicture();
      setState(() {
        _image = image;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imagePath: _image!.path,
            address: _currentAddress ?? 'Unknown location',
            dateTime: _currentDateTime ?? 'Unknown time',
            latitude: _currentPosition?.latitude.toString() ?? 'Unknown',
            longitude: _currentPosition?.longitude.toString() ?? 'Unknown',
            isUsernameEnabled: widget.isUsernameEnabled,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _switchCamera() {
    _isFrontCamera = !_isFrontCamera;
    _setCamera(_isFrontCamera ? _cameras![1] : _cameras![0]);
    setState(() {});
  }

  Future<void> _zoomCamera(double zoomLevel) async {
    if (zoomLevel >= _minZoomLevel && zoomLevel <= _maxZoomLevel) {
      await _controller?.setZoomLevel(zoomLevel);
      setState(() {
        _currentZoomLevel = zoomLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  onScaleUpdate: (ScaleUpdateDetails details) {
                    if (details.scale != 1.0) {
                      _zoomCamera(_currentZoomLevel * details.scale);
                    }
                  },
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Address: ${_currentAddress ?? 'Fetching...'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Date & Time: ${_currentDateTime ?? 'Fetching...'}',
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
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Centered Take Picture Button
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    shape: const CircleBorder(),
                  ),
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera),
                ),
                // Switch Camera Button on the right
                Positioned(
                  right: 20, // Adjust padding as necessary
                  child: IconButton(
                    icon: const Icon(
                      Icons.cameraswitch_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _switchCamera,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
