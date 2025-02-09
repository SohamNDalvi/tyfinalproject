import 'package:flutter/material.dart';

class EmployeeHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hello, Soham Dalvi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'Manage your data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            // First Row with Two Cards
            Row(
              children: [
                Expanded(
                  child: _buildCard('Ongoing Donations', 'assets/images/sponsor_banner2.png'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildCard('Assigned Donations', 'assets/images/sponsor_banner2.png'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Second Row with One Large Card
            _buildCard('Completed Donations', 'assets/images/sponsor_banner2.png', height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String imagePath, {double height = 100}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EmployeeHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}
