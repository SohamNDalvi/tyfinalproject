import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Employee_Assigned_Donation_Page.dart';
import 'Employee_account_screen.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: EmployeeHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class EmployeeHomePage extends StatefulWidget {
  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _requestLocationPermission();
    updateUserFCMToken();
  }

  Future<void> updateUserFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    String? fcmToken = prefs.getString('fcm_token');

    // Check if userId and fcmToken are valid
    if (userId == null || userId.isEmpty) {
      print('❌ No userId found in SharedPreferences');
      return; // Exit if userId is not valid
    }

    if (fcmToken == null || fcmToken.isEmpty) {
      print('❌ No FCM token found in SharedPreferences');
      return; // Exit if fcmToken is not valid
    }

    // If both userId and fcmToken are valid, update Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'userFcmToken': fcmToken,
    }, SetOptions(merge: true)); // Use merge to create or update the field

    print('✅ FCM token updated successfully for user: $userId');
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid');
    if (userId != null) {
      _fetchAndStoreLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted
    } else {
      // Handle permission denied
    }
  }

  Future<void> _fetchAndStoreLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'empCurrentLatitude': position.latitude,
      'empCurrentLongitude': position.longitude,
    }, SetOptions(merge: true));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hello, Soham Dalvi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmployeeAccountScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'Manage your data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            // First Row with Two Cards
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                    },
                    child: _buildCard('Start Location Sharing', 'assets/images/sponsor_banner2.png'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Assigned Donations screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmployeeAssignedDonations()),
                      );
                    },
                    child: _buildCard('Assigned Donations', 'assets/images/sponsor_banner2.png'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Second Row with One Large Card
            _buildCard('Completed Donations', 'assets/images/sponsor_banner2.png', height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String imagePath, {double height = 100}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}