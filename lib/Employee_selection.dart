import 'package:flutter/material.dart';

class EmployeeSelection extends StatefulWidget {
  @override
  _EmployeeSelectionState createState() => _EmployeeSelectionState();
}

class _EmployeeSelectionState extends State<EmployeeSelection> {
  int? _selectedEmployee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select employee'),
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red,
                          child: const Text(
                            'SD',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ramkrishna Sharma',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Employee ID – 123455',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Radio<int>(
                          value: 1,
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
                        'Assign donation schedule',
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
                      children: [
                        _buildTableRow('2/02/2025', [
                          '12pm ',
                          '03pm ',
                          '06pm ',
                        ]),
                        _buildTableRow('3/02/2025', [
                          '01pm',
                          '04pm',
                          '07pm',
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Handle assign button press
                },
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
