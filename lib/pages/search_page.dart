import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البحث في السور أو الآيات')),
      body: const Center(child: Text('صفحة البحث')), 
    );
  }
} 