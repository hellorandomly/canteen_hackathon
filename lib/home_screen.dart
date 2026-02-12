import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String studentId;
  const HomeScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, $studentId")),
      body: const Center(child: Text("Stall List goes here...")),
    );
  }
}