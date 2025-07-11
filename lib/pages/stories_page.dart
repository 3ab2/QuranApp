import 'package:flutter/material.dart';
import '../data/prophets_data.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('قصص الأنبياء'), backgroundColor: Colors.teal),
        body: ListView.builder(
          itemCount: prophets.length,
          itemBuilder: (context, i) {
            final p = prophets[i];
            return ListTile(
              title: Text(p["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(context, '/story/${p["id"]}'),
            );
          },
        ),
      ),
    );
  }
} 