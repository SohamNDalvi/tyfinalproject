import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'user_login_page.dart'; // Import for navigation to login page


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Set a timer to navigate to the LoginPage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserLoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD700), // Yellow
              Color(0xFFFF4500), // Orange
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                'assets/BeOne_Logo.png',
                width: 190, // Adjust the width and height as needed
                height: 200,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
