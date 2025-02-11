import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class UserOngoingDonationPage extends StatefulWidget {
  final String userId;
  final String donationId;

  UserOngoingDonationPage({required this.userId, required this.donationId});

  @override
  _UserOngoingDonationPageState createState() => _UserOngoingDonationPageState();
}

class _UserOngoingDonationPageState extends State<UserOngoingDonationPage> {
Map<String, dynamic>? donationDetails;
LatLng? employeeLocation;
LatLng? userLocation;
bool showMap = false;
Timer? _locationTimer;

// Default employee location if fetching fails
final LatLng defaultEmployeeLocation = LatLng(19.0760, 72.8777); // Example: Mumbai

@override
void initState() {
  super.initState();
  _fetchDonationDetails();
  _startLocationUpdates();
}

Future<void> _fetchDonationDetails() async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Donations')
        .doc(widget.userId)
        .collection('userDonations')
        .doc(widget.donationId)
        .get();

    if (doc.exists) {
      donationDetails = doc.data() as Map<String, dynamic>;

      // Set user location with default values
      userLocation = LatLng(
        donationDetails?['CurrentLatitude'] ?? 19.0760,
        donationDetails?['CurrentLongitude'] ?? 72.8777,
      );

      // Fetch employee location
      String assignedEmployeeId = donationDetails?['assignedEmployeeId'] ?? '';
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(assignedEmployeeId)
          .get();

      if (employeeDoc.exists) {
        employeeLocation = LatLng(
          employeeDoc['empCurrentLatitude'] ?? 19.0760,
          employeeDoc['empCurrentLongitude'] ?? 72.8777,
        );
      } else {
        // If employee document does not exist, use default location
        employeeLocation = defaultEmployeeLocation;
      }
    }
  } catch (e) {
    print("Error fetching donation details: $e");
    // Use default location if there's an error
    employeeLocation = defaultEmployeeLocation;
  }

  setState(() {}); // Refresh the UI
}

void _startLocationUpdates() {
  _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
    await _updateEmployeeLocation();
  });
}

Future<void> _updateEmployeeLocation() async {
  // Fetch the employee's current location from Firestore
  String assignedEmployeeId = donationDetails?['assignedEmployeeId'] ?? '';
  DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(assignedEmployeeId)
      .get();

  if (employeeDoc.exists) {
    setState(() {
      employeeLocation = LatLng(
        employeeDoc['empCurrentLatitude'] ?? 19.0760,
        employeeDoc['empCurrentLongitude'] ?? 72.8777,
      );
    });
  } else {
    // If fetching fails, use default location
    setState(() {
      employeeLocation = defaultEmployeeLocation;
    });
  }
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
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Donation Details",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: false,
    ),
    body: donationDetails == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Card
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: Text(
                    donationDetails?['Name']?.substring(0, 2).toUpperCase() ?? 'U',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
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
                      Text(donationDetails?['Name'] ?? 'Unknown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("EMAIL: ${donationDetails?['Email'] ?? 'N/A'}"),
                      Text("Phone Number: ${donationDetails?['Phone'] ?? 'N/A'}"),
                      Text("User   ID: ${widget.userId}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Donation Information Section
          _buildSectionTitle("Donation Information"),
          _buildInfoTable([
            {"Donation Id": donationDetails?['DonationId'] ?? 'N/A'},
            {"Food Category": donationDetails?['FoodCategory'] ?? 'N/A'},
            {"Food Condition": donationDetails?['FoodCondition'] ?? 'N/A'},
            {"Food Type": donationDetails?['FoodType'] ?? 'N/A'},
            {"Ingredient Used": donationDetails?['IngredientUsed'] ?? 'N/A'},
            {"Number Of Serving": "${donationDetails?['NumberOfServing'] ?? 'N/A'} People"},
            {"Special Instructions": donationDetails?['SpecialInstruction'] ?? 'N/A'},
            {"Quantity": donationDetails?['Quantity'] ?? 'N/A'},
          ]),
          SizedBox(height: 20),

          // Pickup Information Section
          _buildSectionTitle("Pickup Information"),
          _buildInfoTable([
            {"Address": donationDetails?['Address'] ?? 'N/A'},
            {"Pickup Date": donationDetails?['PickUpDate'] ?? 'N/A'},
            {"Pickup Time Slot": donationDetails?['PickUpTimeSlot'] ?? 'N/A'},
            {"Status": donationDetails?['status'] ?? 'N/A'},
          ]),
          SizedBox(height: 20),

          // Track Donation Button
          if (donationDetails?['status'] == 'Ongoing' && donationDetails?['startLocShare'] == true)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showMap = true;
                });
              },
              child: Text("Track Your Donation"),
            ),
          SizedBox(height: 20),

          // Map Section
          if (showMap)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: FlutterMap(
                options: MapOptions(
                  center: userLocation ?? LatLng(19.0760, 72.8777),
                  zoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      if (userLocation != null)
                        Marker(
                          point: userLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      if (employeeLocation != null)
                        Marker(
                          point: employeeLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.bike_scooter_rounded, size: 40),
                        ),
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      if (userLocation != null && employeeLocation != null)
                        Polyline(
                          points: [userLocation!, employeeLocation!],
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

// Section Title
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

// Information Table with White Background for Values
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
}