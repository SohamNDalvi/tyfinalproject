import 'package:final_project/Employee_home_Page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class EmpGetDetailsScreen extends StatefulWidget {
  const EmpGetDetailsScreen({super.key});

  @override
  State<EmpGetDetailsScreen> createState() => _EmpGetDetailsScreenState();
}

class _EmpGetDetailsScreenState extends State<EmpGetDetailsScreen> {
  String? gender;
  bool termsAccepted = false;
  File? profileImage;
  String? documentPath;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dobController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker(); // Initialize image picker


  Future<void> _takeProfilePicture() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front, // Open front camera only
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx', 'jpg', 'png', 'jpeg']);
    if (result != null) {
      setState(() {
        documentPath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/Account_creation_illustration.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: "First Name",
                    icon: Icons.person_outline,
                    controller: firstNameController,
                    validator: (value) =>
                    value == null || value.trim().isEmpty ? "First name cannot be empty" : null,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Last Name",
                    icon: Icons.person_outline,
                    controller: lastNameController,
                    validator: (value) =>
                    value == null || value.trim().isEmpty ? "Last name cannot be empty" : null,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Phone Number",
                    icon: Icons.phone_android_outlined,
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Phone number cannot be empty";
                      } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return "Phone number must be 10 digits";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        dobController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                    child: AbsorbPointer(
                      child: CustomTextField(
                        hintText: "DOB - dd/mm/yyyy",
                        icon: Icons.calendar_today_outlined,
                        controller: dobController,
                        validator: (value) =>
                        value == null || value.trim().isEmpty ? "Date of Birth cannot be empty" : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GenderSelector(
                    selectedGender: gender,
                    onChanged: (value) => setState(() => gender = value),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: termsAccepted,
                        onChanged: (value) => setState(() => termsAccepted = value!),
                      ),
                      const Expanded(
                        child: Text(
                          "By checking the box you agree to our terms and conditions.",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _takeProfilePicture,
                    child: Text(profileImage == null ? "Take Profile Picture" : "Profile Picture Taken"),
                  ),
                  if (profileImage != null) ...[
                    const SizedBox(height: 10),
                    Image.file(profileImage!, height: 100, width: 100, fit: BoxFit.cover),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickDocument,
                    child: Text(documentPath == null ? "Upload Document" : "Document Uploaded"),
                  ),
                  if (documentPath != null) ...[
                    const SizedBox(height: 10),
                    Text("Document: $documentPath"),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (termsAccepted) {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String? userId = prefs.getString('uid');

                            if (userId != null) {
                              await FirebaseFirestore.instance.collection('users').doc(userId).set({
                                'firstName': firstNameController.text,
                                'lastName': lastNameController.text,
                                'dob': dobController.text,
                                'gender': gender,
                                'phoneNumber': phoneNumberController.text,
                              }, SetOptions(merge: true));

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => EmployeeHomePage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User ID not found.')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please accept the terms and conditions.')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("Next"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.hintText,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onChanged;

  const GenderSelector({
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select your gender",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RadioOption(value: "male", groupValue: selectedGender, label: "Male", onChanged: onChanged),
            RadioOption(value: "female", groupValue: selectedGender, label: "Female", onChanged: onChanged),
            RadioOption(value: "other", groupValue: selectedGender, label: "Other", onChanged: onChanged),
          ],
        ),
      ],
    );
  }

}

class RadioOption extends StatelessWidget {
  final String value;
  final String? groupValue;
  final String label;
  final void Function(String?) onChanged;

  const RadioOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(value: value, groupValue: groupValue, onChanged: onChanged),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}