import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // To track the current carousel index
  int _donorsIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with location, profile, and notifications
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.orange),
                            SizedBox(width: 8.0),
                            Text(
                              "Home",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 28.0),
                            SizedBox(width: 16.0),
                            Icon(Icons.notifications_outlined, size: 28.0),
                          ],
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
                        'assets/images/sponsor_banner1.png',
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
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10.0),
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
                              'assets/images/sponsor_banner2.png', // Path to your food_donation image
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
                              padding: const EdgeInsets.only(left: 18.0,top:5.0),
                              child: Text(
                                "Food Donation",
                                style: TextStyle(
                                  color: Colors.grey.shade800, // Text color for visibility
                                  fontSize: 17.0, // Font size for the text
                                  fontWeight: FontWeight.bold, // Bold font
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0), // Space between text and next section
                            // Rectangle Section
                        Transform.translate(
                          offset: Offset(0, -15),
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
                                      child: Image.asset(
                                        'assets/images/food_donation.png', // Path to your inner rectangle image
                                        fit: BoxFit.cover, // Ensure the image covers the entire rectangle
                                      ),
                                    ),
                                    // Overlay Content
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16), // General padding for the entire rectangle
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Description with separate paddings

                                          Padding(
                                            padding: const EdgeInsets.only(right: 160.0), // Right padding for "Give food, Give hope"

                                            child: Text(
                                              "Give food, Give hope",
                                              style: TextStyle(
                                                fontFamily: "Inter",
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
                                                fontFamily: "Inter",
                                                fontSize: 14.0,
                                                color: Colors.grey.shade600, // Text color
                                              ),
                                            ),
                                          ),
                                          Spacer(), // Push the button to the bottom
                                          SizedBox(
                                            height: 45,
                                            width: double.infinity, // Set the button to stretch full width of rectangle
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Implement your button action here
                                              },
                                              child: Text("START DONATING TODAY",
                                                style: TextStyle(fontFamily: "Inter",fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.only(left:16,right: 16,top:14,bottom: 18),
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement your button action here
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove padding to make the image occupy full space
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        height: 70.0, // Set the desired height for the button
                        width: double.infinity, // Make the width of the button stretch to full width
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Image.asset(
                          'assets/images/verified_icon.png', // Path to your image
                          fit: BoxFit.cover, // Ensure the image covers the whole button
                        ),
                      ),
                    ),
                  ),

                  // Highest Donors Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Highest donors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0 , color: Colors.grey.shade700)),
                            TextButton(onPressed: () {}, child: Text("Explore all >")),
                          ],
                        ),
                        SizedBox(
                          height: 180.0,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 10), // To show 3 cards at once
                            itemCount: 10,
                            onPageChanged: (index) {
                              setState(() {
                                _donorsIndex = index; // Update the index when a page is changed
                              });
                            },
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _donorsIndex = index; // Update the index when an item is tapped
                                  });
                                },
                                child: Container(
                                  width: 150.0,
                                  padding: EdgeInsets.only(
                                    right: 16.0,
                                    top:16,
                                     left: 16
                                     // Add left padding only for the first card
                                  ),
                                  margin: EdgeInsets.only(right: 11.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 24.0,
                                        backgroundColor: Colors.lightBlueAccent,
                                        child: Icon(
                                          Icons.account_circle,
                                          size: 24.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        "SOHAM DALVI",
                                        style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 3.0),
                                      Text(
                                        "Feed 10 HungryOnes",
                                        style: TextStyle(fontSize: 11.0),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 3.0),
                                      Text(
                                        "In 5 Donations",
                                        style: TextStyle(fontSize: 10.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Dots Indicator for Highest Donors
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: DotsIndicator(
                              dotsCount: 10, // Number of donors
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
                          child:IconButton(
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
                        child:Text(
                          "Organic Store",
                          style: TextStyle(fontSize: 10.0, color: Colors.grey ,fontWeight: FontWeight.w500),
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
                                    style: TextStyle(fontSize: 10.0, color: Colors.grey, fontWeight: FontWeight.w500),
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
                      children: [Transform.translate(
                        offset: Offset(0, -1),
                        child:IconButton(
                          icon: Icon(Icons.favorite, color: Colors.grey),
                          onPressed: () {
                            // Navigate to My Donation
                          },
                        ),
                      ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Transform.translate(
                            offset: Offset(0, -5),
                            child:Text(
                              "My Donation",
                              style: TextStyle(fontSize: 10.0, color: Colors.grey ,fontWeight: FontWeight.w500),
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
    );
  }
}