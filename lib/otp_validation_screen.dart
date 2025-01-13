import 'package:flutter/material.dart';
import 'get_details.dart';

class OTPValidationScreen extends StatefulWidget {
  const OTPValidationScreen({super.key});

  @override
  _OTPValidationScreenState createState() => _OTPValidationScreenState();
}

class _OTPValidationScreenState extends State<OTPValidationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure the body adjusts when the keyboard opens
      body: SingleChildScrollView(  // Wrap content in a scrollable view
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Illustration - Full width, no padding for the image
            Image.asset(
              'assets/images/validate_illustration.png',
              width: MediaQuery.of(context).size.width, // Full width
              fit: BoxFit.cover, // Ensure it covers the full width
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding for the content except image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24.0),
                  // Title
                  const Text(
                    "Almost there",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'cerapro',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Subtitle
                  const Text(
                    "Please enter the 6-digit code sent to your Phone Number for verification.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'cerapro',
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 40,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'cerapro',
                          ),
                          onChanged: (value) {
                            // Automatically move to next field when a value is entered
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                            }
                            // Move to previous field if the user clears the field
                            else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                            }
                          },
                          decoration: InputDecoration(
                            counterText: "", // Remove the character counter
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Colors.black12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24.0),
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GetDetailsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'cerapro',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Resend Code
                  const Text(
                    "Resend Again",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'cerapro',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "Didn’t receive any code?",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'cerapro',
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    "Request new code in 00:30s",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'cerapro',
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Back Button at the Bottom Left
            const SizedBox(height: 60.0),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.keyboard_backspace, // `<` like back icon
                      color: Colors.white,
                    ),
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
