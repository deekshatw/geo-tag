import 'package:flutter/material.dart';
import 'package:geo_tag/core/shared_prefs/shared_prefs.dart';
import 'package:geo_tag/features/auth/screens/login_screen.dart';
import 'package:geo_tag/features/home/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    _checkIsLoggedIn();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => isLoggedIn ? HomeScreen() : LoginScreen()));
    });
    super.initState();
  }

  void _checkIsLoggedIn() async {
    isLoggedIn = await SharedPrefs.getUsernameSharedPreference() != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          height: 200,
        ),
      ),
    );
  }
}
