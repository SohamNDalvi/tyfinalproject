import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class MyDonationsPage extends StatefulWidget {
  @override
  _MyDonationsPageState createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  String userId = "";
  List<Donation> donations = [];

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

    List<Donation> donationsList = [];
    for (var doc in userDonationsSnapshot.docs) {
      var donationData = doc.data();
      // Wait for the donation to be fetched with user data
      Donation donation = await Donation.fromFirestore(doc.id, donationData);
      donationsList.add(donation);
    }

    setState(() {
      donations = donationsList;
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
      body: Stack(
        children: [
          donations.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0), // Add padding around the entire ListView
            child: ListView.builder(
              itemCount: donations.length,
              itemBuilder: (context, index) {
                var donation = donations[index];
                return DonationCard(
                  name: donation.name,
                  donationId: donation.donationId,
                  description: donation.description,
                  location: donation.city,
                  status: donation.status,
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigationBar(),
          ),
        ],
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

class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: 300.0, // Adjust width of the bottom navigation bar
      height: 70.0, // Adjust height to fit icons and labels
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Skin-colored rectangle behind icons and text
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 115,  // Width of the rectangle
              height: 70,  // Height of the rectangle (full height of the navigation bar)
              decoration: BoxDecoration(
                color: Color(0xFFFFF5E5),  // Skin color (light brown)
                borderRadius: BorderRadius.circular(15),  // Border radius of 15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Organic Store icon should not move
                buildBottomNavItem(Icons.store, "Organic Store", Colors.grey, () {}, iconTransform: false),
                // Home icon (navigate to HomeScreen)
                buildHomeNavItem(context),
                // My Donation icon should move and have fontWeight applied
                Padding(
                  padding: EdgeInsets.only(left: 4.5), // Adds 1px left padding to "My Donation"
                  child: buildBottomNavItem(Icons.favorite, "My Donation", Colors.orange, () {}, iconTransform: true, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavItem(IconData icon, String label, Color color, VoidCallback onTap, {bool iconTransform = false, FontWeight fontWeight = FontWeight.normal}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Apply translation only to the icon, based on iconTransform value
        Transform.translate(
          offset: iconTransform ? Offset(-2.6, -1.0) : Offset(-0.3, -1.0), // Apply -3px left translation if iconTransform is true, else no movement
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
          child: Transform.translate(
            offset: Offset(0, -5), // Keeps the label translation unchanged
            child: Text(
              label,
              style: TextStyle(
                fontFamily: "cerapro",
                fontSize: 10.0,
                color: color,
                fontWeight: fontWeight, // Apply fontWeight for My Donation only
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHomeNavItem(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.0), // Inner padding
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(-0.6, -0.8),
                child: IconButton(
                  icon: Icon(Icons.home, color: Colors.grey),
                  onPressed: () {
                    // Navigate to HomeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()), // Navigate to HomeScreen
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Transform.translate(
                  offset: Offset(-0.7, -5),
                  child: Text(
                    "Home",
                    style: TextStyle(
                      fontFamily: "cerapro",
                      fontSize: 10.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}