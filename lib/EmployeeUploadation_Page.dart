import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EmployeeUploadationPage extends StatefulWidget {
  @override
  _EmployeeUploadationPageState createState() => _EmployeeUploadationPageState();
}

class _EmployeeUploadationPageState extends State<EmployeeUploadationPage> {
  final LatLng donationLocation = LatLng(19.0760, 72.8777);
  List<File> uploadedImages = [];

  Future<void> _pickImage() async {
    if (uploadedImages.length >= 4) return;
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploadedImages.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            _buildSectionTitle("Donation Information"),
            _buildInfoTable([
              {"Donation ID": "gdyhgujujioikj"},
              {"Food Category": "Dinner"},
              {"Food Condition": "Fresh"},
              {"Food Type": "Veg"},
              {"Ingredient Used": "Dinner"},
              {"Number of Servings": "25 People"},
              {"Special Instructions": "Handle with care"},
              {"Quantity": "400g"}
            ]),
            _buildSectionTitle("Pickup Information"),
            _buildInfoTable([
              {"Address": "Sai Shraddha Phase 2, Hanuman Tekdi, Mumbai, Maharashtra, 400068"},
              {"Pickup Date": "2025-01-30"},
              {"Pickup Time Slot": "3:16 PM"},
              {"Status": "Pending"}
            ]),
            _buildMapSection(context),
            _buildImageUploadSection(),
            SizedBox(height: 20),
            _buildActionButtons(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text("Donation Details", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.red,
            child: Text("SD", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text("Soham Dalvi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("EMAIL: sohamdalvi12@gmail.com"),
                Text("Phone: +91 8591509629"),
                Text("User ID: gdyhgujujioikj"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoTable(List<Map<String, dynamic>> data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        padding: EdgeInsets.all(2),
        child: Table(
          border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300)),
          columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
          children: data.map((item) {
            return TableRow(
              children: [
                IntrinsicHeight(
                  child: Container(
                    color: Colors.grey.shade100,
                    padding: EdgeInsets.all(12),
                    alignment: Alignment.centerLeft,
                    child: Text(item.keys.first, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                IntrinsicHeight(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(12),
                    alignment: Alignment.centerLeft,
                    child: item.values.first is Widget ? item.values.first : Text(item.values.first),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return _buildInfoTable([
      {
        "Fetch location on Map": Column(
          children: [
            GestureDetector(
              onTap: () => _showMapDialog(context),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: FlutterMap(
                  options: MapOptions(center: donationLocation, zoom: 13),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
                    MarkerLayer(markers: [
                      Marker(
                        point: donationLocation,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () => _showMapDialog(context),
              child: Text(
                "Open Full Map View",
                style: TextStyle(fontSize: 13.5),
              ),
            ),
          ],
        ),
      }
    ]);
  }

  void _showMapDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(center: donationLocation, zoom: 13, minZoom: 5, interactiveFlags: InteractiveFlag.all),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: const ['a', 'b', 'c']),
                    MarkerLayer(markers: [
                      Marker(
                        point: donationLocation,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Upload Images (Max 4)"),
        Wrap(
          spacing: 10,
          children: uploadedImages.map((file) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: uploadedImages.length < 4 ? _pickImage : null,
          child: Text("Upload Image"),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: uploadedImages.isNotEmpty ? Colors.orange : Colors.grey,
        ),
        onPressed: uploadedImages.isNotEmpty ? () {} : null,
        child: Text("Complete Donation"),
      ),
    );
  }
}
