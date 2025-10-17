import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class RatePage extends StatelessWidget {
  const RatePage({super.key});

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
                        'قيمنا',
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'نقدر ملاحظاتك! يرجى تقييم تطبيقنا على متجر التطبيقات.',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              color: cs.primary,
                              size: 40,
                            ),
                            onPressed: () {
                              // Handle rating logic here
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('شكراً لتقييمك ${index + 1} نجوم!')),
                              );
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Open app store link
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('إعادة توجيه إلى متجر التطبيقات...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                        ),
                        child: Text(
                          'اذهب إلى متجر التطبيقات',
                          style: GoogleFonts.amiri(),
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
