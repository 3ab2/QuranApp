import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

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
    const Color backgroundColor = Colors.white;
    const Color gold = Color(0xFFD4AF37);
    const Color darkGreen = Color(0xFF006400);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: 20),
              // Back Button and Page Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const BackButtonWidget(),
                    Expanded(
                      child: Text(
                        'تفسير الجلالين',
                        style: GoogleFonts.amiri(
                          color: darkGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: darkGreen),
                            const SizedBox(height: 16),
                            Text(
                              'جاري تحميل التفسير...',
                              style: GoogleFonts.amiri(color: darkGreen),
                            ),
                          ],
                        ),
                      )
                    : errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    errorMessage!,
                                    style: GoogleFonts.amiri(
                                      fontSize: 18,
                                      color: darkGreen,
                                    ),
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
                                    label: Text(
                                      'إعادة المحاولة',
                                      style: GoogleFonts.amiri(),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: darkGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: tafsirVerses.length,
                            itemBuilder: (context, index) {
                              final verse = tafsirVerses[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gold.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '﴿${verse['verse_number']}﴾',
                                      style: GoogleFonts.amiri(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: darkGreen,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      verse['text'],
                                      textDirection: TextDirection.rtl,
                                      style: GoogleFonts.amiri(
                                        fontSize: 16,
                                        color: darkGreen.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
