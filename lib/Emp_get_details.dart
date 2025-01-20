import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EmpGetDetailsScreen extends StatefulWidget {
  const EmpGetDetailsScreen({super.key});

  @override
  State<EmpGetDetailsScreen> createState() => _EmpGetDetailsScreenState();
}

class _EmpGetDetailsScreenState extends State<EmpGetDetailsScreen> with WidgetsBindingObserver {
  String? gender;
  bool termsAccepted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dobController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  File? idProofFile;
  File? profilePhotoFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dobController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
      _deleteUserIfNotCompleted();
    }
  }

  Future<void> _deleteUserIfNotCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (userId != null &&
        firstNameController.text.isEmpty &&
        lastNameController.text.isEmpty &&
        phoneNumberController.text.isEmpty) {
      await FirebaseAuth.instance.currentUser?.delete();
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    }
  }

  Future<void> _pickFile(bool isProfilePhoto) async {
    final XFile? pickedFile = await _picker.pickImage(source: isProfilePhoto ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        if (isProfilePhoto) {
          profilePhotoFile = File(pickedFile.path);
        } else {
          idProofFile = File(pickedFile.path);
        }
      }
    });
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
                    focusNode: phoneFocusNode,
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
                      Expanded(
                        child: const Text(
                          "By checking the box you agree to our terms and conditions.",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: "Please select ID proof as you are Indian",
                    icon: Icons.file_upload_outlined,
                    controller: TextEditingController(),
                    readOnly: true,
                    onTap: () => _pickFile(false),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Please select upload by clicking image for profile photo",
                    icon: Icons.camera_alt_outlined,
                    controller: TextEditingController(),
                    readOnly: true,
                    onTap: () => _pickFile(true),
                  ),
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
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .set({
                                'firstName': firstNameController.text,
                                'lastName': lastNameController.text,
                                'dob': dobController.text,
                                'gender': gender,
                                'phoneNumber': phoneNumberController.text,
                                'idProof': idProofFile?.path,
                                'profilePhoto': profilePhotoFile?.path,
                              }, SetOptions(merge: true));

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomeScreen()),
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
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool readOnly;
  final void Function()? onTap;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.validator,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        focusNode: focusNode,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final void Function(String?) onChanged;

  const GenderSelector({
    super.key,
    this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gender",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Male',
              groupValue: selectedGender,
              onChanged: onChanged,
            ),
            const Text("Male"),
            Radio<String>(
              value: 'Female',
              groupValue: selectedGender,
              onChanged: onChanged,
            ),
            const Text("Female"),
            Radio<String>(
              value: 'Other',
              groupValue: selectedGender,
              onChanged: onChanged,
            ),
            const Text("Other"),
          ],
        ),
      ],
    );
  }
}
