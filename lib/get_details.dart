import 'package:flutter/material.dart';

class GetDetailsScreen extends StatefulWidget {
  const GetDetailsScreen({super.key});

  @override
  State<GetDetailsScreen> createState() => _GetDetailsScreenState();
}

class _GetDetailsScreenState extends State<GetDetailsScreen> {
  String? gender; // Gender selection state
  bool termsAccepted = false; // Checkbox state
  TextEditingController dobController = TextEditingController(); // DOB field controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const SizedBox(height: 20.0),
            // Illustration
            Image.asset(
              'assets/login_illustration.png', // Replace with your illustration path
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20.0),
            // Title
            const Text(
              "get started",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'cerapro',
              ),
            ),
            const SizedBox(height: 8.0),
            // Subtitle
            const Text(
              "by creating an account.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontFamily: 'cerapro',
              ),
            ),
            const SizedBox(height: 20.0),
            // First Name
            const CustomTextField(
              hintText: "first name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 10.0),
            // Last Name
            const CustomTextField(
              hintText: "last name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 10.0),
            // Email ID
            const CustomTextField(
              hintText: "email id",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 10.0),
            // DOB with Date Picker
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus(); // Dismiss keyboard before showing date picker
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    dobController.text =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
              child: AbsorbPointer(
                child: CustomTextField(
                  hintText: "dob - dd/mm/yyyy",
                  icon: Icons.calendar_today_outlined,
                  controller: dobController,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // Gender Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "select your gender",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'cerapro',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: "male",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                        const Text(
                          "male",
                          style: TextStyle(fontFamily: 'cerapro'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: "female",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                        const Text(
                          "female",
                          style: TextStyle(fontFamily: 'cerapro'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: "other",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                        const Text(
                          "other",
                          style: TextStyle(fontFamily: 'cerapro'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Terms and Conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      termsAccepted = value!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "by checking the box you agree to our ",
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'cerapro',
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: "terms ",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: "and "),
                        TextSpan(
                          text: "conditions.",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (termsAccepted) {
                    print("next button pressed");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text("please accept the terms and conditions."),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "next  >",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cerapro',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: 'cerapro'),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
    );
  }
}
