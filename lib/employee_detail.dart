import 'package:flutter/material.dart';

class EmployeeDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wraps the entire body in a scrollable view
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      'SD',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soham Dalvi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Employee ID\nHtryuyiuivnbngjhyuyooop',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mobile Number\n+91 8591509629',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Email ID\nsohamdalvi12@gmail.com',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Employee Documents',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Document list inside a scrollable widget
              ListView(
                shrinkWrap: true, // Ensures the ListView doesn't take up all available space
                physics: NeverScrollableScrollPhysics(), // Disables scrolling within ListView
                children: [
                  buildDocumentCard(),
                  SizedBox(height: 16),
                  buildDocumentCard(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDocumentCard() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Id Proof',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Image.asset(
            'assets/images/sponsor_banner1.jpg', // Updated to use the local asset
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: EmployeeDetailPage(),
));
