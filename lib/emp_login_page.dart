import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import 'forgot_password_page.dart';
import 'Emp_get_details.dart';
import 'user_signup_page.dart';
import 'user_login_page.dart';
import 'package:final_project/Employee_home_Page.dart';
import 'admin_home_page.dart'; // Import the AdminHomePage

class EmpLoginPage extends StatefulWidget {
  const EmpLoginPage({Key? key}) : super(key: key);

  @override
  State<EmpLoginPage> createState() => _EmpLoginPageState();
}

class _EmpLoginPageState extends State<EmpLoginPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? errorMessage; // Holds the error message
  bool _obscurePassword = true;

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser  = await _googleSignIn.signIn();
      if (googleUser  == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser .authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      String uid = userCredential.user!.uid;
      String? userEmail = userCredential.user!.email;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String userType = userDoc['UserType'];
        if (userType == 'employee') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('uid', uid);
          print("Saved UID: $uid");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeeHomePage()),
          );
        } else if (userType == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()), // Navigate to AdminHomePage
          );
        } else {
          setState(() {
            errorMessage = "Your email is registered as a User. Please log in with an Employee's email.";
          });
        }
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': userEmail,
          'UserType': 'employee',
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', uid);
        print("Saved UID for new user: $uid");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmpGetDetailsScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred. Please try again.";
      });
    }
  }

  Future<void> validateEmail() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Email and Password fields cannot be empty.";
      });
      return;
    }

    if (!regex.hasMatch(email)) {
      setState(() {
        errorMessage = "Sorry, this doesn't look like a valid email address.";
      });
      return;
    }

    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() {
          errorMessage = "Employee not found. Please check your credentials.";
        });
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        String uid = userCredential.user!.uid;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', uid);
        print("Saved UID: ${prefs.getString('uid')}");

        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          print("exist");
          String userType = userDoc['UserType'];
          if (userType == 'employee') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else if (userType == 'admin') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()), // Navigate to AdminHomePage
            );
          } else {
            setState(() {
              errorMessage =
              "Your email ID is registered as a User. Please log in with an Employee's email ID.";
            });
          }
        } else {
          setState(() {
            errorMessage = "Employee not found. Please check your credentials.";
          });
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = "An error occurred. Please try again.";

        if (e.code == 'invalid-credential') {
          DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userQuery.docs.first.id).get();

          String userType = userDoc['UserType'];
          if (userType == 'employee') {
            errorMsg =
            "Incorrect password. Please check your credentials or you are registered with Google SignIn. So try Google SignIn.";
          } else if (userType == 'admin') {
            errorMsg =
            "Incorrect password. Please check your credentials or you are registered with Google SignIn. So try Google SignIn.";
          } else {
            errorMsg =
            "Your email is registered as a User. Please log in using Employee's Email Id.";
          }
        } else {
          errorMsg = e.message ?? errorMsg;
          print("Firebase Error: ${e.code}");
        }

        setState(() {
          errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Image.asset(
                          'assets/login_illustration.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                          "Ready to serve and share? Together, We deliver hope. Log in to continue.",
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserLoginPage()),
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
                        TextField(
                          controller: emailController,
                          style: const TextStyle(fontFamily: 'cerapro', fontSize: 14),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email ID",
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Colors.grey.shade600),
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
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontFamily: 'cerapro', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock_outline_rounded,
                                color: Colors.grey.shade600),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontFamily: 'cerapro',
                                fontWeight: FontWeight.w600,
                              ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UserSignupPage()),
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
                          onPressed: (signInWithGoogle),
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