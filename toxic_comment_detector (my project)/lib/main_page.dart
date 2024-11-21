import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _commentController = TextEditingController();
  String _result = "";

  Future<void> _checkComment() async {
    final String comment = _commentController.text.trim();

    if (comment.isEmpty) {
      setState(() {
        _result = "Please enter a comment.";
      });
      return;
    }

    setState(() {
      _result = "Checking...";
    });

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8000/detect/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"comment": comment}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data["is_toxic"]
              ? "This comment is toxic!"
              : "This comment is acceptable.";
        });
      } else {
        setState(() {
          _result = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error checking the comment. Please try again later.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Toxic Comment Detector")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Type your comment here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkComment,
              child: const Text("Check Comment"),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _result.contains("toxic") ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
