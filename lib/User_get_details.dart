import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserGetDetailsScreen extends StatefulWidget {
  const UserGetDetailsScreen({super.key});

  @override
  State<UserGetDetailsScreen> createState() => _UserGetDetailsScreenState();
}

class _UserGetDetailsScreenState extends State<UserGetDetailsScreen> with WidgetsBindingObserver {
String? gender;
bool termsAccepted = false;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

final TextEditingController dobController = TextEditingController();
final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final TextEditingController phoneNumberController = TextEditingController();
final FocusNode phoneFocusNode = FocusNode();

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
    await FirebaseAuth.instance.currentUser ?.delete();
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async => false,
    child: Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
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
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      DateTime today = DateTime.now();
                      int age = today.year - pickedDate.year;

                      if (pickedDate.month > today.month || (pickedDate.month == today.month && pickedDate.day > today.day)) {
                        age--; // Adjust age if birthday hasn't occurred yet this year
                      }

                      if (age < 14) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("You must be at least 14 years old.")),
                        );
                      } else {
                        dobController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (termsAccepted) {
                          if (gender == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select your gender.')),
                            );
                            return; // Exit the function if gender is not selected
                          }

                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String? userId = prefs.getString('uid');

                          if (userId != null) {
                            await FirebaseFirestore.instance.collection('users').doc(userId).set({
                              'firstName': firstNameController.text,
                              'lastName': lastNameController.text,
                              'dob': dobController.text,
                              'gender': gender,
                              'phoneNumber': phoneNumberController.text,
                              'userType': 'user', // Explicitly setting the userType to 'user'
                            }, SetOptions(merge: true));

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User  ID not found.')),
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

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.keyboardType,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final void Function(String?) onChanged;

  const GenderSelector({
    super.key,
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