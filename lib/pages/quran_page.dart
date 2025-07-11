import 'package:flutter/material.dart';
import '../data/surah_data.dart';

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القرآن الكريم'),
          backgroundColor: Colors.indigo,
        ),
        body: ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (ctx, i) {
            final surah = surahs[i];
            return ListTile(
              title: Text('${surah["number"]}. ${surah["name"]}',
                  style: const TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pushNamed(
                context,
                '/surah/${surah["number"]}',
              ),
            );
          },
        ),
      ),
    );
  }
} 