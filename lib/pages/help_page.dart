import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
                        'المساعدة',
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
                        'مرحباً بك في قسم المساعدة. هنا يمكنك العثور على إرشادات حول كيفية استخدام التطبيق بفعالية.',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'كيفية الاستخدام:',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '- التنقل عبر الصفحة الرئيسية للوصول إلى الأقسام المختلفة\n- استخدام ميزة البحث في تفاصيل السورة للعثور على آيات محددة\n- تعديل حجم الخط في تفاصيل السورة لقراءة أفضل\n- تفعيل الوضع الليلي في الإعدادات لقراءة مريحة',
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
