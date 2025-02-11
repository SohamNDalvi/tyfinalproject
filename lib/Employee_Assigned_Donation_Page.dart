import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Employee_StartDonation_Page.dart'; // Import the EmployeeStartDonationPage

class EmployeeAssignedDonations extends StatefulWidget {
  @override
  _EmployeeAssignedDonationsState createState() =>
      _EmployeeAssignedDonationsState();
}

class _EmployeeAssignedDonationsState extends State<EmployeeAssignedDonations> {
  // List to store assigned donations
  List<Map<String, String>> assignedDonations = [];

  // Variable to store search query
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAssignedDonations();
  }

  Future<void> _fetchAssignedDonations() async {
    // Get the user ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeId = prefs.getString('uid'); // Fetch the user ID from SharedPreferences
    print("Employee ID: $employeeId");
    if (employeeId == null) {
      print("No employee ID found in SharedPreferences.");
      return;
    }

    // Fetch all user IDs from the Donations collection
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('Donations')
        .get();

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      String userId = userDoc.id; // Get the user ID
      print("Fetching donations for user: $userId");

      // Fetch donations filtered by employeeId and status
      QuerySnapshot donationSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(userId)
          .collection('userDonations')
          .where('assignedEmployeeId', isEqualTo: employeeId)
          .where('status', isEqualTo: 'Assigned') // Only fetch assigned donations
          .get();

      print("Number of assigned donations for user $userId: ${donationSnapshot.docs.length}");

      // Store assigned donations for the employee
      for (var doc in donationSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>; // Access the document data
        print("Donation Data: $data"); // Print the entire document data for debugging

        assignedDonations.add({
          'name': data['Name'] ?? 'Unknown', // Assuming the name is stored in the document
          'donationId': data['DonationId'] ?? 'Unknown',
          'userId': userId, // Store the userId for navigation
          'description': 'For ${data['NumberOfServing'] ?? 0} Hungry Ones', // Example description
          'location': data['City'] ?? 'Unknown', // Assuming the city is stored in the document
        });
      }
    }

    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assigned Donations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Employee',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            SizedBox(height: 16),
            // Filtered User Cards
            Expanded(
              child: ListView.builder(
                itemCount: assignedDonations.length,
                itemBuilder: (context, index) {
                  final donation = assignedDonations[index];
                  if (searchQuery.isNotEmpty &&
                      !donation['name']!.toLowerCase().contains(searchQuery)) {
                    return Container();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeStartDonationPage(
                            donationId: donation['donationId']!,
                            userId: donation['userId']!,
                          ),
                        ),
                      );
                    },
                    child: DonationCard(
                      name: donation['name']!,
                      donationId: donation['donationId']!,
                      description: donation['description']!,
                      location: donation['location']!,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class DonationCard extends StatelessWidget {
  final String name;
  final String donationId;
  final String description;
  final String location;

  const DonationCard({
    required this.name,
    required this.donationId,
    required this.description,
    required this.location,
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
      child: Center(
        child: Text(
          name.split(' ').map((e) => e[0]).take(2).join(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Donation ID: $donationId',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Location: $location',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          // Assigned Tag in Same Column
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Assigned',
              style: TextStyle(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EmployeeAssignedDonations(),
    debugShowCheckedModeBanner: false,
  ));
}