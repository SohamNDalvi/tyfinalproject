import 'package:flutter/material.dart';

class AllUserDetails extends StatefulWidget {
  @override
  _AllUserDetailsState createState() => _AllUserDetailsState();
}

class _AllUserDetailsState extends State<AllUserDetails> {
  // Initial list of users
  List<Map<String, String>> users = [
    {
      'name': 'Soham Dalvi',
      'email': 'sohamdalvi12@gmail.com',
      'id': 'gdyhgujuioikjioijkjk',
      'avatar': 'SD',
    },
    // Add more users as needed
  ];

  // Initialize filteredUsers as the full list of users
  List<Map<String, String>> filteredUsers = [];

  // Controller for search input
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredUsers = users; // Initially, no filtering, show all users

    // Listen for changes in the search bar
    _searchController.addListener(() {
      filterUsers();
    });
  }

  // Filter users based on the search text
  void filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users
          .where((user) =>
      user['name']!.toLowerCase().contains(query) ||
          user['email']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Details',
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search user',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            SizedBox(height: 16),
            // Display filtered users
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  var user = filteredUsers[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.red,
                        child: Text(
                          user['avatar']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user['name']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['email']!,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            user['id']!,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          // BeOne Verified tag
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BeOne Verified',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
    home: AllUserDetails(),
    debugShowCheckedModeBanner: false,
  ));
}
