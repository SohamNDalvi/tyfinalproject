import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'otp_validation_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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
                        height: 380, // Fixed height for illustration
                        child: Image.asset(
                          'assets/login_illustration.png', // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 40, // Adjust for the status bar padding
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to HomeScreen when "Skip" button is pressed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            },
                            splashColor: Colors.grey.withOpacity(0.2),
                            highlightColor: Colors.grey.withOpacity(0.1),
                            customBorder: CircleBorder(),
                            child: SvgPicture.asset(
                              'assets/skip_button.svg', // Make sure this is the correct path for the SVG file
                              width: 85,
                              height: 55,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Welcome Text Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome To BeOne!",
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Login/Register now and be part of a community dedicated to ending hunger",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 12,
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phone Number Input Section
                  Container(
                    padding: EdgeInsets.all(20.0),
                    height: 393,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
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
                        Text(
                          "Verify your Email Address",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Enter your Email ID to proceed",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'cerapro',
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                style: TextStyle(fontFamily: 'cerapro', fontSize: 14),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: "Email ID",
                                  suffixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade600),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            // Handle login/register as employee action
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 65.0),
                            child: Text(
                              "Login/Register as an employee?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'cerapro',
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the OTPValidationScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OTPValidationScreen()),
                            );
                          },
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
