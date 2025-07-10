import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('الصفحة الرئيسية', style: TextStyle(fontFamily: 'Amiri')),
          centerTitle: true,
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildTile(
              context,
              icon: Icons.menu_book,
              label: ' القرآن الكريم',
              route: '/quran',
            ),
            _buildTile(
              context,
              icon: Icons.headphones,
              label: ' الاستماع للتلاوة',
              route: '/audio',
            ),
            _buildTile(
              context,
              icon: Icons.auto_stories,
              label: 'قصص الأنبياء',
              route: '/stories',
            ),
            _buildTile(
              context,
              icon: Icons.access_time,
              label: 'الأذان وأوقات الصلاة',
              route: '/adhan',
            ),
            _buildTile(
              context,
              icon: Icons.science,
              label: 'إعجاز علمي في القرآن',
              route: '/miracles',
            ),
            _buildTile(
              context,
              icon: Icons.search,
              label: 'البحث في السور',
              route: '/search',
            ),
            _buildTile(
              context,
              icon: Icons.settings,
              label: 'الإعدادات',
              route: '/settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String label, required String route}) {
    return Card(
      color: const Color(0xFF6366F1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.white),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
} 