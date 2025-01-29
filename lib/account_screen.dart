import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_login_page.dart';
import 'support_page.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

Future<void> _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('uid');  // Clear the stored user ID

  // Check if the user is signed in with Google
  final GoogleSignIn googleSignIn = GoogleSignIn();
  if (await googleSignIn.isSignedIn()) {
    // Sign out from Google
    await googleSignIn.signOut();
  }

  // Sign out from Firebase Authentication
  await FirebaseAuth.instance.signOut();

  // Navigate to the UserLoginPage
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => UserLoginPage()),  // Navigate to login screen
  );
}

class _AccountScreenState extends State<AccountScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String dob = '';
  String gender = '';

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore using the uid
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid'); // Fetch the user ID from SharedPreferences

    if (userId != null) {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'] ?? '';
          lastName = userDoc['lastName'] ?? '';
          email = userDoc['email'] ?? '';
          phoneNumber = userDoc['phoneNumber'] ?? '';
          dob = userDoc['dob'] ?? '';
          gender = userDoc['gender'] ?? '';

          // Set the controllers with fetched values for editing
          firstNameController.text = firstName;
          lastNameController.text = lastName;
          emailController.text = email;
          phoneNumberController.text = phoneNumber;
          dobController.text = dob;
          genderController.text = gender;
        });
      }
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');

    if (userId != null) {
      // Update Firestore only if any field is modified
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'firstName': firstNameController.text.isNotEmpty ? firstNameController.text : firstName,
        'lastName': lastNameController.text.isNotEmpty ? lastNameController.text : lastName,
        'email': emailController.text.isNotEmpty ? emailController.text : email,
        'phoneNumber': phoneNumberController.text.isNotEmpty ? phoneNumberController.text : phoneNumber,
        'dob': dobController.text.isNotEmpty ? dobController.text : dob,
        'gender': genderController.text.isNotEmpty ? genderController.text : gender,
      });

      // After update, fetch the latest data
      _fetchUserData();
      setState(() {
        isEditing = false; // Hide the Save button after updating
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Account",
          style: TextStyle(fontFamily: 'cerapro'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: Text(
                    "${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}",
                    style: const TextStyle(
                      fontFamily: 'cerapro',
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing; // Toggle editing mode
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isEditing
                    ? Expanded(
                  child: TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                    ),
                  ),
                )
                    : Text(
                  firstName.isNotEmpty ? firstName : "",
                  style: const TextStyle(
                    fontFamily: 'cerapro',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                  child: TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                    ),
                  ),
                )
                    : Text(
                  lastName.isNotEmpty ? lastName : "",
                  style: const TextStyle(
                    fontFamily: 'cerapro',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            isEditing
                ? TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email ID',
              ),
            )
                : Text(
              email.isNotEmpty ? "EMAIL ID: $email" : "",
              style: const TextStyle(
                fontFamily: 'cerapro',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 2.0),
            isEditing
                ? TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            )
                : Text(
              phoneNumber.isNotEmpty ? "Phone Number: $phoneNumber" : "",
              style: const TextStyle(
                fontFamily: 'cerapro',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4.0),
            isEditing
                ? TextField(
              controller: dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
              ),
            )
                : Text(
              dob.isNotEmpty ? "Date of Birth: $dob" : "",
              style: const TextStyle(
                fontFamily: 'cerapro',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 2.0),
            isEditing
                ? TextField(
              controller: genderController,
              decoration: const InputDecoration(
                labelText: 'Gender',
              ),
            )
                : Text(
              gender.isNotEmpty ? "Gender: $gender" : "",
              style: const TextStyle(
                fontFamily: 'cerapro',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16.0),
            if (isEditing) // Show Save button only in edit mode
              ElevatedButton(
                onPressed: _updateUserData,
                child: const Text('Save'),
              ),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(Icons.verified, color: Colors.amber),
                title: const Text(
                  "Be BeOne Verified",
                  style: TextStyle(
                    fontFamily: 'cerapro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "& build trust in community in few steps",
                  style: TextStyle(
                    fontFamily: 'cerapro',
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.card_giftcard, color: Colors.black),
                    title: const Text(
                      "Rewards",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.headset_mic, color: Colors.black),
                    title: const Text(
                      "24*7 Help & Support",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportPage()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.black),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _logout(context);  // Pass the context here
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
