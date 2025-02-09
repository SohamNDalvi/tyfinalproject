import 'package:flutter/material.dart';

class AdminDonationDetails extends StatefulWidget {
  @override
  _AdminDonationDetailsState createState() => _AdminDonationDetailsState();
}

class _AdminDonationDetailsState extends State<AdminDonationDetails> {
  String selectedSection = "Pending Donations";

  List<String> sections = [
    "Pending Donations",
    "Completed Donations",
    "Assigned Donations",
    "Rejected Donations",
  ];

  Map<String, List<Map<String, String>>> donationsBySection = {
    "Pending Donations": [
      {
        "name": "SOHAM NARSINHA DALVI",
        "details": "Feed 10 HungryOnes",
        "location": "Dahisar East",
        "date": "12/03/2024",
        "status": "Pending"
      },
    ],
    "Completed Donations": [
      {
        "name": "RAHUL SHARMA",
        "details": "Feed 10 HungryOnes",
        "location": "Borivali West",
        "date": "16/03/2024",
        "status": "Completed"
      },
    ],
    "Assigned Donations": [
      {
        "name": "PRIYA VERMA",
        "details": "Feed 15 HungryOnes",
        "location": "Andheri West",
        "date": "22/03/2024",
        "status": "Assigned"
      },
    ],
    "Rejected Donations": [
      {
        "name": "VIJAY PATIL",
        "details": "Feed 20 HungryOnes",
        "location": "Bandra West",
        "date": "18/03/2024",
        "status": "Rejected"
      },

    ],
  };

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredDonations = donationsBySection[selectedSection]!
        .where((donation) =>
        donation["name"]!.toLowerCase().contains(searchQuery.toLowerCase()))
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name",
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
                      filteredDonations[index]["name"]!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(filteredDonations[index]["details"]!),
                        Text(
                          "From ${filteredDonations[index]["location"]}",
                        ),
                        Text("Date: ${filteredDonations[index]["date"]}"),
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
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

void main() {
  runApp(MaterialApp(
    home: AdminDonationDetails(),
    debugShowCheckedModeBanner: false,
  ));
}
