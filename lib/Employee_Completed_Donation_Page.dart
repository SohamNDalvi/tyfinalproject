import 'package:flutter/material.dart';

class EmployeeCompletedDonations extends StatefulWidget {
  @override
  _EmployeeCompletedDonationsState createState() =>
      _EmployeeCompletedDonationsState();
}

class _EmployeeCompletedDonationsState extends State<EmployeeCompletedDonations> {
  // Sample data for users
  List<Map<String, String>> users = [
    {
      'name': 'Soham Dalvi',
      'email': 'sohamdalvi12@gmail.com',
      'donationId': 'gdyhgujuioikj',
    },
  ];

  // Variable to store search query
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Completed Donations',
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
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  if (searchQuery.isNotEmpty &&
                      !user['name']!.toLowerCase().contains(searchQuery)) {
                    return Container();
                  }
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // User Avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.red,
                            child: Text(
                              user['name']!
                                  .split(' ')
                                  .map((e) => e[0])
                                  .take(2)
                                  .join(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // User Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  user['email']!,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                                Text(
                                  'donation ID: ${user['donationId']}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                                SizedBox(height: 4),
                                // Completed Tag in Same Column
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.amber.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
      backgroundColor: Colors.white,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EmployeeCompletedDonations(),
    debugShowCheckedModeBanner: false,
  ));
}
