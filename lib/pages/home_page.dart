import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
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
        child: Column(
          children: [
            const TopBar(),
            const SizedBox(height: 20),
            // Basmala
            Expanded(
              flex: 1,
              child: Center(
                child: AnimatedBuilder(
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
              ),
            ),
            const SizedBox(height: 20),
            // Buttons
            if (_showButtons)
              Expanded(
                flex: 2,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
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
                        icon: Icons.access_time,
                        label: l10n.homeAdhan,
                        route: '/adhan',
                        cs: cs,
                      ),
                      _buildButton(
                        context,
                        icon: Icons.science,
                        label: l10n.homeMiracles,
                        route: '/scientific-miracles',
                        cs: cs,
                      ),
                    ],
                  ),
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
      borderRadius: BorderRadius.circular(16),
      splashColor: cs.primary.withValues(alpha: 0.3),
      highlightColor: cs.secondary.withValues(alpha: 0.2),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.15),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: cs.onSurface),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.amiri(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
