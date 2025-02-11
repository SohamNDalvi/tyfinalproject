import 'package:final_project/User_Ongoing_Donation_Page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'completed_donation_page.dart'; // Import the CompletedDonationPage
import 'user_pending_donation_page.dart'; // Import the UserPendingDonationPage
import 'package:final_project/User_Ongoing_Donation_Page.dart';

class MyDonationsPage extends StatefulWidget {
  @override
  _MyDonationsPageState createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  String userId = "";
  String searchQuery = "";
  String selectedSection = "Pending Donation"; // Default selected section
  Map<String, List<Donation>> donationsByStatus = {
    "Pending Donation": [],
    "Completed Donation": [],
    "Assigned Donation": [],
    "Rejected Donation": [],
    "Ongoing Donation": [], // Added Ongoing section
  };

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Fetch userId from SharedPreferences
  _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('uid') ?? '';
    });
    if (userId.isNotEmpty) {
      _fetchDonations();
    }
  }

  // Fetch donations from Firestore for the given userId
  _fetchDonations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userDonationsSnapshot = await firestore
        .collection('Donations')
        .doc(userId)
        .collection('userDonations')
        .get();

    Map<String, List<Donation>> donationsMap = {
      "Pending Donation": [],
      "Completed Donation": [],
      "Assigned Donation": [],
      "Rejected Donation": [],
      "Ongoing Donation": [], // Added Ongoing section
    };

    for (var doc in userDonationsSnapshot.docs) {
      var donationData = doc.data();
      Donation donation = await Donation.fromFirestore(doc.id, donationData);
      donationsMap[donation.status + " Donation"]?.add(donation);
    }

    setState(() {
      donationsByStatus = donationsMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Donations",
          style: TextStyle(
            fontFamily: "cerapro",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search by name or ID",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: donationsByStatus.keys.map((status) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSection = status;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selectedSection == status
                                  ? Color(0xFF09357F) // Persian Blue
                                  : Colors.black54,
                            ),
                          ),
                          SizedBox(height: 4), // Space between text and line
                          if (selectedSection == status)
                            Container(
                              height: 2,
                              width: 150,
                              color: Color(0xFF09357F), // Persian Blue
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: donationsByStatus[selectedSection]!
                    .where((donation) =>
                donation.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    donation.donationId.toLowerCase().contains(searchQuery.toLowerCase()))
                    .map((donation) {
                  return GestureDetector(
                    onTap: () {
                      // Check the status of the donation
                      if (donation.status == 'Completed') {
                        // Navigate to CompletedDonationPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompletedDonationPage(
                              userId: userId,
                              donationId: donation.donationId,
                            ),
                          ),
                        );
                      } else if (donation.status == 'Ongoing') {
                        // Navigate to CompletedDonationPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserOngoingDonationPage(
                              userId: userId,
                              donationId: donation.donationId,
                            ),
                          ),
                        );
                      }else {
                        // Navigate to UserPendingDonationPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPendingDonationPage(
                              userId: userId,
                              donationId: donation.donationId,
                            ),
                          ),
                        );
                      }
                    },
                    child: DonationCard(
                      name: donation.name,
                      donationId: donation.donationId,
                      description: donation.description,
                      location: donation.city,
                      status: donation.status,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationCard extends StatelessWidget {
  final String name;
  final String donationId;
  final String description;
  final String location;
  final String status;

  const DonationCard({
    required this.name,
    required this.donationId,
    required this.description,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color borderColor;

    // Set color based on status
    if (status == 'Pending') {
      statusColor = Colors.orange;
      borderColor = Colors.orange[100]!;
    } else if (status == 'Approved') {
      statusColor = Colors.green;
      borderColor = Colors.green[100]!;
    } else {
      statusColor = Colors.grey;
      borderColor = Colors.grey[100]!;
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            buildIconBox(),
            SizedBox(width: 16),
            buildCardContent(statusColor, borderColor),
          ],
        ),
      ),
    );
  }

  Widget buildIconBox() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget buildCardContent(Color statusColor, Color borderColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13.2,
              fontWeight: FontWeight.w600,
              fontFamily: "cerapro",
            ),
          ),
          SizedBox(height: 4),
          Text(
            donationId,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontFamily: "cerapro",
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontFamily: "cerapro",
            ),
          ),
          SizedBox(height: 4),
          Text(
            location,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontFamily: "cerapro",
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: statusColor,
                width: 1.0,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
                fontFamily: "cerapro",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Donation {
  final String name;
  final String donationId;
  final String description;
  final String city;
  final String status;

  Donation({
    required this.name,
    required this.donationId,
    required this.description,
    required this.city,
    required this.status,
  });

  // Convert Firestore data to Donation object
  static Future<Donation> fromFirestore(String donationId, Map<String, dynamic> data) async {
    String userId = data['userID'];
    String description = 'For ${data['NumberOfServing']} Hungry Ones';
    String city = 'From ${data['City']} ' ?? '';
    String status = data['status'] ?? 'Pending';

    // Fetch user name from Users collection
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String firstName = userDoc['firstName'] ?? 'Unknown';
    String lastName = userDoc['lastName'] ?? 'Unknown';
    String name = '$firstName $lastName';

    return Donation(
      name: name,
      donationId: donationId,
      description: description,
      city: city,
      status: status,
    );
  }
}