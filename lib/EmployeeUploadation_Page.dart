import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:final_project/Employee_home_Page.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeUploadationPage extends StatefulWidget {
  final String userId;
  final String donationId;
  final Timer? locationTimer; // Accept the locationTimer

  EmployeeUploadationPage({required this.userId, required this.donationId, this.locationTimer}); // Update constructor

  @override
  _EmployeeUploadationPageState createState() => _EmployeeUploadationPageState();
}

class _EmployeeUploadationPageState extends State<EmployeeUploadationPage> {
  LatLng? donationLocation;
  Map<String, dynamic>? donationDetails;
  Map<String, dynamic>? userDetails;
  Timer? _locationTimer;
  List<File> uploadedImages = [];

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
      print("Location permission denied");
    }
  }

  Future<void> _openGoogleMaps() async {
    if (donationDetails != null) {
      double latitude = donationDetails!['CurrentLatitude'] ?? 0.0;
      double longitude = donationDetails!['CurrentLongitude'] ?? 0.0;
      String url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> _fetchDonationDetails() async {
    try {
      DocumentSnapshot donationSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(widget.userId)
          .collection('userDonations')
          .doc(widget.donationId)
          .get();

      if (donationSnapshot.exists) {
        donationDetails = donationSnapshot.data() as Map<String, dynamic>;

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

        if (userSnapshot.exists) {
          userDetails = userSnapshot.data() as Map<String, dynamic>;
        }

        double latitude = donationDetails!['CurrentLatitude'] ?? 0.0;
        double longitude = donationDetails!['CurrentLongitude'] ?? 0.0;
        donationLocation = LatLng(latitude, longitude);
      }
    } catch (e) {
      print("Error fetching donation details: $e");
    }

    setState(() {});
  }

  Future<void> _pickImage() async {
    if (uploadedImages.length >= 4) return;
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploadedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _stopLocationSharing() async {
    await FirebaseFirestore.instance
        .collection('Donations')
        .doc(widget.userId)
        .collection('userDonations')
        .doc(widget.donationId)
        .update({
      'startLocShare': false,
      'status': 'Completed', // Adjust this based on your logic
    });

    _locationTimer?.cancel(); // Cancel the timer if it's running
    print("Location sharing stopped");
  }

  Future<void> _completeDonation() async {
    await FirebaseFirestore.instance
        .collection('Donations')
        .doc(widget.userId)
        .collection('userDonations')
        .doc(widget.donationId)
        .update({
      'startLocShare': false,
      'status': 'Completed',
    });

    _stopLocationSharing(); // Ensure the timer is stopped here

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EmployeeHomePage()),
    );
  }

  Future<void> _markDonationCollected() async {
    await FirebaseFirestore.instance
        .collection('Donations')
        .doc(widget.userId)
        .collection('userDonations')
        .doc(widget.donationId)
        .update({
      'FoodCollected': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Donation marked as collected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: donationDetails == null || userDetails == null
          ? Center(child: CircularProgressIndicator())
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
            _buildImageUploadSection(),
            SizedBox(height: 20),
            _buildActionButtons(),
            SizedBox(height: 20),
            _buildDonationCollectedButton(),
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
                Text("User   ID: ${widget.userId}"),
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
                  options: MapOptions(center: donationLocation ?? LatLng(0, 0), zoom:  13),
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

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Upload Images (Max 4)"),
        Wrap(
          spacing: 10,
          children: uploadedImages.map((file) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: uploadedImages.length < 4 ? _pickImage : null,
          child: Text("Upload Image "),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: uploadedImages.isNotEmpty ? Colors.orange : Colors.grey,
            ),
            onPressed: uploadedImages.isNotEmpty ? _completeDonation : null,
            child: Text("Complete Donation"),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _openGoogleMaps,
            child: Text("Open in Google Maps"),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationCollectedButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        onPressed: _markDonationCollected,
        child: Text("Donation Collected"),
      ),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}