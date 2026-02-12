import 'package:flutter/material.dart';
import 'home_screen.dart'; // We will create this in Step 3

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _sidController = TextEditingController();

  void _login() {
    if (_sidController.text.isNotEmpty) {
      // Hackathon Hack: Save SID locally or just pass it to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(studentId: _sidController.text)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fastfood, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text("UniCanteen", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _sidController,
                decoration: const InputDecoration(
                  labelText: "Enter Student ID (SID)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _login,
                  child: const Text("Start Ordering"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}