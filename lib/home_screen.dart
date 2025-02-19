import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'organic_store.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'donation_form.dart';
import 'beone_donors.dart';
import 'package:final_project/BeOne_Verification_Page.dart';
import 'account_screen.dart';
import 'my_donations.dart';
import 'user_login_page.dart'; // Import your UserLoginPage
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'Card_to_All_donation.dart'; // Import the DonationCardToAll page
import 'MyRewardsPage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'courses.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = "Fetching location...";
  int _currentIndex = 0;
  int _donorsIndex = 0;
  List<Map<String, dynamic>> completedDonations = []; // List to hold completed donations

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _fetchCompletedDonations(); // Fetch completed donations on init
    updateUserFCMToken();
  }


  Future<void> updateUserFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    String? fcmToken = prefs.getString('fcm_token');

    // Check if userId and fcmToken are valid
    if (userId == null || userId.isEmpty) {
      print('❌ No userId found in SharedPreferences');
      return; // Exit if userId is not valid
    }

    if (fcmToken == null || fcmToken.isEmpty) {
      print('❌ No FCM token found in SharedPreferences');
      return; // Exit if fcmToken is not valid
    }

    // If both userId and fcmToken are valid, update Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'userFcmToken': fcmToken,
    }, SetOptions(merge: true)); // Use merge to create or update the field

    print('✅ FCM token updated successfully for user: $userId');
  }



  Future<void> _refreshData() async {
    await _fetchLocation(); // Refresh location
    await _fetchCompletedDonations(); // Refresh completed donations
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return; // Do nothing if location services are disabled
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return; // Do nothing if permission is denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return; // Do nothing if permissions are permanently denied
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

// Convert latitude and longitude to a human-readable address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks.first;

      String address =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

      // Save the address to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('current_latitude', position.latitude);
      await prefs.setDouble('current_longitude', position.longitude);

      // Update the UI
      setState(() {
        _currentAddress = address;
      });
    } catch (e) {
      print("Failed to get address: $e");
    }
  }

  Future<void> _fetchCompletedDonations() async {
    List<Map<String, dynamic>> tempDonationsList = [];
    DateTime now = DateTime.now();
    String currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}"; // Format YYYY-MM

    try {
      QuerySnapshot donationsSnapshot =
      await FirebaseFirestore.instance.collection('Donations').get();

      for (var donationDoc in donationsSnapshot.docs) {
        String userId = donationDoc.reference.id;
        print("Checking donations for user ID: $userId");

        QuerySnapshot userDonationsSnapshot = await FirebaseFirestore.instance
            .collection('Donations')
            .doc(userId)
            .collection('userDonations')
            .where('status', isEqualTo: 'Completed')
            .get();

        int totalServings = 0;
        int totalDonations = 0;
        String donorName = "Unknown";
        String city = "Unknown";

        for (var doc in userDonationsSnapshot.docs) {
          print("Fetched donation: ${doc.data()}");
          var data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            String? pickUpDate = data['PickUpDate'] as String?;

            if (pickUpDate != null && pickUpDate.length >= 7) {
              String formattedDate = pickUpDate.substring(0, 7); // Extract YYYY-MM

              if (formattedDate == currentMonth) {
                totalServings += (data['NumberOfServing'] ?? 0) as int;
                totalDonations++;

                donorName = data['Name'] ?? donorName;
                city = data['City'] ?? city;
              }
            }
          }
        }

        if (totalDonations > 0) {
          tempDonationsList.add({
            'Name': donorName,
            'TotalServings': totalServings,
            'TotalDonations': totalDonations,
            'City': city,
            'User  Id': userId, // Store userId for navigation
          });
        }
      }

      tempDonationsList.sort((a, b) =>
          b['TotalServings'].compareTo(a['TotalServings'])); // Sort by servings

      setState(() {
        completedDonations = tempDonationsList;
        print("Completed Donations: $tempDonationsList");
      });
    } catch (e) {
      print("Error fetching completed donations: $e");
    }
  }

  Future<void> _checkLoginAndNavigate(Widget page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    if (userId != null && userId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      _showLoginPrompt(); // Show login prompt if not logged in
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Required"),
          content: Text("Please login first."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLoginPage()), // Navigate to UserLoginPage
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData, // Call the refresh function
          child: Stack(
            children: [
          SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with location, profile, and notifications
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.orange),
                            SizedBox(width: 8.0),
                            Text(
                              "Current Location",
                              style: TextStyle(
                                fontFamily: "cerapro",
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Icon(Icons.keyboard_arrow_down, size: 20.0, color: Colors.grey),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _checkLoginAndNavigate(AccountScreen());
                              },
                              icon: SvgPicture.asset(
                                'assets/images/profile_icon.svg',
                                width: 28.0,
                                height: 28.0,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => StorePage()),
                                );
                              },
                              icon: Icon(
                                Icons.notifications_outlined,
                                size: 28.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        _currentAddress,
                        style: TextStyle(
                          fontFamily: "cerapro",
                          fontSize: 12.0,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Carousel with Dots Indicator
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 180.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index; // Update the current index
                      });
                    },
                  ),
                  items: [
                    'assets/images/sponsor_banner1.jpg',
                    'assets/images/sponsor_banner2.png',
                    'assets/images/sponsor_banner3.png',
                    'assets/images/sponsor_banner4.png',
                    'assets/images/sponsor_banner5.png',
                    'assets/images/sponsor_banner6.png',
                  ].map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 2,
                          margin: EdgeInsets.symmetric(horizontal: 0.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1.0),
                            border: Border.all(
                              color: Colors.grey.shade400,  // Border color
                              width: 1.5,  // Border width (2px)
                            ),
                          ),
                          child: Image.asset(imagePath, fit: BoxFit.cover), // Display the image
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

              // Dots Indicator below the carousel
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: DotsIndicator(
                    dotsCount: 6, // The number of items in the carousel
                    position: _currentIndex.toInt(), // Current position of carousel
                    decorator: DotsDecorator(
                      color: Colors.grey.shade400, // Inactive dot color
                      activeColor: Colors.black54, // Active dot color
                      size: Size(5.5, 5.5), // Dot size
                      activeSize: Size(7.0, 7.0), // Active dot size
                      spacing: EdgeInsets.symmetric(horizontal: 3.5), // Space between dots
                    ),
                  ),
                ),
              ),

              // Food Donation Section
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 20.0, left: 0.0, right: 0.0), // Padding for the entire section
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/images/food_donation_background.png', // Path to your food_donation image
                          fit: BoxFit.cover, // Ensure the image covers the whole container
                        ),
                      ),
                    ),
                    // Overlay Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Food Donation" Text
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0, top: 16.0),
                          child: Text(
                            "Food Donation",
                            style: TextStyle(
                              color: Colors.grey.shade700, // Text color for visibility
                              fontSize: 14.0, // Font size for the text
                              fontWeight: FontWeight.bold, // Bold font
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0), // Space between text and next section
                        // Rectangle Section
                        Transform.translate(
                          offset: Offset(0, -6),
                          child: Container(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
                            height: 249.0, // Set a fixed height for the rectangle
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Stack(
                                children: [
                                  // Full-Width and Full-Height Image
                                  Positioned.fill(
                                    child: SvgPicture.asset(
                                      'assets/images/food_donation.svg',
                                      fit: BoxFit.contain,  // Ensures the entire image is visible
                                    ),
                                  ),
                                  // Overlay Content
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // General padding for the entire rectangle
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Description with separate paddings
                                        SizedBox(height: 12.0),

                                        Padding(
                                          padding: const EdgeInsets.only(right: 160.0, top: 4), // Right padding for "Give food, Give hope"
                                          child: Text(
                                            "Give food, Give hope",
                                            style: TextStyle(
                                              fontFamily: "cerapro",
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade800, // Text color
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 8.0), // Spacing
                                        Padding(
                                          padding: const EdgeInsets.only(right: 140.0), // Right padding for "A simple act of kindness..."
                                          child: Text(
                                            "A simple act of kindness can change lives",
                                            style: TextStyle(
                                              fontFamily: "cerapro",
                                              fontSize: 13.0,
                                              color: Colors.grey.shade600, // Text color
                                            ),
                                          ),
                                        ),
                                        Spacer(), // Push the button to the bottom
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 18.0), // Add bottom padding here
                                          child: SizedBox(
                                            height: 45,
                                            width: double.infinity, // Set the button to stretch full width of rectangle
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Navigate to DonationForm when the button is pressed
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => DonationForm()),
                                                );
                                              },
                                              child: Text(
                                                "START DONATING TODAY              >",
                                                style: TextStyle(
                                                  fontFamily: "cerapro",
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white, // Text color
                                                backgroundColor: Colors.orange, // Button background color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Be BeOne Verified Section
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 18),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BeOneVerificationForm()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove padding to make the image occupy full space
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.50),
                    ),
                  ),
                  child: Container(
                    height: 70.0, // Set the desired height for the button
                    width: double.infinity, // Make the width of the button stretch to full width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.50),
                      color: Colors.grey[500],
                      border: Border.all(
                        color: Colors.grey, // Border color
                        width: 0.0, // Thickness of the border
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/verified_icon.svg',
                      fit: BoxFit.contain,  // Ensures the entire image is visible
                    ),
                  ),
                ),
              ),
              // Highest Donors Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(
                  "Highest donors",
                  style: TextStyle(
                    fontFamily: "cerapro",
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.grey.shade700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BeOneDonors()), // Directly navigate to BeOneDonors
                    ); // Correctly close the Navigator.push method
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Removes extra padding around the button
                    minimumSize: Size(50, 30), // Sets the minimum size of the button
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks tap area
                  ),
                  child: Text(
                    "Explore all >",
                    style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'cerapro', // Custom font for the text
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700, // Sets the text color to blue
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 160.0,
            child: completedDonations.isNotEmpty
                ? PageView.builder(
              controller: PageController(viewportFraction: 1.04), // Show multiple cards partially
              itemCount: completedDonations.length > 10 ? 10 : completedDonations.length,
              onPageChanged: (index) {
                setState(() {
                  _donorsIndex = index; // Update the index when a page is changed
                });
              },
              itemBuilder: (context, index) {
                var donation = completedDonations[index];
                return DonationCard(
                  name: donation['Name'],
                  totalServings: donation['TotalServings'],
                  totalDonations: donation['TotalDonations'],
                  city: donation['City'],
                  userId: donation['User  Id'], // Pass the userId here
                ); // Pass data to DonationCard
              },
            )
                : Center(
              child: Text(
                "Sorry, there are no donations yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
          // Dots Indicator for Highest Donors
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: DotsIndicator(
                dotsCount: completedDonations.isNotEmpty ? (completedDonations.length > 10 ? 10 : completedDonations.length) : 1, // Number of donors
                position: _donorsIndex.toInt(), // Current index of selected donor
                decorator: DotsDecorator(
                  color: Colors.grey.shade400, // Inactive dot color
                  activeColor: Colors.black54, // Active dot color
                  size: Size(10, 5), // Dot size
                  activeSize: Size(12, 6), // Active dot size
                  spacing: EdgeInsets.symmetric(horizontal: 1.5), // Space between dots
                ),
              ),
            ),
          ),
          ],
        ),
      ),

      // Image Illustration and Caption
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 30, 30),
        child: Column(
          children: [
            Image.asset("assets/images/illustration.png"), // Replace with your illustration
            SizedBox(height: 100.0),
          ],
        ),
      ),
      ],
    ),
    ),

    // Fixed bottom navigation bar
    Align(
    alignment: Alignment.bottomCenter,
    child: Container(
    width: 300.0, // Adjust width of the bottom navigation bar
    height: 70.0, // Adjust height to fit icons and labels
    margin: EdgeInsets.only(bottom: 12.0),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(25.0),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.6),
    blurRadius: 5,
    spreadRadius: 2,
    offset: Offset(0, 2),
    ),
    ],
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Transform.translate(
    offset: Offset(0, -1),
    child: IconButton(
    icon: Icon(Icons.store, color: Colors.grey),
    onPressed: () {
    // Navigate to Organic Store
    },
    ),
    ),
    Padding(
    padding: const EdgeInsets.only(bottom: 3.0),
    child: Transform.translate(
    offset: Offset(0, -5),
    child: Text(
    "Organic Store",
    style: TextStyle(fontFamily: "cerapro", fontSize: 10.0, color: Colors.grey, fontWeight: FontWeight.w500),
    ),
    ),
    ),
    ],
    ),
    Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Container(
    decoration: BoxDecoration(
    color: Color(0xFFFFF5E5), // Light skin shade color
    borderRadius: BorderRadius.circular(15.0), // Rounded corners
    ),
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0), // Inner padding
    child: Column(
    children: [
    Transform.translate(
    offset: Offset(0, -1),
    child: IconButton(
    icon: Icon(Icons.home, color: Colors.orange),
    onPressed: () {
    // Navigate to Home
    },
    ),
    ),
    Padding(
    padding: const EdgeInsets.only(bottom: 3.0),
    child: Transform.translate(
    offset: Offset(0, -5),
    child: Text(
    "Home",
    style: TextStyle(fontFamily: "cerapro", fontSize: 10.0, color: Colors.orange, fontWeight: FontWeight.w700),
    ),
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Transform.translate(
    offset: Offset(0, -1),
    child: IconButton(
    icon: Icon(Icons.favorite, color: Colors.grey),
    onPressed: () {
    _checkLoginAndNavigate(MyDonationsPage()); // Check login before navigating
    },
    ),
    ),
    GestureDetector(
    onTap: () {
    _checkLoginAndNavigate(MyDonationsPage()); // Check login before navigating
    },
    child: Padding(
    padding: const EdgeInsets.only(bottom: 3.0, left: 6.0),
    child: Transform.translate(
    offset: Offset(0, -5),
    child: Text(
    "My Donation",
    style: TextStyle(
    fontFamily: "cerapro",
    fontSize: 10.0,
    color: Colors.grey,
    fontWeight: FontWeight.w500,
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    );
  }
}

// DonationCard widget to display individual donor cards
class DonationCard extends StatelessWidget {
  final String name;
  final int totalServings;
  final int totalDonations;
  final String city;
  final String userId; // Add userId parameter

  DonationCard({
    required this.name,
    required this.totalServings,
    required this.totalDonations,
    required this.city,
    required this.userId, // Accept userId in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to DonationCardToAll with the userId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationCardToAll(userId: userId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white, // Background color matching your image
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Soft shadow for a lifted effect
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Square icon on the left
              Container(
                height: 90.0,
                width: 90.0,
                decoration: BoxDecoration(
                  color: Color(0xFF2C3E75), // Navy blue color
                  borderRadius: BorderRadius.circular(10), // Rounded square
                ),
              ),
              SizedBox(width: 16.0),
              // Text details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, top: 16.0),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'cerapro',
                          fontSize: 13.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700, // Text color for the name
                        ),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      "Feed $totalServings HungryOnes",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E75), // Dark blue color for emphasis
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      "In $totalDonations Donations, from $city",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                        fontSize: 10.0,
                        color: Colors.grey.shade600, // Subtle grey for less emphasis
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}