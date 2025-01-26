import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DonationForm(),
    );
  }
}

class DonationForm extends StatefulWidget {
  @override
  _DonationFormState createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();

  String _selectedCategory = 'Select';
  String _selectedFoodType = 'VEG';

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // Start from today
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Compare only the date portions (ignoring time)
      DateTime pickedDateWithoutTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      DateTime nowWithoutTime = DateTime(now.year, now.month, now.day);

      if (pickedDateWithoutTime.isAtSameMomentAs(nowWithoutTime) || pickedDateWithoutTime.isAfter(nowWithoutTime)) {
        return pickedDate; // Return valid date
      } else {
        // Show Snackbar if date is not valid
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Pickup date must be today or a future date.'),
        ));
        return null;
      }
    } else {
      return null; // Return null if no date is selected
    }
  }


  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Get current date and time
      DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      // Check if the selected time is within the night time range (12:00 AM - 6:00 AM)
      if (pickedTime.hour >= 0 && pickedTime.hour < 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Pickup time must be between 6:00 AM and 11:59 PM.'),
        ));
        return null;
      }

      // Check if the selected time is after the current time for today
      if (selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Pickup time must be after the current time.'),
        ));
        return null;
      }

      // Return valid time
      return pickedTime;
    }

    return null;
  }



  Future<bool> _isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    return uid != null;
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Required"),
          content: Text("You need to log in to proceed with the food Donation."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              style: TextButton.styleFrom(
                textStyle: TextStyle(fontSize: 14),
                foregroundColor: Colors.orange, // Set the text color to orange
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserLoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitDonation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid'); // Fetching userId from SharedPreferences
    double currentLatitude = prefs.getDouble('current_latitude') ?? 0.0;
    double currentLongitude = prefs.getDouble('current_longitude') ?? 0.0;

    if (userId == null) {
      // Handle case where userId is not available in SharedPreferences
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User is not logged in!'),
      ));
      return;
    }

    // Fetch the user's firstName and lastName from the users collection
    String fullName = '';
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User data not found!'),
        ));
        return;
      }

      String firstName = userDoc.data()?['firstName'] ?? '';
      String lastName = userDoc.data()?['lastName'] ?? '';
      fullName = '$firstName $lastName';
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch user data!'),
      ));
      return;
    }

    // Prepare the address string by concatenating the fields
    String man_address =
        '${_flatController.text} ${_areaController.text}, ${_cityController.text}, '
        '${_stateController.text}, ${_pincodeController.text}';

    // Generate a unique donation ID using the userId and the current date and time
    String donationId = '$userId-${DateTime.now().toIso8601String()}';

    // Create a donation data map
    Map<String, dynamic> donationData = {
      'userID': userId,
      'Name': fullName, // Add the combined name here
      'Address': man_address,
      'Pincode': _pincodeController.text,
      'City': _cityController.text,
      'State': _stateController.text,
      'CurrentLatitude': currentLatitude,
      'CurrentLongitude': currentLongitude,
      'PickUpDate': _dateController.text,
      'PickUpTimeSlot': _timeController.text,
      'FoodCategory': _categoryController.text,
      'SpecialInstruction':
      _instructionsController.text.isEmpty ? ' ' : _instructionsController.text,
      'NumberOfServing': _servingsController.text,
      'Quantity': _quantityController.text,
      'FoodCategory': _selectedCategory,
      'IngredientUsed': _ingredientsController.text,
      'FoodCondition': _conditionController.text.isEmpty ? ' ' : _conditionController.text,
      'FoodType': _selectedFoodType,
      'DonationId': donationId,
      'status': 'Pending', // Default status
      'createdAt': FieldValue.serverTimestamp(), // Timestamp for creation
    };

    try {
      // Add the donation data to Firestore under UserID -> UserDonations -> donationID
      await FirebaseFirestore.instance
          .collection('Donations')
          .doc(userId)
          .collection('UserDonations')
          .doc(donationId)
          .set(donationData);

      // Show success popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Donation Successful'),
          content: Text('Thank you for your donation!'),
          actions: [
            TextButton(
              onPressed: () {
                // Clean form details
                _flatController.clear();
                _areaController.clear();
                _cityController.clear();
                _stateController.clear();
                _pincodeController.clear();
                _dateController.clear();
                _timeController.clear();
                _categoryController.clear();
                _instructionsController.clear();
                _servingsController.clear();
                _quantityController.clear();
                _ingredientsController.clear();
                _conditionController.clear();

                // Navigate to HomeScreen
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeScreen()));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      // Show error popup
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Submission Failed'),
          content: Text('Some technical error occurred. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the popup and stay on the same page
                Navigator.of(context).pop();
              },
              child: Text('Resubmit'),
            ),
          ],
        ),
      );
    }
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
        SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Donation food details",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pickup details",
                  style: TextStyle(
                    fontFamily: "cerapro",
                    fontSize: 17,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.0),

                buildFieldWithExample(
                  label: "Enter pincode",
                  controller: _pincodeController,
                  example: "Example: 400001",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Pincode is required.";
                    }
                    if (value.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return "Pincode must be exactly 6 digits.";
                    }
                    return null;
                  },
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: buildFieldWithExample(
                        label: "City",
                        controller: _cityController,
                        example: "Example: Mumbai",
                        validator: (value) =>
                        value == null || value.isEmpty ? "City is required." : null,
                        onTap: () async {
                          bool isLoggedIn = await _isUserLoggedIn();
                          if (!isLoggedIn) {
                            _showLoginDialog(context);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: buildFieldWithExample(
                        label: "State",
                        controller: _stateController,
                        example: "Example: Maharashtra",
                        validator: (value) =>
                        value == null || value.isEmpty ? "State is required." : null,
                        onTap: () async {
                          bool isLoggedIn = await _isUserLoggedIn();
                          if (!isLoggedIn) {
                            _showLoginDialog(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                buildFieldWithExample(
                  label: "Area, street, sector",
                  controller: _areaController,
                  example: "Example: MG Road, Sector 7",
                  validator: (value) =>
                  value == null || value.isEmpty ? "Area is required." : null,
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    }
                  },
                ),
                buildFieldWithExample(
                  label: "Flat, housing no., building, apartment",
                  controller: _flatController,
                  example: "Example: Flat 101, ABC Apartments",
                  maxLines: 3,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Flat details are required." : null,
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    }
                  },
                ),
                buildFieldWithExample(
                  label: "Pickup date",
                  controller: _dateController,
                  example: "Select a date",
                  isReadOnly: true,
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    } else {
                      DateTime? selectedDate = await _selectDate(context); // Get selected date
                      if (selectedDate != null) {
                        setState(() {
                          _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                        });
                      }
                    }
                  },
                  suffixIcon: Icons.calendar_today,
                  validator: (value) => value == null || value.isEmpty
                      ? "Pickup date is required."
                      : null,
                ),
                buildFieldWithExample(
                  label: "Pickup time slot",
                  controller: _timeController,
                  example: "Example: 10:00 AM - 12:00 PM",
                  isReadOnly: true,
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    } else {
                      TimeOfDay? selectedTime = await _selectTime(context); // Get selected time
                      if (selectedTime != null) {
                        setState(() {
                          _timeController.text = selectedTime.format(context);
                        });
                      }
                    }
                  },
                  suffixIcon: Icons.access_time,
                  validator: (value) => value == null || value.isEmpty
                      ? "Pickup time is required."
                      : null,
                ),


                buildFieldWithExample(
                  label: "Special instructions (Optional)",
                  controller: _instructionsController,
                  example: "Example: Call before arrival",
                  maxLines: 3,
                ),
                SizedBox(height: 32.0),

                Text(
                  "Food details",
                  style: TextStyle(
                    fontFamily: "cerapro",
                    fontSize: 17,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15.0),

                buildFieldWithExample(
                  label: "Number of servings (Approx)",
                  controller: _servingsController,
                  example: "Example: 20",
                  validator: (value) =>
                  value == null || value.isEmpty ? "Number of servings is required." : null,
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    }
                  },
                ),
                buildFieldWithExample(
                  label: "Quantity (Approx)",
                  controller: _quantityController,
                  example: "Example: 5kg,200g",
                  validator: (value) =>
                  value == null || value.isEmpty ? "Quantity is required." : null,
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    }
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: <String>[
                        'Select',
                        'Breakfast',
                        'Lunch',
                        'Dinner',
                        'Snacks',
                        'Desserts',
                        'Beverages'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "Food Category",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty || value == "Select"? "Food Category selection required." : null,
                      onTap: () async {
                        bool isLoggedIn = await _isUserLoggedIn();
                        if (!isLoggedIn) {
                          _showLoginDialog(context);
                        }
                      },
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
                buildFieldWithExample(
                  label: "Ingredients used (Optional)",
                  controller: _ingredientsController,
                  example: "Example: Rice, Dal, Vegetables",
                  maxLines: 3,
                ),
                buildFieldWithExample(
                  label: "Food condition",
                  controller: _conditionController,
                  example: "Example: Fresh, 1-day old",
                  validator: (value) =>
                  value == null || value.isEmpty ? "Condition of food is required." : null,
                  onTap: () async {
                    bool isLoggedIn = await _isUserLoggedIn();
                    if (!isLoggedIn) {
                      _showLoginDialog(context);
                    }
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  "Food Type",
                  style: TextStyle(
                    fontFamily: "cerapro",
                    fontSize: 17,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text("VEG"),
                        value: "VEG",
                        groupValue: _selectedFoodType,
                        onChanged: (value) async {
                          if (await _isUserLoggedIn()) {
                            setState(() => _selectedFoodType = value!);
                          } else {
                            _showLoginDialog(context); // Show the login dialog if the user is not logged in
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text("NON-VEG"),
                        value: "NON-VEG",
                        groupValue: _selectedFoodType,
                        onChanged: (value) async {
                          if (await _isUserLoggedIn()) {
                            setState(() => _selectedFoodType = value!);
                          } else {
                            _showLoginDialog(context); // Show the login dialog if the user is not logged in
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool isLoggedIn = await _isUserLoggedIn();
                        if (!isLoggedIn) {
                          _showLoginDialog(context);
                        } else {
                          if (_formKey.currentState!.validate()) {
                            await _submitDonation();
                            print('Form submitted');
                          }
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
                          fontFamily: "cerapro",
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
