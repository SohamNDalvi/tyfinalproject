import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CompletedDonationPage extends StatefulWidget {
  final String donationId; // Define the donationId parameter
  final String userId;
  CompletedDonationPage({required this.userId,required this.donationId}); // Constructor

  @override
  _CompletedDonationPageState createState() => _CompletedDonationPageState();
}

class _CompletedDonationPageState extends State<CompletedDonationPage> {
  int _currentIndex = 0; // Track active image
  Map<String, dynamic>? donationDetails;

  final List<String> imagePaths = [
    "assets/images/sponsor_banner1.jpg",
    "assets/images/sponsor_banner2.png",
    "assets/images/sponsor_banner3.png",
    "assets/images/sponsor_banner4.png",
  ];

  @override
  void initState() {
    super.initState();
    fetchDonationDetails();
  }

  Future<void> fetchDonationDetails() async {

    try {
      print("Printing , $this.donationId");
      DocumentSnapshot donationSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(widget.userId)
          .collection('userDonations')
          .doc(widget.donationId)
          .get();

      if (donationSnapshot.exists) {
        setState(() {
          donationDetails = donationSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        setState(() {
          donationDetails = {}; // Set empty map to prevent null errors
        });
      }
    } catch (e) {
      setState(() {
        donationDetails = {'error': 'Failed to fetch data'};
      });
      print("Error fetching donation details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (donationDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Donation Details"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
      body: SingleChildScrollView(
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
                          donationDetails!['Name'] ?? "Unknown",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("User  ID: ${donationDetails!['userID'] ?? 'N/A'}"),
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
              {"Number Of Serving": "${donationDetails!['NumberOfServing']} People"},
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

            // 🔹 Banner Image Carousel
            _buildSectionTitle("Donation Photos"),
            SizedBox(height: 10),
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 150, // Carousel Height
                    autoPlay: true, // Auto-scroll every 4 seconds
                    autoPlayInterval: Duration(seconds: 4),
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: imagePaths.map((imagePath) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
                    );
                  }).toList(),
                ),

                // 🔹 Dots Indicator Below Carousel
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imagePaths.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? Colors.blue : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),
              ],
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