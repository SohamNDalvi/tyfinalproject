import 'package:flutter/material.dart';

class AllEmployeeDetails extends StatefulWidget {
  @override
  _AllEmployeeDetailsState createState() => _AllEmployeeDetailsState();
}

class _AllEmployeeDetailsState extends State<AllEmployeeDetails> {
  bool isApprovedSelected = true;
  List<Map<String, String>> approvedEmployees = [
    {"name": "Soham Dalvi", "email": "sohamdalvi12@gmail.com"},
    // Add more approved employees here
  ];

  List<Map<String, String>> pendingEmployees = [
    {"name": "Pending Employee", "email": "pending@example.com"},
    // Add more pending employees here
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredEmployees = isApprovedSelected
        ? approvedEmployees
        .where((employee) =>
        employee["name"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList()
        : pendingEmployees
        .where((employee) =>
        employee["name"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Employee",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isApprovedSelected = true;
                    });
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Approved Employees",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isApprovedSelected
                                ? Color(0xFF1C39BB)
                                : Colors.black54,
                          ),
                        ),
                      ),
                      if (isApprovedSelected)
                        Container(
                          height: 2,
                          color: Color(0xFF1C39BB),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isApprovedSelected = false;
                    });
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Pending Employees",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !isApprovedSelected
                                ? Color(0xFF1C39BB)
                                : Colors.black54,
                          ),
                        ),
                      ),
                      if (!isApprovedSelected)
                        Container(
                          height: 2,
                          color: Color(0xFF1C39BB),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(filteredEmployees[index]["name"]![0]),
                    ),
                    title: Text(filteredEmployees[index]["name"]!),
                    subtitle: Text(filteredEmployees[index]["email"]!),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AllEmployeeDetails(),
    debugShowCheckedModeBanner: false,
  ));
}
