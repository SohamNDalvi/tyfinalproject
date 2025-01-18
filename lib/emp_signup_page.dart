import 'package:final_project/emp_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'otp_validation_screen.dart';
import 'user_login_page.dart';

class EmpSignupPage extends StatefulWidget {
  const EmpSignupPage({Key? key}) : super(key: key);

  @override
  State<EmpSignupPage> createState() => _EmpSignupPage();
}

class _EmpSignupPage extends State<EmpSignupPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? errorMessage; // Holds the error message
  bool _obscurePassword = true;

  void validateEmail() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim(); // Add confirm password field
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);

    setState(() {
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        errorMessage = "All fields are required.";
      } else if (!regex.hasMatch(email)) {
        errorMessage = "Sorry, this doesn't look like a valid email address.";
      } else if (password.length < 8) {
        errorMessage = "Password must be at least 8 characters long.";
      } else if (password != confirmPassword) {
        errorMessage = "Passwords do not match.";
      } else {
        errorMessage = null; // Clear the error if validation passes
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OTPValidationScreen()),
        );
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.light, // Light icons for dark background
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Section with Illustration and Skip Button
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4, // Dynamic height
                        child: Image.asset(
                          'assets/login_illustration.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Welcome To BeOne!",
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "We need compassionate individuals like you to bring change. Register now!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Email Input Section
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Create your account and start making a difference",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Error Message Section
                        if (errorMessage != null)
                          Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    fontFamily: 'cerapro',
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // TextField Section
                        TextField(
                          controller: emailController,
                          style: const TextStyle(fontFamily: 'cerapro', fontSize: 14),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email ID",
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword, // Control visibility based on the flag
                          style: const TextStyle(fontFamily: 'cerapro', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade600),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: _obscurePassword, // Control visibility
                          style: const TextStyle(fontFamily: 'cerapro', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade600),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: validateEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontFamily: 'cerapro',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: const [
                            Expanded(child: Divider(color: Colors.grey)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 7.0),
                              child: Text("OR", style: TextStyle(color: Colors.grey , fontSize: 10)),
                            ),
                            Expanded(child: Divider(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            // Navigate to UserLoginPage when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EmpLoginPage()),
                            );
                          },
                          child: const Text(
                            "Already on BeOne? Login now",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'cerapro',
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),
                        OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: SvgPicture.asset(
                            'assets/google_icon.svg',
                            width: 20,
                            height: 20,
                          ),
                          label: const Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontFamily: 'cerapro',
                              fontSize: 16,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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
