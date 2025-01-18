import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  TextEditingController _queryController = TextEditingController();
  List<String> _messages = [];  // List to hold chat messages

  // Your Hugging Face API token
  final String apiToken = "YOUR_HUGGING_FACE_API_KEY";  // Replace with your Hugging Face API key

  // Function to send a query to Hugging Face API (GPT-like model)
  Future<void> _sendQueryToHuggingFace(String query) async {
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/gpt2'),  // Use GPT-2 or another Hugging Face model
      headers: {
        'Authorization': 'Bearer $apiToken',  // Use your actual Hugging Face API key here
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'inputs': query,  // The query that you send to the model
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String responseText = data[0]['generated_text'];

      setState(() {
        _messages.add('User: $query');
        _messages.add('Hugging Face: $responseText');
      });
    } else {
      setState(() {
        _messages.add('Error: Could not connect to the chatbot.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      hintText: 'Type your query...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_queryController.text.isNotEmpty) {
                      _sendQueryToHuggingFace(_queryController.text);  // Send query to Hugging Face API
                      _queryController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
