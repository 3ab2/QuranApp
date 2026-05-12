import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../ui/app_tokens.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
    final todayDate =
        '${arabicNumbers.convert(hijri.hDay)} ${arabicMonths[hijri.hMonth - 1]} ${arabicNumbers.convert(hijri.hYear)} هـ';

    return Directionality(
      textDirection: Directionality.of(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageH,
          vertical: AppSpacing.md - 4,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  todayDate,
                  style: GoogleFonts.amiri(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: cs.onSurface),
              tooltip: l10n.settingsTitle,
              position: PopupMenuPosition.under,
              onSelected: (value) {
                switch (value) {
                  case 'settings':
                    Navigator.pushNamed(context, '/settings');
                    break;
                  case 'about':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                    break;
                  case 'help':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpPage()),
                    );
                    break;
                  case 'rate':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RatePage()),
                    );
                    break;
                  case 'trusted':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrustedSourcesPage(),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'settings',
                  child: Text(
                    l10n.settingsTitle,
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),
                PopupMenuItem(
                  value: 'about',
                  child: Text(
                    l10n.topBarAbout,
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),
                PopupMenuItem(
                  value: 'help',
                  child: Text(
                    l10n.topBarHelp,
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),
                PopupMenuItem(
                  value: 'rate',
                  child: Text(
                    l10n.topBarRate,
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),
                PopupMenuItem(
                  value: 'trusted',
                  child: Text(
                    l10n.topBarSources,
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
