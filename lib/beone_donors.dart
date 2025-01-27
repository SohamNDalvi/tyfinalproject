import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeOneDonors extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchCompletedDonations() async {
    List<Map<String, dynamic>> completedDonations = [];

    // Get all user documents from the 'Donations' collection
    QuerySnapshot donationsSnapshot =
    await FirebaseFirestore.instance.collection('Donations').get();
    print(" hhhh :$donationsSnapshot.docs");
  print(donationsSnapshot.docs.length);
    // Iterate over each user's document in 'Donations'
    for (var donationDoc in donationsSnapshot.docs) {
      String userId = donationDoc.id;
      print(donationDoc.data());
      // Access the 'UserDonations' subcollection for the current user
      QuerySnapshot userDonationsSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(userId)
          .collection('userDonations')
          .where('status', isEqualTo: 'Completed') // Filter by status
          .get();

      // Check if donations are found and print for debugging
      if (userDonationsSnapshot.docs.isNotEmpty) {
        print('User $userId has completed donations.');

        // Add each completed donation document to the list
        for (var userDonation in userDonationsSnapshot.docs) {
          completedDonations.add(userDonation.data() as Map<String, dynamic>);
        }
      } else {
        print('No completed donations for user $userId.');
      }
    }

    print('Completed Donations: $completedDonations');
    return completedDonations;
  }


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
            fontSize: 17,
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchCompletedDonations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error loading donations"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No completed donations found"));
            }

            final donations = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: donations.map((donation) {
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10.0),
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
                              color: Color(0xFF2C3E75),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          // Text details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 20.0, top: 16.0),
                                  child: Text(
                                    donation['Address'] ?? 'Unknown Address',
                                    style: TextStyle(
                                      fontFamily: 'cerapro',
                                      fontSize: 13.2,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  "${donation['NumberOfServing']} Servings",
                                  style: TextStyle(
                                    fontFamily: 'cerapro',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2C3E75),
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  "Category: ${donation['FoodCategory'] ?? 'Unknown'}",
                                  style: TextStyle(
                                    fontFamily: 'cerapro',
                                    fontSize: 10.0,
                                    color: Colors.grey.shade600,
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
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
