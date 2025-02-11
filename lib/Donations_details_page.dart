import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'completed_donation_page.dart'; // Import the CompletedDonationPage
import 'user_pending_donation_page.dart'; // Import the UserPendingDonationPage
import 'admin_donation_approve_page.dart'; // Import the PendingDonation Page

class AdminDonationDetails extends StatefulWidget {
  @override
  _AdminDonationDetailsState createState() => _AdminDonationDetailsState();
}

class _AdminDonationDetailsState extends State<AdminDonationDetails> {
  String selectedSection = "Pending Donations";
  String searchQuery = "";
  String sortBy = "Date"; // Default sorting criteria
  bool isAscending = false; // Default sorting order

  List<String> sections = [
    "Pending Donations",
    "Completed Donations",
    "Assigned Donations",
    "Rejected Donations",
    "Ongoing Donations", // New section added
  ];

  Map<String, List<Map<String, dynamic>>> donationsBySection = {
    "Pending Donations": [],
    "Completed Donations": [],
    "Assigned Donations": [],
    "Rejected Donations": [],
    "Ongoing Donations": [], // New section initialized
  };

  @override
  void initState() {
    super.initState();
    _fetchAllDonations();
  }

  _fetchAllDonations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Mapping from status to section names
    Map<String, String> statusToSection = {
      'Pending': 'Pending Donations',
      'Completed': 'Completed Donations',
      'Assigned': 'Assigned Donations',
      'Rejected': 'Rejected Donations',
      'Ongoing': 'Ongoing Donations', // New mapping for ongoing donations
    };

    try {
      final allUsersSnapshot = await firestore.collection('Donations').get();

      for (var userDoc in allUsersSnapshot.docs) {
        final userDonationsSnapshot = await userDoc.reference.collection('userDonations').get();

        for (var donationDoc in userDonationsSnapshot.docs) {
          var donationData = donationDoc.data();
          String status = donationData['status'] ?? 'Pending';

          // Use the mapping to get the correct section
          String section = statusToSection[status] ?? 'Pending Donations';

          // Ensure the list for the section is initialized
          if (donationsBySection[section] == null) {
            donationsBySection[section] = [];
          }

          // Add donation to the appropriate section based on its status
          donationsBySection[section]!.add({
            ...donationData,
            "userID": userDoc.id,
            "DonationId": donationDoc.id,
          });
        }
      }
    } catch (e) {
      print("Error fetching donations: $e");
    }

    // Sort donations by date when the page is loaded
    _sortDonations();
    setState(() {});
  }

  void _sortDonations() {
    for (var section in donationsBySection.keys) {
      donationsBySection[section]!.sort((a, b) {
        if (sortBy == "Date") {
          DateTime dateA = DateTime.parse(a["PickUpDate"] ?? DateTime.now().toString());
          DateTime dateB = DateTime.parse(b["PickUpDate"] ?? DateTime.now().toString());
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        } else {
          int servingsA = a["NumberOfServing"] ?? 0;
          int servingsB = b["NumberOfServing"] ?? 0;
          return isAscending ? servingsA.compareTo(servingsB) : servingsB.compareTo(servingsA);
        }
      });
    }
  }

  void _openSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            width: 400, // Set the desired width
            height: 250, // Set the desired height
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Sort Donations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16), // Space between title and content
                DropdownButton<String>(
                  value: sortBy,
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: "Date", child: Text("Sort by Date")),
                    DropdownMenuItem(value: "Servings", child: Text("Sort by Number of Servings")),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ascending"),
                    Radio(
                      value: true,
                      groupValue: isAscending,
                      onChanged: (value) {
                        setState(() {
                          isAscending = true;
                        });
                        Navigator.of(context).pop(); // Close the dialog after selection
                        _sortDonations(); // Sort donations immediately
                        _openSortDialog(); // Reopen the dialog to reflect the change
                      },
                    ),
                    Text("Descending"),
                    Radio(
                      value: false,
                      groupValue: isAscending,
                      onChanged: (value) {
                        setState(() {
                          isAscending = false;
                        });
                        Navigator.of(context).pop(); // Close the dialog after selection
                        _sortDonations(); // Sort donations immediately
                        _openSortDialog(); // Reopen the dialog to reflect the change
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20), // Space before the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _sortDonations(); // Sort donations when OK is pressed
                        Navigator.of(context).pop();
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredDonations = donationsBySection[selectedSection]!
        .where((donation) =>
    donation["Name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (donation["PickUpDate"]?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
        (donation["City"]?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
        (donation["NumberOfServing"]?.toString().contains(searchQuery) ?? false))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Donations Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _openSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name, date, city, or servings",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sections.map((section) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSection = section;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          section,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedSection == section
                                ? Color(0xFF09357F) // Persian Blue
                                : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4), // Space between text and line
                        if (selectedSection == section)
                          Container(
                            height: 2,
                            width: 150,
                            color: Color(0xFF09357F), // Persian Blue
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDonations.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      color: Colors.blue,
                    ),
                    title: Text(
                      filteredDonations[index]["Name"]!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(filteredDonations[index]["NumberOfServing"] != null
                            ? "Feed ${filteredDonations[index]["NumberOfServing"]} Hungry Ones"
                            : "No details available"),
                        Text(
                          "From ${filteredDonations[index]["City"] ?? "Unknown location"}",
                        ),
                        Text("Date: ${filteredDonations[index]["PickUpDate"] ?? "Unknown date"}"),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: filteredDonations[index]["status"] == "Pending"
                            ? Colors.orange.shade100
                            : filteredDonations[index]["status"] == "Completed"
                            ? Colors.green.shade100
                            : filteredDonations[index]["status"] == "Assigned"
                            ? Colors.blue.shade100
                            : filteredDonations[index]["status"] == "Ongoing"
                            ? Colors.yellow.shade100 // Color for ongoing donations
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        filteredDonations[index]["status"]!,
                        style: TextStyle(
                          color: filteredDonations[index]["status"] == "Pending"
                              ? Colors.orange
                              : filteredDonations[index]["status"] == "Completed"
                              ? Colors.green
                              : filteredDonations[index]["status"] == "Assigned"
                              ? Colors.blue
                              : filteredDonations[index]["status"] == "Ongoing"
                              ? Colors.yellow // Color for ongoing donations
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (filteredDonations[index]["status"] == 'Pending') {
                        var donationDetails = await FirebaseFirestore.instance
                            .collection('Donations')
                            .doc(filteredDonations[index]["userID"])
                            .collection('userDonations')
                            .doc(filteredDonations[index]["DonationId"])
                            .get();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PendingDonation(
                              donationData: donationDetails.data()!,
                              userId: filteredDonations[index]["userID"], // Pass userId
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPendingDonationPage(
                              userId: filteredDonations[index]["userID"],
                              donationId: filteredDonations[index]["DonationId"],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}