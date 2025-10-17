import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                        'حول التطبيق',
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
                        'يوفر تطبيق القرآن الكريم الوصول إلى القرآن الكريم، أوقات الصلاة، المعجزات العلمية، والمزيد. تم تصميمه لمساعدة المستخدمين على تعميق فهمهم وارتباطهم بالقرآن.',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'الميزات:',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '- قراءة القرآن بالنص العربي\n- الاستماع إلى التلاوات الصوتية\n- عرض أوقات الصلاة\n- استكشاف المعجزات العلمية\n- الوصول إلى القصص والتفسير',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 16,
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
