import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appwrite/appwrite.dart';
import 'FullScreenImage.dart';

class EmpMyDocuments extends StatefulWidget {
  @override
  _EmpMyDocumentsState createState() => _EmpMyDocumentsState();
}

class _EmpMyDocumentsState extends State<EmpMyDocuments> {
  String? profilePicUrl;
  String? documentUrl;

  late Client client;
  late Storage storage;

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    _loadUserDocuments();
  }

  void _initializeAppwrite() {
    client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
        .setProject('beone10103'); // Your Appwrite project ID
    storage = Storage(client);
  }

  Future<void> _loadUserDocuments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');

    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      String? profilePicId = userDoc['profilepic'];
      String? documentId = userDoc['document'];

      if (profilePicId != null) {
        // Construct the URL for the profile picture
        profilePicUrl = 'https://cloud.appwrite.io/v1/storage/buckets/employees_profiles10103/files/$profilePicId/view?project=beone10103';
      }

      if (documentId != null) {
        // Construct the URL for the document
        documentUrl = 'https://cloud.appwrite.io/v1/storage/buckets/employees_documents10103/files/$documentId/view?project=beone10103';
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Documents",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Employee Documents",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              _documentCard(context, "Employee Photo", profilePicUrl),
              SizedBox(height: 30),
              _documentCard(context, "Employee Id Proof", documentUrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _documentCard(BuildContext context, String title, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (imageUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        imagePath: imageUrl,
                      ),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(child: Text("No Image Available")),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    print("Edit button pressed for $title");
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}