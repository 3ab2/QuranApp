import 'package:flutter/material.dart';

class QuranPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('القرآن الكريم | Quran')),
      body: Center(
        child: Text('Liste des sourates'),
      ),
    );
  }
} 