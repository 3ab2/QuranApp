import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class TrustedSourcesPage extends StatelessWidget {
  const TrustedSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
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
                        'المصادر الموثوقة',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'يعتمد هذا التطبيق على مصادر موثوقة للحصول على معلومات دقيقة وأصيلة. فيما يلي المصادر المستخدمة:',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text(
                                'نص القرآن',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'مصدر من Tanzil.net للنص العربي الدقيق.',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'التلاوات الصوتية',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'مقدمة من EveryAyah.com.',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'أوقات الصلاة',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'محسوبة باستخدام Aladhan API.',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                'المعجزات العلمية',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'مجمعة من مصادر علمية إسلامية متنوعة.',
                                style: GoogleFonts.amiri(
                                  color: cs.onSurface,
                                  fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }
}
