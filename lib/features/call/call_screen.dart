import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF18181B),
      appBar: AppBar(title: const Text('Calls')),
      body: const Center(child: Text('Call Screen')),
    );
  }
}
