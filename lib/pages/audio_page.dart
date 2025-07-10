import 'package:flutter/material.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاستماع للتلاوة')),
      body: const Center(child: Text('صفحة الاستماع للتلاوة')), 
    );
  }
} 