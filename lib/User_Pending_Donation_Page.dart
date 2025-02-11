import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPendingDonationPage extends StatefulWidget {
  final String userId;
  final String donationId;

  UserPendingDonationPage({required this.userId, required this.donationId});

  @override
  _UserPendingDonationPageState createState() => _UserPendingDonationPageState();
}

class _UserPendingDonationPageState extends State<UserPendingDonationPage> {
Map<String, dynamic>? donationDetails;

@override
void initState() {
  super.initState();
  _fetchDonationDetails();
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
      setState(() {
        donationDetails = doc.data() as Map<String, dynamic>?;
      });
    }
  } catch (e) {
    print("Error fetching donation details: $e");
  }
}

@override
Widget build(BuildContext context) {
  final LatLng donationLocation = LatLng(
    donationDetails?['CurrentLatitude'] ?? 19.0760,
    donationDetails?['CurrentLongitude'] ?? 72.8777,
  );

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
                    "SD",
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
                      Text(
                        donationDetails!['Name'] ?? 'Unknown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text("EMAIL ID: ${donationDetails!['Email'] ?? 'N/A'}"),
                      Text("Phone Number: ${donationDetails!['Phone'] ?? 'N/A'}"),
                      Text("User  ID: ${widget.userId}"),
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
            {"Donation Id": donationDetails!['DonationId'] ?? 'N/A'},
            {"Food Category": donationDetails!['FoodCategory'] ?? 'N/A'},
            {"Food Condition": donationDetails!['FoodCondition'] ?? 'N/A'},
            {"Food Type": donationDetails!['FoodType'] ?? 'N/A'},
            {"Ingredient Used": donationDetails!['IngredientUsed'] ?? 'N/A'},
            {"Number Of Serving": "${donationDetails!['NumberOfServing'] ?? 'N/A'} People"},
            {"Special Instructions": donationDetails!['SpecialInstruction'] ?? 'N/A'},
            {"Quantity": donationDetails!['Quantity'] ?? 'N/A'},
          ]),
          SizedBox(height: 20),

          // Pickup Information Section
          _buildSectionTitle("Pickup Information"),
          _buildInfoTable([
            {"Address": donationDetails!['Address'] ?? 'N/A'},
            {"Pickup Date": donationDetails!['PickUpDate'] ?? 'N/A'},
            {"Pickup Time Slot": donationDetails!['PickUpTimeSlot'] ?? 'N/A'},
            {"Status": donationDetails!['status'] ?? 'N/A'},
          ]),
          SizedBox(height: 20),

          // Map Section
          _buildSectionTitle("Donation Location"),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: FlutterMap(
              options: MapOptions(center: donationLocation, zoom: 13),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: donationLocation,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
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
Widget _buildInfoTable(List<Map<String, String>> data) {
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
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
        ),
        columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
        children: data
            .map((item) => TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          children: [
            // Key Column (Light Grey Background)
            Container(
              color: Colors.grey.shade100,
              padding: EdgeInsets.all(12),
              child: Text(
                item.keys.first,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Value Column (White Background)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(12),
              child: Text(item.values.first),
            ),
          ],
        ))
            .toList(),
      ),
    ),
  );
}
}