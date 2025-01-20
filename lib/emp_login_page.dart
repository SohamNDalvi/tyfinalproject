import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'otp_validation_screen.dart';
import 'user_login_page.dart';
import 'emp_signup_page.dart';

class EmpLoginPage extends StatefulWidget {
  const EmpLoginPage({Key? key}) : super(key: key);

  @override
  State<EmpLoginPage> createState() => _EmpLoginPageState();
}

class _EmpLoginPageState extends State<EmpLoginPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? errorMessage; // Holds the error message
  bool _obscurePassword = true;

  void validateEmail() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);

    setState(() {
      if (email.isEmpty || password.isEmpty) {
        errorMessage = "Email field cannot be empty.";
      } else if (!regex.hasMatch(email)) {
        errorMessage = "Sorry, this doesn't look like a valid email address.";
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
                          "Welcome Back To BeOne!",
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Ready to serve and share? Together, we deliver hope. Log in to continue.",
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
                          "Verify your Email Id and Password",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            // Navigate to EmpLoginPage when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UserLoginPage()),
                            );
                          },
                          child: const Text(
                            "Login/Register as an User? Click here",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'cerapro',
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
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

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(fontSize: 12, color: Colors.orange , fontFamily: 'cerapro',fontWeight:FontWeight.w600),
                            ),
                          ),
                        ),
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
                              MaterialPageRoute(builder: (context) => const EmpSignupPage()),
                            );
                          },
                          child: const Text(
                            "New to BeOne? Join now",
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
