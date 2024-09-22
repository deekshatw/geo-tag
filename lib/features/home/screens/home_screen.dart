import 'package:flutter/material.dart';
import 'package:geo_tag/core/shared_prefs/shared_prefs.dart';
import 'package:geo_tag/core/widgets/primary_button.dart';
import 'package:geo_tag/features/auth/screens/login_screen.dart';
import 'package:geo_tag/features/camera/screens/camera_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  bool _isLoading = false;

  @override
  void initState() {
    _getUsername();
    super.initState();
  }

  Future<void> _getUsername() async {
    username = await SharedPrefs.getUsernameSharedPreference();
    setState(() {});
  }

  Future<void> _openCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PermissionStatus cameraStatus = await Permission.camera.request();
      PermissionStatus locationStatus = await Permission.location.request();

      if (cameraStatus.isGranted && locationStatus.isGranted) {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Reverse geocoding to get the address
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final Placemark placemark = placemarks.first;
        final String address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';

        // Navigate to CameraScreen with position and address data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CameraScreen(
              // address: address,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera or location permissions denied!'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: _handleLogout,
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Dear\n $username',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Press button below to open camera!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    onTap: _openCamera,
                    label: 'Open Camera',
                  ),
                ],
              ),
            ),
    );
  }

  _handleLogout() async {
    // Show confirmation dialog
    bool shouldLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Don't logout
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Proceed with logout
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    // Proceed with logout if confirmed
    if (shouldLogout) {
      SharedPrefs.clearUserSharedPreferences(); // Clear shared preferences
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Logged out successfully!'),
        ),
      );
    }
  }
}
