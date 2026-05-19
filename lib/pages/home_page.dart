import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../providers/tilawat_audio_controller.dart';
import '../ui/app_scroll.dart';
import '../ui/app_tokens.dart';
import '../widgets/top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward().then((_) {
      if (!mounted) return;
      setState(() {
        _showButtons = true;
      });
      _slideController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    if (_showButtons) _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;




    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: AppScrollPhysics.list(context),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TopBar(),
                  FutureBuilder<bool>(
                    future: TilawatAudioController.hasSavedSession(),
                    builder: (context, snap) {
                      if (snap.data != true) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageH,
                          vertical: AppSpacing.sm,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: FilledButton.tonalIcon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/audio',
                              arguments: {'resume': true},
                            ),
                            icon: const Icon(Icons.headphones_rounded),
                            label: Text(l10n.tilawatContinueListening),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Text(
                          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                          style: GoogleFonts.amiri(
                            color: cs.secondary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_showButtons)
                    SlideTransition(
                      position: _slideAnimation,
                      child: Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildButton(
                            context,
                            icon: Icons.menu_book,
                            label: l10n.homeQuran,
                            route: '/quran',
                            cs: cs,
                          ),
                          _buildButton(
                            context,
                            icon: Icons.library_books,
                            label: l10n.homeTafsir,
                            route: '/tafsir',
                            cs: cs,
                          ),
                          _buildButton(
                            context,
                            icon: Icons.headphones,
                            label: l10n.homeAudio,
                            route: '/audio',
                            cs: cs,
                          ),
                          _buildButton(
                            context,
                            icon: Icons.auto_stories,
                            label: l10n.homeStories,
                            route: '/stories',
                            cs: cs,
                          ),
                          _buildButton(
                            context,
                            icon: Icons.science,
                            label: l10n.homeMiracles,
                            route: '/scientific-miracles',
                            cs: cs,
                          ),
                          _buildButton(
                            context,
                            icon: Icons.format_quote_rounded,
                            label: l10n.homeQuranicDuas,
                            route: '/quranic-duas',
                            cs: cs,
                          ),
                          _buildButton(
                            context,
                            icon: Icons.volunteer_activism_rounded,
                            label: l10n.homeKhatmDua,
                            route: '/khatm-dua',
                            cs: cs,
                          ),
                          _buildButton(
                            context,
                            icon: Icons.access_time,
                            label: l10n.homeAdhan,
                            route: '/adhan',
                            cs: cs,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required IconData icon, required String label, required String route, required ColorScheme cs}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      splashColor: cs.primary.withValues(alpha: 0.2),
      highlightColor: cs.secondary.withValues(alpha: 0.12),
      child: Container(
        width: 116,
        height: 116,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outline.withValues(alpha: 0.08)),
          boxShadow: AppShadows.cardElevated(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppIconSizes.lg + 8, color: cs.onSurface.withValues(alpha: 0.88)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: GoogleFonts.amiri(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
