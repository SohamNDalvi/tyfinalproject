import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_home_page.dart';

class EmployeeSelection extends StatefulWidget {
  final String donationId; // Donation ID to fetch assigned donations
  final String userId; // User ID to fetch employee details

  EmployeeSelection({required this.userId, required this.donationId});

  @override
  _EmployeeSelectionState createState() => _EmployeeSelectionState();
}

class _EmployeeSelectionState extends State<EmployeeSelection> {
  int? _selectedEmployee;
  List<Map<String, dynamic>> _assignedDonations = [];
  List<Map<String, dynamic>> _employees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }
  Future<void> _assignDonation() async {
    if (_selectedEmployee != null) {
      String selectedEmployeeId = _employees[_selectedEmployee!]['id'];
      String donationId = widget.donationId;

      // Update the assignedEmployeeId and status in Firestore
      await FirebaseFirestore.instance
          .collection('Donations')
          .doc(widget.userId) // Parent document for the user
          .collection('userDonations')
          .doc(donationId) // Specific donation document
          .update({
        'assignedEmployeeId': selectedEmployeeId,
        'status': 'Assigned',
      });

      // Navigate to AdminHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminHomePage()),
      );
    }
  }
  Future<void> _fetchEmployees() async {
    // Fetch all employees
    QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('UserType', isEqualTo: 'employee')
        .get();

    // Store employee details
    _employees = employeeSnapshot.docs.map((doc) {
      print(doc.id);
      print(doc['firstName']);
      print(doc['lastName']);
      return {

        'id': doc.id,
        'firstName': doc['firstName'],
        'lastName': doc['lastName'],
      };
    }).toList();

    // Fetch assigned donations for each employee
    for (var employee in _employees) {
      await _fetchAssignedDonations(employee['id']);
    }

    setState(() {});
  }

  Future<void> _fetchAssignedDonations(String employeeId) async {
    // Get the current date
    DateTime now = DateTime.now();
    // Create a DateTime object for today
    DateTime todayDate = DateTime(now.year, now.month, now.day); // Current date without time
    print("todayDate = $todayDate");

    // Fetch all user IDs from the Donations collection
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('Donations')
        .get();

    for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
      String userId = userDoc.id; // Get the user ID

      // Fetch donations filtered by employeeId
      QuerySnapshot donationSnapshot = await FirebaseFirestore.instance
          .collection('Donations')
          .doc(userId)
          .collection('userDonations')
          .where('assignedEmployeeId', isEqualTo: employeeId)
          .get(); // Fetch all donations for the employee

      // Store assigned donations for the employee
      for (var doc in donationSnapshot.docs) {
        // Get the PickUpDate as a string
        String pickUpDateString = doc['PickUpDate']; // Assuming this is in YYYY-MM-DD format
        print(pickUpDateString);
        // Convert the PickUpDate string to a DateTime object
        DateTime pickUpDate;
        try {
          pickUpDate = DateTime.parse(pickUpDateString); // Parse the date string
        } catch (e) {
          print("Error parsing date: $pickUpDateString"); // Handle parsing error
          continue; // Skip this document if parsing fails
        }

        // Compare the dates
        if (pickUpDate.isAfter(todayDate) || pickUpDate.isAtSameMomentAs(todayDate)) {
          _assignedDonations.add({
            'employeeId': employeeId,
            'date': pickUpDateString, // Store the original string if needed
            'time': doc['PickUpTimeSlot'],
            'donationId': doc['DonationId'],
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Employee'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select an Employee',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final employee = _employees[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Text(
                                  employee['firstName'][0] + employee['lastName'][0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${employee['firstName']} ${employee['lastName']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Employee ID – ${employee['id']}', // Removed const
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<int>(
                                value: index,
                                groupValue: _selectedEmployee,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEmployee = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Assigned Donation Schedule',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            border: TableBorder.all(
                              color: Colors.grey,
                              width: 1.0,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            children: _assignedDonations
                                .where((donation) => donation['employeeId'] == employee['id'])
                                .map((donation) {
                              return _buildTableRow(donation['date'], [
                                donation['time'],
                              ]);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _assignDonation,
                child: const Text(
                  'ASSIGN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String date, List<String> times) {
    return TableRow(
      children: [
        Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: times
                .map(
                  (time) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}