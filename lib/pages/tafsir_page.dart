import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TafsirPage extends StatefulWidget {
  const TafsirPage({super.key});

  @override
  State<TafsirPage> createState() => _TafsirPageState();
}

class _TafsirPageState extends State<TafsirPage> {
  List<dynamic> tafsirVerses = [];
  bool isLoading = true;
  String? errorMessage;

  final int tafsirId = 4; // ID ديال تفسير الجلالين
  final int chapterNumber = 1; // Example: Al-Fatiha

  @override
  void initState() {
    super.initState();
    fetchTafsir();
  }

  Future<void> fetchTafsir() async {
    final url = 'https://api.quran.com/v4/quran/tafsirs/$tafsirId?chapter_number=$chapterNumber';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tafsirVerses = data['tafsir']['verses'];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'تعذر جلب التفسير. الرجاء المحاولة لاحقًا.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ أثناء الاتصال بالخادم. تأكد من اتصال الإنترنت وحاول مجددًا.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tafsir al-Jalalayn')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            fetchTafsir();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: tafsirVerses.length,
                  itemBuilder: (context, index) {
                    final verse = tafsirVerses[index];
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '﴿${verse['verse_number']}﴾',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            verse['text'],
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
} 