import 'package:flutter/material.dart';

class BeOneDonors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BeOne Donors",
          style: TextStyle(
            fontFamily: "cerapro",
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: List.generate(1, (index) {
              return Card(
                color: Colors.white, // Set the card background color to white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 20.0),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Square icon on the left
                      Container(
                        height: 90.0,
                        width: 90.0,
                        decoration: BoxDecoration(
                          color: Color(0xFF2C3E75), // Navy blue color
                          borderRadius: BorderRadius.circular(10), // Rounded square
                        ),
                      ),
                      SizedBox(width: 16.0),
                      // Text details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0, top: 16.0),
                              child: Text(
                                "SOHAM NARSINHA DALVI",
                                style: TextStyle(
                                  fontFamily: 'cerapro',
                                  fontSize: 13.2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700, // Text color for the name
                                ),
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              "Feed 10 HungryOnes",
                              style: TextStyle(
                                fontFamily: 'cerapro',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C3E75), // Dark blue color for emphasis
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              "In 5 Donations, from Dahisar East",
                              style: TextStyle(
                                fontFamily: 'cerapro',
                                fontSize: 10.0,
                                color: Colors.grey.shade600, // Subtle grey for less emphasis
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
