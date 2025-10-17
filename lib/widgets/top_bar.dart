import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:arabic_numbers/arabic_numbers.dart';
import '../pages/about_page.dart';
import '../pages/help_page.dart';
import '../pages/rate_page.dart';
import '../pages/trusted_sources_page.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final hijri = HijriCalendar.now();
    final arabicNumbers = ArabicNumbers();
    final arabicMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الثانية',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة'
    ];
    String todayDate = '${arabicNumbers.convert(hijri.hDay)} ${arabicMonths[hijri.hMonth - 1]} ${arabicNumbers.convert(hijri.hYear)} هـ';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: cs.onSurface),
              onSelected: (value) {
                // Handle menu selection
                switch (value) {
                  case 'about':
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                    break;
                  case 'help':
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpPage()));
                    break;
                  case 'rate':
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RatePage()));
                    break;
                  case 'trusted':
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TrustedSourcesPage()));
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'about', child: Text('حول التطبيق', style: TextStyle(color: cs.onSurface))),
                PopupMenuItem(value: 'help', child: Text('المساعدة', style: TextStyle(color: cs.onSurface))),
                PopupMenuItem(value: 'rate', child: Text('قيمنا', style: TextStyle(color: cs.onSurface))),
                PopupMenuItem(value: 'trusted', child: Text('المصادر الموثوقة', style: TextStyle(color: cs.onSurface))),
              ],
            ),
            Text(
              todayDate,
              style: GoogleFonts.amiri(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
