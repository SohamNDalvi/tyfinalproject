import 'package:flutter/material.dart';

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

  String _selectedCategory = 'Breakfast';
  String _selectedFoodType = 'VEG';

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  Widget buildFieldWithExample({
    required String label,
    required TextEditingController controller,
    required String example,
    bool isReadOnly = false,
    Function()? onTap,
    IconData? suffixIcon,
    int maxLines = 1, // Added maxLines parameter for multiline support
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          maxLines: maxLines, // Handle multiline input
          decoration: InputDecoration(
            labelText: label, // Always show label text for floating behavior
             // You can set a default hint text if needed
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Adjust padding for proper alignment
            floatingLabelBehavior: FloatingLabelBehavior.auto, // Make label float when focused
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          ),
        ),
        SizedBox(height: 4.0),
        Align(
          alignment: Alignment.centerLeft, // Ensure the example text is aligned to the start
          child: Text(
            example, // This text is displayed outside the text field
            style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: "cerapro"),
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
        title: Text("Donation food details", style: TextStyle(fontFamily: "cerapro",fontSize: 17,fontWeight: FontWeight.bold)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pickup details", style: TextStyle(fontFamily: "cerapro", fontWeight: FontWeight.bold, fontSize: 18 ,color: Colors.grey.shade800,)),
              SizedBox(height: 8.0),

              buildFieldWithExample(
                label: "Enter pincode",
                controller: _pincodeController,
                example: "Example: 400001",
              ),
              Row(
                children: [
                  Expanded(
                    child: buildFieldWithExample(
                      label: "City",
                      controller: _cityController,
                      example: "Example: Mumbai",
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: buildFieldWithExample(
                      label: "State",
                      controller: _stateController,
                      example: "Example: Maharashtra",
                    ),
                  ),
                ],
              ),
              buildFieldWithExample(
                label: "Area, street, sector",
                controller: _areaController,
                example: "Example: MG Road, Sector 7",
              ),
              buildFieldWithExample(
                label: "Flat, housing no., building, apartment",
                controller: _flatController,
                example: "Example: Flat 101, ABC Apartments",
                maxLines: 3, // TextArea
              ),
              buildFieldWithExample(
                label: "Pickup date",
                controller: _dateController,
                example: "Select a date",
                isReadOnly: true,
                onTap: () => _selectDate(context),
                suffixIcon: Icons.calendar_today,
              ),
              buildFieldWithExample(
                label: "Pickup time slot",
                controller: _timeController,
                example: "Example: 10:00 AM - 12:00 PM",
                isReadOnly: true,
                onTap: () => _selectTime(context),
                suffixIcon: Icons.access_time,
              ),
              buildFieldWithExample(
                label: "Special instructions (Optional)",
                controller: _instructionsController,
                example: "Example: Call before arrival",
                maxLines: 3, // TextArea
              ),
              SizedBox(height: 32.0),

              Text("Food details", style: TextStyle(fontFamily: "cerapro", fontWeight: FontWeight.bold, fontSize: 18 ,color: Colors.grey.shade800)),
              SizedBox(height: 8.0),

              buildFieldWithExample(
                label: "Number of servings (Approx)",
                controller: _servingsController,
                example: "Example: 20",
              ),
              buildFieldWithExample(
                label: "Quantity (Optional)",
                controller: _quantityController,
                example: "Example: 5kg",
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0.0), // Space between the text and dropdown
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0), // Left padding for dropdown
                    child: Container(
                      width: double.infinity, // Ensures the dropdown button takes full width like the text field
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400, // Set the border color to match the text field
                        ),
                        borderRadius: BorderRadius.circular(8.0), // Matching border radius
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true, // Ensures the dropdown width matches the container width
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        items: <String>['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Desserts', 'Beverages']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 18.0), // Left padding for text inside dropdown
                              child: Text(value,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w400,// Set the text color to grey.800
                              ),
                            ),
                          ),
                          );
                        }).toList(),
                        underline: SizedBox(), // Hides the underline
                      ),
                    ),
                  ),
                  SizedBox(height: 6.0),
                  Text(
                    "Food Category",
                    style: TextStyle(
                      fontSize: 12, // Set the font size as needed
                       // Make it bold if needed
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              buildFieldWithExample(
                label: "Ingredients used (Optional)",
                controller: _ingredientsController,
                example: "Example: Rice, Dal, Vegetables",
                maxLines: 3, // TextArea
              ),

              buildFieldWithExample(
                label: "Food condition",
                controller: _conditionController,
                example: "Example: Fresh, 1-day old",
              ),

              // Radio buttons for VEG and NON-VEG
              SizedBox(height: 16.0),
              Text("Food Type", style: TextStyle(fontFamily: "cerapro", fontWeight: FontWeight.bold, fontSize: 18 ,color: Colors.grey.shade800)),
              Row(
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'VEG',
                        groupValue: _selectedFoodType,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedFoodType = value!;
                          });
                        },
                      ),
                      Text("VEG"),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'NON-VEG',
                        groupValue: _selectedFoodType,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedFoodType = value!;
                          });
                        },
                      ),
                      Text("NON-VEG"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32.0),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle form submission logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text("SUBMIT", style: TextStyle(fontFamily: "cerapro", fontSize: 16, color: Colors.white , fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
