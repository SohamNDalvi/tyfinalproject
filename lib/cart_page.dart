import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;

  CartPage({required this.cart});

  @override
  Widget build(BuildContext context) {
    double total = 0;
    cart.forEach((item) {
      total += item['price'] * item['quantity'];
    });
    double gst = total * 0.18; // 18% GST
    double grandTotal = total + gst;

    return Scaffold(
      appBar: AppBar(title: Text("Cart"), backgroundColor: Colors.orange),
      body: cart.isEmpty
          ? Center(child: Text("Your cart is empty!"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                var item = cart[index];
                return ListTile(
                  leading: Image.asset(item["image"], width: 50),
                  title: Text(item["name"]),
                  subtitle: Text("₹${item["price"]} x ${item['quantity']}"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Subtotal: ₹${total.toStringAsFixed(2)}"),
                Text("GST (18%): ₹${gst.toStringAsFixed(2)}"),
                Text("Total: ₹${grandTotal.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    // Logic for placing the order
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Order placed successfully!"),
                    ));
                  },
                  child: Text("Order Now"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}