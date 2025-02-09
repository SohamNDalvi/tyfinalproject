import 'package:flutter/material.dart';
import 'user_login_page.dart';  // Make sure this path is correct

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  _AdminAccountScreenState createState() => _AdminAccountScreenState();
}

Future<void> _logout(BuildContext context) async {
  // Simply navigate to the UserLoginPage (without Firebase/SharedPreferences)
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => UserLoginPage()),  // Navigate to login screen
  );
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  String firstName = 'John';
  String lastName = 'Doe';
  String email = 'johndoe@example.com';
  String phoneNumber = '123-456-7890';
  String dob = '01/01/2000';
  String gender = 'Male';

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
    // Prepopulate fields for display (removes Firebase fetch)
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    emailController.text = email;
    phoneNumberController.text = phoneNumber;
    dobController.text = dob;
    genderController.text = gender;
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
                onPressed: () {
                  setState(() {
                    // Simply save edited data (for UI purpose, no database functionality)
                    firstName = firstNameController.text;
                    lastName = lastNameController.text;
                    email = emailController.text;
                    phoneNumber = phoneNumberController.text;
                    dob = dobController.text;
                    gender = genderController.text;
                    isEditing = false;
                  });
                },
                child: const Text('Save'),
              ),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.black),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    fontFamily: 'cerapro',
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _logout(context);  // Navigate to login screen on logout
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminAccountScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
