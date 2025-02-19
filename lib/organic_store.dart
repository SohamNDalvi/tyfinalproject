import 'package:flutter/material.dart';
import 'product_details_page.dart';
import 'cart_page.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // Sample product data
  final List<Map<String, dynamic>> products = [
    {"name": "Organic Apples", "price": 150, "image": 'assets/images/sponsor_banner2.png', "quantity": 0},
    {"name": "Organic Bananas", "price": 100, "image": 'assets/images/sponsor_banner2.png', "quantity": 0},
    {"name": "Organic Carrots", "price": 80, "image": 'assets/images/sponsor_banner2.png', "quantity": 0},
    {"name": "Organic Spinach", "price": 50, "image": 'assets/images/sponsor_banner2.png', "quantity": 0},
  ];

  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> cart = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredProducts = products; // Initialize with all products
  }

  // Filter products based on the search query
  void filterProducts(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = products
          .where((product) => product["name"].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  // Add product to the cart
  void addToCart(Map<String, dynamic> product) {
    setState(() {
      // Check if the product is already in the cart
      int index = cart.indexWhere((item) => item['name'] == product['name']);
      if (index != -1) {
        // If it exists, increase the quantity
        cart[index]['quantity'] += 1;
        // Also increase the quantity in filteredProducts
        filteredProducts[filteredProducts.indexOf(product)]['quantity'] += 1;
      } else {
        // If it doesn't exist, add it to the cart with quantity 1
        cart.add({...product, 'quantity': 1});
        // Set the quantity in filteredProducts
        filteredProducts[filteredProducts.indexOf(product)]['quantity'] = 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product['name']} added to cart!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Organic Store"),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterProducts,
              decoration: InputDecoration(
                hintText: "Search for products...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
                  );
                },
              ),
              if (cart.isNotEmpty) // Show badge only if cart is not empty
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.length}', // Show the number of unique items in the cart
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            var product = filteredProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: product, addToCart: addToCart),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.asset(product["image"], fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("₹${product["price"]}", style: TextStyle(color: Colors.orange)),
                          SizedBox(height: 5),
                          if (product['quantity'] > 0) // Show quantity if greater than 0
                            Text("Quantity: ${product['quantity']}", style: TextStyle(color: Colors.green)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            onPressed: () => addToCart(product),
                            child: Text("Add to Cart"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}