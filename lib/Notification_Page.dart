import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Sample notifications data
  List<Map<String, String>> notifications = [
    {
      "title": "New Donation Request",
      "body": "You have a new donation request from John Doe.",
      "time": "2 minutes ago"
    },
    {
      "title": "Donation Picked Up",
      "body": "Your donation has been picked up successfully.",
      "time": "1 hour ago"
    },
    {
      "title": "New Message",
      "body": "You received a message from the charity organization.",
      "time": "3 hours ago"
    },
    {
      "title": "Donation Reminder",
      "body": "Don't forget to donate this weekend!",
      "time": "Yesterday"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.black), // Change text color to orange
        ),
        backgroundColor: Colors.white, // Change background color to white
        elevation: 0, // Remove shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build a notification card
  Widget _buildNotificationCard(Map<String, String> notification) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 4),
            Text(
              notification['body']!,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Text(
              notification['time']!,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NotificationPage(),
  ));
}