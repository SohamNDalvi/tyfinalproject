import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFullImageBox('assets/images/sponsor_banner1.jpg'),
              SizedBox(height: 16.0),

              Row(
                children: [
                  Expanded(child: _buildTextOnlyBox('Donation Details', 'assets/images/sponsor_banner2.png')),
                  SizedBox(width: 16.0),
                  Expanded(child: _buildTextOnlyBox('Employee Details', 'assets/images/sponsor_banner2.png')),
                ],
              ),
              SizedBox(height: 16.0),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        _buildTextOnlyBox('User Details', 'assets/images/sponsor_banner3.png', height: 120.0),
                        SizedBox(height: 16.0),
                        _buildTextOnlyBox('Product Details', 'assets/images/sponsor_banner4.png', height: 120.0),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextOnlyBox('BeOne Verification Details', 'assets/images/sponsor_banner5.png', height: 256.0),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              _buildTextOnlyBox('Manage Your Rewards', 'assets/images/sponsor_banner6.png', height: 180.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Box with only background image (no text or icon)
  Widget _buildFullImageBox(String backgroundImage) {
    return Container(
      height: 80.0,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Box with background image and text aligned to the top-left corner
  Widget _buildTextOnlyBox(String title, String backgroundImage, {double height = 120.0}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
