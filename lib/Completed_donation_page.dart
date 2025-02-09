import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CompletedDonationPage extends StatefulWidget {
  @override
  _CompletedDonationPageState createState() => _CompletedDonationPageState();
}

class _CompletedDonationPageState extends State<CompletedDonationPage> {
  int _currentIndex = 0; // Track active image

  final List<String> imagePaths = [
    "assets/images/sponsor_banner1.jpg",
    "assets/images/sponsor_banner2.png",
    "assets/images/sponsor_banner3.png",
    "assets/images/sponsor_banner4.png",
  ];

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
                          "Soham Dalvi",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("EMAIL ID: sohamdalvi12@gmail.com"),
                        Text("Phone Number: +91 8591509629"),
                        Text("User ID : gdyhgujujioikj"),
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
              {"Donation Id": "gdyhgujujioikj"},
              {"Food Category": "Dinner"},
              {"Food Condition": "Fresh"},
              {"Food Type": "Veg"},
              {"Ingredient Used": "Dinner"},
              {"Number Of Serving": "25 People"},
              {"Special Instructions": "Handle with care"},
              {"Quantity": "400g"},
            ]),
            SizedBox(height: 20),

            // Pickup Information Section
            _buildSectionTitle("Pickup Information"),
            _buildInfoTable([
              {"Address": "Sai Shraddha Phase 2, Hanuman Tekdi, Mumbai, Maharashtra, 400068"},
              {"Pickup Date": "2025-01-30"},
              {"Pickup Time Slot": "3:16 PM"},
              {"Status": "Completed"},
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
