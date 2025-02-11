import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/EmployeeUploadation_Page.dart';

class EmployeeStartLocationSharingPage extends StatefulWidget {
  final String userId;
  final String donationId;

  EmployeeStartLocationSharingPage({required this.userId, required this.donationId});

  @override
  _EmployeeStartLocationSharingPageState createState() => _EmployeeStartLocationSharingPageState();
}

class _EmployeeStartLocationSharingPageState extends State<EmployeeStartLocationSharingPage> {
  LatLng? donationLocation;
  Map<String, dynamic>? donationDetails;
  Map<String, dynamic>? userDetails;
  Timer? _locationTimer;
  bool isSharingLocation = false; // Track if location sharing is active

  @override
  void initState() {
    super.initState();
    _fetchDonationDetails();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted
    } else {
      // Handle permission denied
      print("Location permission denied");
    }
  }

  Future<void> _fetchDonationDetails() async {
    try {
      // Fetch donation details
      DocumentSnapshot donationSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(widget.userId) // Parent document for the user
          .collection('userDonations')
          .doc(widget.donationId) // Specific donation document
          .get();

      if (donationSnapshot.exists) {
        donationDetails = donationSnapshot.data() as Map<String, dynamic>;

        // Fetch user details
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId) // Fetch user details using userId
            .get();

        if (userSnapshot.exists) {
          userDetails = userSnapshot.data() as Map<String, dynamic>;
        }

        // Set the donation location using latitude and longitude from donation details
        double latitude = donationDetails!['CurrentLatitude'] ?? 0.0;
        double longitude = donationDetails!['CurrentLongitude'] ?? 0.0;
        donationLocation = LatLng(latitude, longitude);
      }
    } catch (e) {
      print("Error fetching donation details: $e");
    }

    setState(() {}); // Refresh the UI
  }

  Future<void> _startLocationSharing() async {
    // Update Firestore to start location sharing
    await FirebaseFirestore.instance
        .collection('Donations')
        .doc(widget.userId) // Parent user document
        .collection('userDonations')
        .doc(widget.donationId) // Specific donation document
        .update({
      'startLocShare': true,
      'status': 'Ongoing',
    });

    // Start updating location every 10 seconds
    isSharingLocation = true; // Set sharing status to true
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _updateLocation();
    });
  }

  Future<void> _stopLocationSharing() async {
    // Update Firestore to stop location sharing
    await FirebaseFirestore.instance.collection('Donations').doc(widget.userId).update({
      'startLocShare': false,
      'status': 'Pending', // Change status as needed
    });

    // Cancel the location update timer
    _locationTimer?.cancel();
    isSharingLocation = false; // Set sharing status to false
    print("Location sharing stopped");
  }

  Future<void> _updateLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empuserId = prefs.getString('uid');
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await FirebaseFirestore.instance.collection('users').doc(empuserId).update({
      'empCurrentLatitude': position.latitude,
      'empCurrentLongitude': position.longitude,
    });
    print("Successfully updated location");
  }

  @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: donationDetails == null || userDetails == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            _buildSectionTitle("Donation Information"),
            _buildInfoTable([
              {"Donation ID": donationDetails!['DonationId'] ?? 'Unknown'},
              {"Food Category": donationDetails!['FoodCategory'] ?? 'Unknown'},
              {"Food Condition": donationDetails!['FoodCondition'] ?? 'Unknown'},
              {"Food Type": donationDetails!['FoodType'] ?? 'Unknown'},
              {"Ingredient Used": donationDetails!['IngredientUsed'] ?? 'Unknown'},
              {"Number of Servings": donationDetails!['NumberOfServing']?.toString() ?? 'Unknown'},
              {"Special Instructions": donationDetails!['SpecialInstruction'] ?? 'None'},
              {"Quantity": donationDetails!['Quantity'] ?? 'Unknown'}
            ]),
            _buildSectionTitle("Pickup Information"),
            _buildInfoTable([
              {"Address": donationDetails!['Address'] ?? 'Unknown'},
              {"City": donationDetails!['City'] ?? 'Unknown'},
              {"Pickup Date": donationDetails!['PickUpDate'] ?? 'Unknown'},
              {"Pickup Time Slot": donationDetails!['PickUpTimeSlot'] ?? 'Unknown'},
              {"Status": donationDetails!['status'] ?? 'Unknown'}
            ]),
            _buildMapSection(context),
            SizedBox(height: 20),
            _buildActionButtons(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text("Donation Details", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.red,
            child: Text(donationDetails!['Name']?.substring(0, 2).toUpperCase() ?? 'U', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(donationDetails!['Name'] ?? 'Unknown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("EMAIL: ${userDetails?['email'] ?? 'Unknown'}"),
                Text("Phone: ${userDetails?['phoneNumber'] ?? 'Unknown'}"),
                Text("User  ID: ${widget.userId}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoTable(List<Map<String, dynamic>> data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        padding: EdgeInsets.all(2),
        child: Table(
          border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300)),
          columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
          children: data.map((item) {
            return TableRow(
              children: [
                IntrinsicHeight(
                  child: Container(
                    color: Colors.grey.shade100,
                    padding: EdgeInsets.all(12),
                    alignment: Alignment.centerLeft,
                    child: Text(item.keys.first, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                IntrinsicHeight(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(12),
                    alignment: Alignment.centerLeft,
                    child: item.values.first is Widget ? item.values.first : Text(item.values.first),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return _buildInfoTable([
      {
        "Fetch location on Map": Column(
          children: [
            GestureDetector(
              onTap: () => _showMapDialog(context),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: FlutterMap(
                  options: MapOptions(center: donationLocation ?? LatLng(0, 0), zoom: 13),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
                    MarkerLayer(markers: [
                      if (donationLocation != null)
                        Marker(
                          point: donationLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                    ]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () => _showMapDialog(context),
              child: Text(
                "Open Full Map View",
                style: TextStyle(fontSize: 13.5),
              ),
            ),
          ],
        ),
      }
    ]);
  }

  void _showMapDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(center: donationLocation ?? LatLng(0, 0), zoom: 13, minZoom: 5, interactiveFlags: InteractiveFlag.all),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
                    MarkerLayer(markers: [
                      if (donationLocation != null)
                        Marker(
                          point: donationLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48, // Ensures consistent height for both buttons
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              _startLocationSharing(); // Start location sharing when button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeUploadationPage(
                    userId: widget.userId, // Pass userId to the next page
                    donationId: widget.donationId, // Pass donationId to the next page
                  ),
                ),
              );
            },
            child: Text(
              "START LOCATION SHARING",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 10), // Space between the buttons
        SizedBox(
          width: double.infinity,
          height: 48, // Ensures consistent height for both buttons
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Color for stop button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              _stopLocationSharingin(); // Stop location sharing when button is pressed
            },
            child: Text(
              "STOP LOCATION SHARING",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _stopLocationSharingin() async {
    // Update Firestore to stop location sharing
    await FirebaseFirestore.instance.collection('Donations').doc(widget.userId).update({
      'startLocShare': false,
      'status': 'Assigned', // Change status as needed
    });

    // Cancel the location update timer
    _locationTimer?.cancel();
    print("Location sharing stopped");
  }
}