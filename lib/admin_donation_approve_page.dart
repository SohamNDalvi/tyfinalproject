import 'package:final_project/Donations_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Employee_selection.dart';
import 'Donations_details_page.dart';

class PendingDonation extends StatefulWidget {
  final Map<String, dynamic> donationData;
  final String userId; // Add userId parameter to fetch user details

  PendingDonation({required this.donationData, required this.userId});

  @override
  _PendingDonationState createState() => _PendingDonationState();
}

class _PendingDonationState extends State<PendingDonation> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String dob = '';
  String gender = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(widget.userId);
  }

  Future<void> _fetchUserDetails(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        firstName = userDoc['firstName'] ?? '';
        lastName = userDoc['lastName'] ?? '';
        dob = userDoc['dob'] ?? '';
        gender = userDoc['gender'] ?? '';
        email = userDoc['email'] ?? '';
        phoneNumber = userDoc['phoneNumber'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng donationLocation = LatLng(
      widget.donationData['CurrentLatitude'] ?? 19.0760,
      widget.donationData['CurrentLongitude'] ?? 72.8777,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            _buildSectionTitle("Donation Information"),
            _buildInfoTable([
              {"Donation ID": widget.donationData['DonationId']},
              {"Food Category": widget.donationData['FoodCategory']},
              {"Food Condition": widget.donationData['FoodCondition']},
              {"Food Type": widget.donationData['FoodType']},
              {"Ingredient Used": widget.donationData['IngredientUsed']},
              {"Number of Servings": "${widget.donationData['NumberOfServing']} People"},
              {"Special Instructions": widget.donationData['SpecialInstruction']},
              {"Quantity": widget.donationData['Quantity']}
            ]),
            _buildSectionTitle("Pickup Information"),
            _buildInfoTable([
              {"Address": widget.donationData['Address']},
              {"Pickup Date": widget.donationData['PickUpDate']},
              {"Pickup Time Slot": widget.donationData['PickUpTimeSlot']},
              {"Status": widget.donationData['status']}
            ]),
            _buildMapSection(context, donationLocation),
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
            child: Text("SD", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                Text("${firstName} ${lastName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("EMAIL: ${email.isNotEmpty ? email : 'N/A'}"),
                Text("Phone: ${phoneNumber.isNotEmpty ? phoneNumber : 'N/A'}"),
                Text("User  ID: ${widget.donationData['userID']}"),
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

  Widget _buildMapSection(BuildContext context, LatLng donationLocation) {
    return _buildInfoTable([
      {
        "Fetch location on Map": Column(
          children: [
            GestureDetector(
              onTap: () => _showMapDialog(context, donationLocation),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: FlutterMap(
                  options: MapOptions(center: donationLocation, zoom: 13),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
                    MarkerLayer(markers: [
                      Marker(
                        point: donationLocation,
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
              onPressed: () => _showMapDialog(context, donationLocation),
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

  void _showMapDialog(BuildContext context, LatLng donationLocation) {
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
                  options: MapOptions(center: donationLocation, zoom: 13, minZoom: 5, interactiveFlags: InteractiveFlag.all),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
                    MarkerLayer(markers: [
                      Marker(
                        point: donationLocation,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () async {
            // Update the status to "Rejected"
            await FirebaseFirestore.instance
                .collection('Donations')
                .doc(widget.userId) // Parent document for the user
                .collection('userDonations')
                .doc(widget.donationData['DonationId']) // Specific donation document
                .update({
              'status': 'Rejected',
            });
            // Optionally, show a message or navigate back
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDonationDetails()),
            );
          },
          child: Text("REJECT", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {
            // Navigate to EmployeeSelection page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmployeeSelection(
              userId: widget.userId,
              donationId: widget.donationData['DonationId'],
            ),),
            );
          },
          child: Text("ACCEPT", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}


