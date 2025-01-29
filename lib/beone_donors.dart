import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeOneDonors extends StatefulWidget {
  @override
  _BeOneDonorsState createState() => _BeOneDonorsState();
}

class _BeOneDonorsState extends State<BeOneDonors> {
  List<Map<String, dynamic>> donorsList = [];
  bool sortDescending = true; // Sort order: true = highest first, false = lowest first
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    print("initState called");
    fetchCompletedDonations();
  }

  Future<void> fetchCompletedDonations() async {
    List<Map<String, dynamic>> tempDonorsList = [];
    DateTime now = DateTime.now();
    String currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}"; // Format YYYY-MM

    // Get all user documents from 'Donations' collection
    QuerySnapshot donationsSnapshot = await FirebaseFirestore.instance.collection('Donations').get();

    for (var donationDoc in donationsSnapshot.docs) {
      String userId = donationDoc.id;

      // Fetch completed donations for the user in the current month
      QuerySnapshot userDonationsSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(userId)
          .collection('userDonations')
          .where('status', isEqualTo: 'Completed')
          .get();

      int totalServings = 0;
      int totalDonations = 0;
      String donorName = "Unknown";
      String city = "Unknown";

      for (var doc in userDonationsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        Timestamp? timestamp = data['createdAt'] as Timestamp?;
        if (timestamp != null) {
          DateTime donationDate = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
          String formattedDate = "${donationDate.year}-${donationDate.month.toString().padLeft(2, '0')}";

          if (formattedDate == currentMonth) { // Compare formatted date with current month
            totalServings += (data['NumberOfServing'] ?? 0) as int;
            totalDonations++;
          }
        }

        donorName = data['Name'] ?? donorName;
        city = data['City'] ?? city;
      }

      if (totalDonations > 0) {
        tempDonorsList.add({
          'Name': donorName,
          'TotalServings': totalServings,
          'TotalDonations': totalDonations,
          'City': city,
        });
      }
    }

    // Sort based on servings (highest first)
    tempDonorsList.sort((a, b) => sortDescending
        ? b['TotalServings'].compareTo(a['TotalServings'])
        : a['TotalServings'].compareTo(b['TotalServings']));

    setState(() {
      donorsList = tempDonorsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredList = donorsList
        .where((donor) => donor['Name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search donor by name...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            // Sorting Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sort by servings",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(sortDescending ? Icons.arrow_downward : Icons.arrow_upward),
                    onPressed: () {
                      setState(() {
                        sortDescending = !sortDescending;
                        donorsList.sort((a, b) => sortDescending
                            ? b['TotalServings'].compareTo(a['TotalServings'])
                            : a['TotalServings'].compareTo(b['TotalServings']));
                      });
                    },
                  ),
                ],
              ),
            ),

            // List of Donors
            Expanded(
              child: filteredList.isEmpty
                  ? Center(child: Text("No completed donations found"))
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  var donation = filteredList[index];
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
                                Text(
                                  donation['Name'],
                                  style: TextStyle(
                                    fontFamily: 'cerapro',
                                    fontSize: 13.2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  "For ${donation['TotalServings']} Hungry Ones",
                                  style: TextStyle(
                                    fontFamily: 'cerapro',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2C3E75),
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  "In ${donation['TotalDonations']} Donations",
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
