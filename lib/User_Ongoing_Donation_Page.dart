import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class UserOngoingDonationPage extends StatefulWidget {
  final String userId;
  final String donationId;

  UserOngoingDonationPage({required this.userId, required this.donationId});

  @override
  _UserOngoingDonationPageState createState() => _UserOngoingDonationPageState();
}

class _UserOngoingDonationPageState extends State<UserOngoingDonationPage> {
Map<String, dynamic>? donationDetails;
LatLng? employeeLocation;
LatLng? userLocation;
bool showMap = false;
Timer? _locationTimer;
List<List<LatLng>> allRoutes = [];
List<LatLng> selectedRoute = [];
bool isLoadingRoute = false;
String? routeError;

final LatLng defaultEmployeeLocation = LatLng(19.0760, 72.8777); // Mumbai
final LatLng defaultUserLocation = LatLng(18.5204, 73.8567); // Pune

@override
void initState() {
super.initState();
print("Initializing UserOngoingDonationPage...");
_startListeningToDonationDetails();
}

void _startListeningToDonationDetails() {
FirebaseFirestore.instance
    .collection('Donations')
    .doc(widget.userId)
    .collection('userDonations')
    .doc(widget.donationId)
    .snapshots()
    .listen((doc) {
if (doc.exists) {
print("Donation document updated: ${doc.id}");
donationDetails = doc.data() as Map<String, dynamic>;

if (donationDetails?['status'] == 'Ongoing') {
userLocation = LatLng(
donationDetails?['CurrentLatitude'] ?? defaultUserLocation.latitude,
donationDetails?['CurrentLongitude'] ?? defaultUserLocation.longitude,
);
print("User  location set to: $userLocation");

String assignedEmployeeId = donationDetails?['assignedEmployeeId'] ?? '';
print("Fetching employee location for ID: $assignedEmployeeId");
_fetchEmployeeLocation(assignedEmployeeId);
_startLocationUpdates();
} else {
print("Donation status is not ongoing. Stopping location updates.");
_stopLocationUpdates();
Navigator.pop(context);
}
} else {
print("No donation document found for user ID: ${widget.userId} and donation ID: ${widget.donationId}");
}
});
}

Future<void> _fetchEmployeeLocation(String assignedEmployeeId) async {
DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(assignedEmployeeId)
    .get();

employeeLocation = employeeDoc.exists
? LatLng(
employeeDoc['empCurrentLatitude'] ?? defaultEmployeeLocation.latitude,
employeeDoc['empCurrentLongitude'] ?? defaultEmployeeLocation.longitude,
)
    : defaultEmployeeLocation;

print("Employee location set to: $employeeLocation");
setState(() {});
}

void _startLocationUpdates() {
if (_locationTimer == null) {
_locationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
print("Updating employee location...");
await _updateEmployeeLocation();
});
}
}

void _stopLocationUpdates() {
if (_locationTimer != null) {
_locationTimer?.cancel();
_locationTimer = null;
print("Location updates stopped.");
}
}

Future<void> _updateEmployeeLocation() async {
String assignedEmployeeId = donationDetails?['assignedEmployeeId'] ?? '';
print("Fetching updated employee location for ID: $assignedEmployeeId");
DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(assignedEmployeeId)
    .get();

if (employeeDoc.exists) {
if (mounted) {
setState(() {
employeeLocation = LatLng(
employeeDoc['empCurrentLatitude'] ?? defaultEmployeeLocation.latitude,
employeeDoc['empCurrentLongitude'] ?? defaultEmployeeLocation.longitude,
);
});
print("Updated employee location: $employeeLocation");
}
} else {
if (mounted) {
setState(() {
employeeLocation = defaultEmployeeLocation;
});
print("Employee document not found. Using default location: $defaultEmployeeLocation");
}
}
}

Future<void> _handleTrackDonation() async {
if (userLocation == null || employeeLocation == null) return;

setState(() {
isLoadingRoute = true;
routeError = null;
});

try {
print("Fetching routes from user to employee location...");
allRoutes = await _fetchRoutes(userLocation!, employeeLocation!);
if (allRoutes.isNotEmpty) {
selectedRoute = allRoutes[0]; // Select the first route
print("Selected route: $selectedRoute");
}

if (mounted) {
setState(() {
showMap = true;
});
}
} catch (e) {
if (mounted) {
setState(() => routeError = e.toString());
print("Error fetching route: $routeError");
}
} finally {
if (mounted) {
setState(() => isLoadingRoute = false);
}
}
}

Future<List<List<LatLng>>> _fetchRoutes(LatLng start, LatLng end) async {
const baseUrl = 'http://router.project-osrm.org/route/v1/driving';
final url = '$baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline';

print("Fetching routes from $start to $end...");
try {
final response = await http.get(Uri.parse(url));
print("Received response with status code: ${response.statusCode}");
if (response.statusCode == 200) {
final data = json.decode(response.body);
print("Response data: $data");

if (data['routes'] == null || data['routes'].isEmpty) {
print("No route found in response.");
throw Exception('No route found');
}

return data['routes'].map<List<LatLng>>((route) {
final polylineString = route['geometry'];
print("Decoding polyline: $polylineString");
return decodePolyline(polylineString);
}).toList();
} else {
print("API Error: ${response.statusCode}");
throw Exception('API Error: ${response.statusCode}');
}
} catch (e) {
print("Failed to load route: $e");
throw Exception('Failed to load route: $e');
}
}

List<LatLng> decodePolyline(String encoded) {
List<LatLng> decodedCoords = [];
int index = 0;
int lat = 0;
int lng = 0;

print("Decoding polyline...");
while (index < encoded.length) {
int b, shift = 0, result = 0;
do {
b = encoded.codeUnitAt(index++) - 63;
result |= (b & 0x1f) << shift;
shift += 5;
} while (b >= 0x20);
lat += (result & 1) == 1 ? ~(result >> 1) : (result >> 1);

shift = 0;
result = 0;
do {
b = encoded.codeUnitAt(index++) - 63;
result |= (b & 0x1f) << shift;
shift += 5;
} while (b >= 0x20);
lng += (result & 1) == 1 ? ~(result >> 1) : (result >> 1);

LatLng point = LatLng(lat / 1E5, lng / 1E5);
decodedCoords.add(point);
print("Decoded point: $point");
}

return decodedCoords;
}

@override
void dispose() {
_stopLocationUpdates();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
backgroundColor: Colors.white,
elevation: 0,
leading: IconButton(
icon: Icon(Icons.arrow_back, color: Colors.black),
onPressed: () => Navigator.pop(context),
),
title: Text(
"Donation Details",
style: TextStyle(
color: Colors.black,
fontSize: 20,
fontWeight: FontWeight.w500,
),
),
),
body: donationDetails == null
? Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
padding: EdgeInsets.symmetric(horizontal: 16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Center(
child: Column(
children: [
CircleAvatar(
radius: 40,
backgroundColor: Colors.red,
child: Text(
donationDetails?['Name']?.substring(0, 2).toUpperCase() ?? 'U',
style: TextStyle(color: Colors.white, fontSize: 24 , fontWeight: FontWeight.bold),
),
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
Text(donationDetails?['Name'] ?? 'Unknown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
SizedBox(height: 5),
Text("EMAIL: ${donationDetails?['Email'] ?? 'N/A'}"),
Text("Phone Number: ${donationDetails?['Phone'] ?? 'N/A'}"),
Text("User  ID: ${widget.userId}"),
],
),
),
],
),
),
SizedBox(height: 20),
_buildSectionTitle("Donation Information"),
_buildInfoTable([
{"Donation Id": donationDetails?['DonationId'] ?? 'N/A'},
{"Food Category": donationDetails?['FoodCategory'] ?? 'N/A'},
{"Food Condition": donationDetails?['FoodCondition'] ?? 'N/A'},
{"Food Type": donationDetails?['FoodType'] ?? 'N/A'},
{"Ingredient Used": donationDetails?['IngredientUsed'] ?? 'N/A'},
{"Number Of Serving": "${donationDetails?['NumberOfServing'] ?? 'N/A'} People"},
{"Special Instructions": donationDetails?['SpecialInstruction'] ?? 'N/A'},
{"Quantity": donationDetails?['Quantity'] ?? 'N/A'},
]),
SizedBox(height: 20),
if (donationDetails?['status'] == 'Ongoing' && donationDetails?['startLocShare'] == true)
ElevatedButton(
onPressed: _handleTrackDonation,
child: isLoadingRoute
? CircularProgressIndicator()
    : Text("Track Your Donation"),
),
SizedBox(height: 20),
if (showMap)
Container(
height: 300,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(10),
border: Border.all(color: Colors.grey),
),
child: FlutterMap(
options: MapOptions(
center: userLocation ?? LatLng(19.0760, 72.8777),
zoom: 13,
),
children: [
TileLayer(
urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
subdomains: ['a', 'b', 'c'],
),
MarkerLayer(
markers: [
if (userLocation != null)
Marker(
point: userLocation!,
width: 40,
height: 40,
child: Icon(Icons.location_pin, color: Colors.green, size: 40),
),
if (employeeLocation != null)
Marker(
point: employeeLocation!,
width: 40,
height: 40,
child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
),
],
),
PolylineLayer(
polylines: [
if (selectedRoute.isNotEmpty)
Polyline(
points: selectedRoute,
color: Colors.blue,
strokeWidth: 4.0,
),
if (_isClose(userLocation!, employeeLocation!))
Polyline(
points: [userLocation!, employeeLocation!],
color: Colors.grey,
strokeWidth: 2.0,
),
],
),
],
),
),
],
),
),
);
}

bool _isClose(LatLng userLoc, LatLng empLoc) {
const double threshold = 0.01; // Adjust this value based on your needs
return (userLoc.latitude - empLoc.latitude).abs() < threshold && (userLoc.longitude - empLoc.longitude).abs() < threshold;
}

Widget _buildSectionTitle(String title) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 5),
child: Text(
title,
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
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
}