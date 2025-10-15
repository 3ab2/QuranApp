import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isAdhanEnabled = true;
  bool isDarkMode = false;
  bool isReminderEnabled = true;
  double volume = 0.8;
  String selectedLanguage = 'العربية';
  String selectedReciter = 'ماهر المعيقلي';

  List<String> reciters = [
    'ماهر المعيقلي',
    'عبد الباسط عبد الصمد',
    'مشاري العفاسي',
    'سعد الغامدي',
  ];

  List<String> languages = [
    'العربية',
    'English',
  ];

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;
    const Color gold = Color(0xFFD4AF37);
    const Color softGreen = Color(0xFF90EE90);
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
                        'الإعدادات',
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
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
                      child: SwitchListTile(
                        title: Text(
                          'تفعيل الأذان',
                          style: GoogleFonts.amiri(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: isAdhanEnabled,
                        activeColor: darkGreen,
                        onChanged: (val) {
                          setState(() {
                            isAdhanEnabled = val;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
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
                      child: SwitchListTile(
                        title: Text(
                          'الوضع الليلي',
                          style: GoogleFonts.amiri(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: isDarkMode,
                        activeColor: darkGreen,
                        onChanged: (val) {
                          setState(() {
                            isDarkMode = val;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
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
                      child: SwitchListTile(
                        title: Text(
                          'تذكير بالصلاة',
                          style: GoogleFonts.amiri(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: isReminderEnabled,
                        activeColor: darkGreen,
                        onChanged: (val) {
                          setState(() {
                            isReminderEnabled = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'اختيار القارئ',
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: darkGreen,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold),
                      ),
                      child: DropdownButton<String>(
                        value: selectedReciter,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: reciters.map((reciter) {
                          return DropdownMenuItem<String>(
                            value: reciter,
                            child: Text(
                              reciter,
                              style: GoogleFonts.amiri(color: darkGreen),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedReciter = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'اختيار اللغة',
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: darkGreen,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold),
                      ),
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: languages.map((lang) {
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(
                              lang,
                              style: GoogleFonts.amiri(color: darkGreen),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLanguage = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'مستوى الصوت',
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: darkGreen,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                      child: Slider(
                        value: volume,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        label: '${(volume * 100).round()}%',
                        activeColor: darkGreen,
                        inactiveColor: softGreen,
                        onChanged: (val) {
                          setState(() {
                            volume = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Clear temporary data logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم حذف البيانات المؤقتة',
                                style: GoogleFonts.amiri(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                        label: Text(
                          'حذف البيانات المؤقتة',
                          style: GoogleFonts.amiri(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
