import 'package:flutter/material.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قصص الأنبياء')),
      body: const Center(child: Text('صفحة قصص الأنبياء')), 
    );
  }
} 