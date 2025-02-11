import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'completed_donation_page.dart';


// Import the CompletedDonationPage
class DonationCardToAll extends StatefulWidget {
  final String userId;
  DonationCardToAll({required this.userId});

  @override
  _DonationCardToAllState createState() => _DonationCardToAllState();
}

class _DonationCardToAllState extends State<DonationCardToAll> {
  bool isCurrentMonthSelected = true; // Track which donation list is selected
  String searchQuery = ""; // Search query for filtering donations
  List<Map<String, dynamic>> currentMonthDonations = [];
  List<Map<String, dynamic>> previousDonations = [];

  @override
  void initState() {
    super.initState();
    fetchUserDonations();
  }

  Future<void> fetchUserDonations() async {
    DateTime now = DateTime.now();
    String currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}"; // Format YYYY-MM

    try {
      QuerySnapshot userDonationsSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(widget.userId)
          .collection('userDonations')
          .where('status', isEqualTo: 'Completed')
          .get();

      for (var doc in userDonationsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          String? pickUpDate = data['PickUpDate'] as String?;
          if (pickUpDate != null) {
            String formattedDate = pickUpDate.substring(0, 7); // Extract YYYY-MM
            if (formattedDate == currentMonth) {
              currentMonthDonations.add(data);
            } else {
              previousDonations.add(data);
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      print("Error fetching user donations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter donations based on the selected month and search query
    List<Map<String, dynamic>> filteredDonations = (isCurrentMonthSelected
        ? currentMonthDonations
        : previousDonations)
        .where((donation) =>
        donation["Name"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Search TextField
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search Donor",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // Update search query
                  });
                },
              ),
            ),
            // Toggle between Current Month and Previous Donations
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isCurrentMonthSelected = true; // Select current month
                      });
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Current Month Donations",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrentMonthSelected
                                  ? Color(0xFF1C39BB)
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        if (isCurrentMonthSelected)
                          Container(
                            height: 2,
                            color: Color(0xFF1C39BB),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isCurrentMonthSelected = false; // Select previous donations
                      });
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Previous Donations",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !isCurrentMonthSelected
                                  ? Color(0xFF1C39BB)
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        if (!isCurrentMonthSelected)
                          Container(
                            height: 2,
                            color: Color(0xFF1C39BB),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // List of filtered donations
            Expanded(
              child: filteredDonations.isEmpty
                  ? Center(child: Text("No donations found"))
                  : ListView.builder(
                itemCount: filteredDonations.length,
                itemBuilder: (context, index) {
                  var donation = filteredDonations[index];
                  return GestureDetector(
                    onTap: () {
                      print("Donation ID: ${donation['DonationId']}");
                      // Navigate to CompletedDonationPage with donation details
                      Navigator.push(
                        context,
                        MaterialPageRoute(

                          builder: (context) => CompletedDonationPage(userId: widget.userId,donationId:donation['DonationId'] // Ensure this matches Firestore field name
                          ),
                        ),
                      );
                    },
                    child: Card(
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
                            Container(
                              height: 90.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                color: Color(0xFF2C3E75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donation['Name']!,
                                    style: TextStyle(
                                      fontFamily: 'cerapro',
                                      fontSize: 13.2,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "For ${donation['NumberOfServing']} Hungry Ones",
                                    style: TextStyle(
                                      fontFamily: 'cerapro',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2C3E75),
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "Date: ${donation['PickUpDate'] ?? 'N/A'}", // Use null-aware operator
                                    style: TextStyle(
                                      fontFamily: 'cerapro',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "In 1 Donations",
                                    style: TextStyle(
                                      fontFamily: 'cerapro',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "From ${donation['City']}",
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}