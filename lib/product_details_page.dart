import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) addToCart;

  ProductDetailPage({required this.product, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    // Sample images for the carousel
    List<String> imageUrls = [
      product["image"], // Main image
      'assets/images/sponsor_banner1.jpg', // Add more images as needed
      'assets/images/sponsor_banner1.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"]),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Carousel
            Container(
              height: 300,
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageUrls[index]),
                        fit: BoxFit.cover, // Use BoxFit.cover to fill the space
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            // Product Name and Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "₹${product["price"]}",
                    style: TextStyle(fontSize: 20, color: Colors.orange),
                  ),
                  SizedBox(height: 16.0),
                  // Product Description
                  Text(
                    "Description:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "This is a detailed description of the product. It includes information about the product's features, benefits, and any other relevant details that a customer might find useful.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16.0),
                  // Product Features
                  Text(
                    "Features:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "- Fresh and organic\n- No pesticides\n- High nutritional value",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16.0),
                  // Add to Cart Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                      addToCart(product);
                      Navigator.pop(context);
                    },
                    child: Text("Add to Cart"),
                  ),
                  SizedBox(height: 16.0),
                  // Customer Reviews Section
                  Text(
                    "Customer Reviews:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  // Sample Reviews
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("John Doe"),
                    subtitle: Text("Great quality! Highly recommend."),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Jane Smith"),
                    subtitle: Text("Fresh and tasty, will buy again."),
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