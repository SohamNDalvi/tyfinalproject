import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyDonationsPage(),
    );
  }
}

class MyDonationsPage extends StatelessWidget {
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
          buildBody(),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DonationCard(
              name: "SOHAM NARSINHA DALVI",
              description: "Feed 10 HungryOnes",
              location: "Dahisar East",
              donations: 5,
              status: "COMPLETED",
            ),
            // Add more cards here if needed
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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

class DonationCard extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  final int donations;
  final String status;

  const DonationCard({
    required this.name,
    required this.description,
    required this.location,
    required this.donations,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
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
            buildCardContent(),
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

  Widget buildCardContent() {
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
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontFamily: "cerapro",
            ),
          ),
          SizedBox(height: 4),
          Text(
            "In $donations Donations, from $location",
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
              color: Color.fromARGB(230, 246, 233, 233),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.green,
                width: 1.0,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.green,
                fontFamily: "cerapro",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
