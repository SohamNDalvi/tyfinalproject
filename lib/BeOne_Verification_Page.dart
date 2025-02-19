import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BeOneVerificationForm extends StatefulWidget {
  @override
  _BeOneVerificationFormState createState() => _BeOneVerificationFormState();
}

class _BeOneVerificationFormState extends State<BeOneVerificationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerContactNumberController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _previousCertificationsController = TextEditingController();
  final TextEditingController _numberOfEmployeesController = TextEditingController();
  final TextEditingController _averageDailyCustomersController = TextEditingController();
  final TextEditingController _wasteManagementPracticesController = TextEditingController();
  final TextEditingController _cleaningPracticesController = TextEditingController();
  final TextEditingController _preferredDateController = TextEditingController();
  final TextEditingController _preferredTimeController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  String _selectedBusinessType = 'Select';
  String _otherBusinessType = '';

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    return pickedDate;
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    return pickedTime;
  }

  Future<void> _submitVerification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User  is not logged in!'),
      ));
      return;
    }

    // Reference to user's document in the Donations collection
    DocumentReference userDoc = FirebaseFirestore.instance.collection('B1Verifications').doc(userId);

    // Fetch all verification documents for the user from the subcollection
    QuerySnapshot verificationSnapshot = await userDoc.collection('userVerifications').get();

    bool canSubmit = true; // Flag to track if submission is allowed

    if (verificationSnapshot.docs.isNotEmpty) {
      for (var doc in verificationSnapshot.docs) {
        // Safely cast the data to Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>

        if (data != null) {
          String status = data['Status'] ?? ''; // Default empty if not present

          if (status != 'Rejected') {
            canSubmit = false; // If any verification is not rejected, set flag to false
            break; // Stop checking further
          }
        }
      }
    }

    if (!canSubmit) {
      // Show popup if the user is not eligible for a second verification
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: Text("Verification In Progress"),
              content: Text("You are not eligible for a second verification. Please wait for the current verification to complete."),
              actions: [
              TextButton(
              onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text("OK"),
              ),
          ],
          );
        },
      );
      return; // Exit the method
    }

    // Create a verification data map
    Map<String, dynamic> verificationData = {
      'userID': userId,
      'businessName': _businessNameController.text,
      'businessType': _selectedBusinessType == 'Other' ? _otherBusinessType : _selectedBusinessType,
      'businessAddress': _businessAddressController.text,
      'contactNumber': _contactNumberController.text,
      'ownerName': _ownerNameController.text,
      'ownerContactNumber': _ownerContactNumberController.text,
      'ownerEmail': _ownerEmailController.text,
      'reasonForVerification': _reasonController.text,
      'previousCertifications': _previousCertificationsController.text,
      'numberOfEmployees': int.tryParse(_numberOfEmployeesController.text) ?? 0,
      'averageDailyCustomers': int.tryParse(_averageDailyCustomersController.text) ?? 0,
      'wasteManagementPractices': _wasteManagementPracticesController.text,
      'cleaningPractices': _cleaningPracticesController.text,
      'preferredDate': _preferredDateController.text,
      'preferredTime': _preferredTimeController.text,
      'comments': _commentsController.text,
      'createdAt': FieldValue.serverTimestamp(),
      'Status': 'Pending', // Add the Status field
      'IsAllocateB1': false, // Initialize IsAllocateB1 as false
    };

    try {
      // Save verification data to Firestore
      await userDoc.set({
        'createdAt': FieldValue.serverTimestamp(), // Timestamp when the document was created
      }, SetOptions(merge: true)); // Merge to avoid overwriting if the document already exists

      // Add data to the subcollection 'userVerifications', using a unique document ID
      await userDoc.collection('userVerifications').add(verificationData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verification request submitted successfully!'),
      ));
      // Clear form fields
      _clearFormFields();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit verification request. Please try again.'),
      ));
    }
  }

  void _clearFormFields() {
    _businessNameController.clear();
    _businessAddressController.clear();
    _contactNumberController.clear();
    _ownerNameController.clear();
    _ownerContactNumberController.clear();
    _ownerEmailController.clear();
    _reasonController.clear();
    _previousCertificationsController.clear();
    _numberOfEmployeesController.clear();
    _averageDailyCustomersController.clear();
    _wasteManagementPracticesController.clear();
    _cleaningPracticesController.clear();
    _preferredDateController.clear();
    _preferredTimeController.clear();
    _commentsController.clear();
    setState(() {
      _selectedBusinessType = 'Select';
      _otherBusinessType = '';
    });
  }

  Widget buildFieldWithExample({
    required String label,
    required TextEditingController controller,
    required String example,
    bool isReadOnly = false,
    Function()? onTap,
    IconData? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          ),
        ),
        SizedBox(height: 4.0),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            example,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BeOne Verification Form"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Business Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15.0),
                buildFieldWithExample(
                  label: "Business Name",
                  controller: _businessNameController,
                  example: "Example: ABC Restaurant",
                  validator: (value) => value!.isEmpty ? "Business name is required." : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedBusinessType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBusinessType = newValue!;
                      if (_selectedBusinessType == 'Other') {
                        _otherBusinessType = ''; // Reset other business type
                      }
                    });
                  },
                  items: <String>[
                    'Select',
                    'Restaurant',
                    'Hotel',
                    'Guest House',
                    'Food Stall',
                    'Catering Service',
                    'Other'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: "Business Type"),
                  validator: (value) => value == null || value == 'Select' ? "Business type is required." : null,
                ),
                if (_selectedBusinessType == 'Other') // Show text field for other business type
                  buildFieldWithExample(
                    label: "Please specify",
                    controller: _businessTypeController,
                    example: "Example: Food Truck",
                    validator: (value) => value!.isEmpty ? "Please specify the business type." : null,
                  ),
                SizedBox(height: 30.0),
                buildFieldWithExample(
                  label: "Business Address",
                  controller: _businessAddressController,
                  example: "Example: 123 Main St, City",
                  validator: (value) => value!.isEmpty ? "Business address is required." : null,
                ),
                buildFieldWithExample(
                  label: "Contact Number",
                  controller: _contactNumberController,
                  example: "Example: +1 234 567 890",
                  validator: (value) => value!.isEmpty ? "Contact number is required." : null,
                ),
                SizedBox(height: 20.0),
                // Owner/Manager Information
                Text("Owner/Manager Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15.0),
                buildFieldWithExample(
                  label: "Owner/Manager Name",
                  controller: _ownerNameController,
                  example: "Example: John Doe",
                  validator: (value) => value!.isEmpty ? "Owner/Manager name is required." : null,
                ),
                buildFieldWithExample(
                  label: "Owner/Manager Contact Number",
                  controller: _ownerContactNumberController,
                  example: "Example: +1 234 567 890",
                  validator: (value) => value!.isEmpty ? "Owner/Manager contact number is required." : null,
                ),
                buildFieldWithExample(
                  label: "Owner/Manager Email",
                  controller: _ownerEmailController,
                  example: "Example: johndoe@example.com",
                  validator: (value) => value!.isEmpty ? "Owner/Manager email is required." : null,
                ),
                SizedBox(height: 20.0),
                // Verification Details
                Text("Verification Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15.0),
                buildFieldWithExample(
                  label: "Reason for Verification",
                  controller: _reasonController,
                  example: "Example: To reduce food waste",
                  validator: (value) => value!.isEmpty ? "Reason for verification is required." : null,
                ),
                buildFieldWithExample(
                  label: "Previous Certifications (if any)",
                  controller: _previousCertificationsController,
                  example: "Example: Food Safety Certification",
                ),
                SizedBox(height: 20.0),
                // Operational Details
                Text("Operational Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15.0),
                buildFieldWithExample(
                  label: "Number of Employees",
                  controller: _numberOfEmployeesController,
                  example: "Example: 10",
                  validator: (value) => value!.isEmpty ? "Number of employees is required." : null,
                ),
                buildFieldWithExample(
                  label: "Average Daily Customers",
                  controller: _averageDailyCustomersController,
                  example: "Example: 50",
                  validator: (value) => value!.isEmpty ? "Average daily customers is required." : null,
                ),
                buildFieldWithExample(
                  label: "Waste Management Practices",
                  controller: _wasteManagementPracticesController,
                  example: "Example: Composting, Donation",
                ),
                buildFieldWithExample(
                  label: "Cleaning Practices",
                  controller: _cleaningPracticesController,
                  example: "Example: Daily cleaning, Sanitization",
                ),
                SizedBox(height: 20.0),
                // Schedule Preferences
                Text("Schedule Preferences", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15.0),
                buildFieldWithExample(
                  label: "Preferred Date",
                  controller: _preferredDateController,
                  example: "Select a date",
                  isReadOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await _selectDate(context);
                    if (selectedDate != null) {
                      setState(() {
                        _preferredDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                ),
                buildFieldWithExample(
                  label: "Preferred Time",
                  controller: _preferredTimeController,
                  example: "Select a time",
                  isReadOnly: true,
                  onTap: () async {
                    TimeOfDay? selectedTime = await _selectTime(context);
                    if (selectedTime != null) {
                      setState(() {
                        _preferredTimeController.text = selectedTime.format(context);
                      });
                    }
                  },
                ),

                SizedBox(height: 20.0),
                // Additional Information
                Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 15.0),
                buildFieldWithExample(
                  label: "Comments or Questions",
                  controller: _commentsController,
                  example: "Any additional information",
                  maxLines: 3,
                ),

                // Submit Button
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitVerification();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}