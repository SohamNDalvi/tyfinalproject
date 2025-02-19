import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:intl/intl.dart'; // For date formatting

class MyRewardsPage extends StatefulWidget {
  @override
  _MyRewardsPageState createState() => _MyRewardsPageState();
}

class _MyRewardsPageState extends State<MyRewardsPage> {
  String? userId;
  List<Map<String, dynamic>> rewards = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid');
    if (userId != null) {
      _fetchRewards();
    }
  }

  Future<void> _fetchRewards() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Rewards')
          .doc(userId)
          .collection('CouponCodes')
          .get();

      setState(() {
        rewards = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error fetching rewards: $e");
    }
  }

  void _copyToClipboard(String couponCode) {
    Clipboard.setData(ClipboardData(text: couponCode)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Coupon code copied to clipboard")),
      );
    });
  }

  void _showRewardDetails(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reward Details"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text("Coupon Code: ${reward['couponCode']}"),
                Text("Start Date: ${_formatDate(reward['startDate'])}"),
                Text("Due Date: ${_formatDate(reward['dueDate'])}"),
                Text("Terms Condition: ${reward['termsCondition']}"),
                Text("Company: ${reward['company']}"),
                Text("Donation ID: ${reward['donationId']}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('MM/dd/yyyy').format(dateTime); // Format the date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Rewards"),
      ),
      body: rewards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Coupon Code: ${reward['couponCode']}"),
              subtitle: Text("Start Date: ${_formatDate(reward['startDate'])}\nDue Date: ${_formatDate(reward['dueDate'])}"),
              trailing: IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyToClipboard(reward['couponCode']),
              ),
              onTap: () => _showRewardDetails(reward),
            ),
          );
        },
      ),
    );
  }
}