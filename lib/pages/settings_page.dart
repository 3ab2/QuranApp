import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الإعدادات'),
          backgroundColor: Colors.indigo,
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text('تفعيل الأذان'),
              value: isAdhanEnabled,
              onChanged: (val) {
                setState(() {
                  isAdhanEnabled = val;
                });
              },
            ),
            SwitchListTile(
              title: Text('الوضع الليلي'),
              value: isDarkMode,
              onChanged: (val) {
                setState(() {
                  isDarkMode = val;
                });
              },
            ),
            SwitchListTile(
              title: Text('تذكير بالصلاة'),
              value: isReminderEnabled,
              onChanged: (val) {
                setState(() {
                  isReminderEnabled = val;
                });
              },
            ),
            SizedBox(height: 20),
            Text('اختيار القارئ', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedReciter,
              items: reciters.map((reciter) {
                return DropdownMenuItem<String>(
                  value: reciter,
                  child: Text(reciter),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReciter = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text('اختيار اللغة', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedLanguage,
              items: languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text('مستوى الصوت'),
            Slider(
              value: volume,
              min: 0,
              max: 1,
              divisions: 10,
              label: '${(volume * 100).round()}%',
              onChanged: (val) {
                setState(() {
                  volume = val;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Clear temporary data logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف البيانات المؤقتة')),
                );
              },
              icon: Icon(Icons.delete),
              label: Text('حذف البيانات المؤقتة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
} 