import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Account",
          style: TextStyle(fontFamily: 'cerapro'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.red,
              child: const Text(
                "SR",
                style: TextStyle(
                  fontFamily: 'cerapro',
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Soham Dalvi",
              style: TextStyle(
                fontFamily: 'cerapro',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            const Text(
              "EMAIL ID: sohamdalvi12@gmail.com",
              style: TextStyle(
                fontFamily: 'cerapro',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 2.0),
            const Text(
              "Paytm: +91 8591509629",
              style: TextStyle(
                fontFamily: 'cerapro',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(Icons.verified, color: Colors.amber),
                title: const Text(
                  "Be BeOne Verified",
                  style: TextStyle(
                    fontFamily: 'cerapro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "& build trust in community in few steps",
                  style: TextStyle(
                    fontFamily: 'cerapro',
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.card_giftcard, color: Colors.black),
                    title: const Text(
                      "Rewards",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.headset_mic, color: Colors.black),
                    title: const Text(
                      "24*7 Help & Support",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.black),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        fontFamily: 'cerapro',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
