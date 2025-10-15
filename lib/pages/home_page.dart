import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    const Color backgroundColor = Colors.white;
    const Color gold = Color(0xFFD4AF37);
    const Color softGreen = Color(0xFF90EE90);
    const Color darkGreen = Color(0xFF006400);




    return Scaffold(
      backgroundColor: backgroundColor,
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
                          color: gold,
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
                        label: 'القرآن',
                        route: '/quran',
                        gold: gold,
                        softGreen: softGreen,
                        darkGreen: darkGreen,
                      ),
                      _buildButton(
                        context,
                        icon: Icons.headphones,
                        label: 'التلاوات',
                        route: '/audio',
                        gold: gold,
                        softGreen: softGreen,
                        darkGreen: darkGreen,
                      ),
                      _buildButton(
                        context,
                        icon: Icons.auto_stories,
                        label: 'قصص الأنبياء',
                        route: '/stories',
                        gold: gold,
                        softGreen: softGreen,
                        darkGreen: darkGreen,
                      ),
                      _buildButton(
                        context,
                        icon: Icons.access_time,
                        label: 'الأذان',
                        route: '/adhan',
                        gold: gold,
                        softGreen: softGreen,
                        darkGreen: darkGreen,
                      ),
                      _buildButton(
                        context,
                        icon: Icons.science,
                        label: 'المعجزات',
                        route: '/scientific-miracles',
                        gold: gold,
                        softGreen: softGreen,
                        darkGreen: darkGreen,
                      ),
                      _buildButton(
                        context,
                        icon: Icons.settings,
                        label: 'الإعدادات',
                        route: '/settings',
                        gold: gold,
                        softGreen: softGreen,
                        darkGreen: darkGreen,
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

  Widget _buildButton(BuildContext context, {required IconData icon, required String label, required String route, required Color gold, required Color softGreen, required Color darkGreen}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      splashColor: softGreen.withValues(alpha: 77 / 255),
      highlightColor: gold.withValues(alpha: 51 / 255),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: 77 / 255),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: softGreen.withValues(alpha: 51 / 255),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: darkGreen),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.amiri(
                color: darkGreen,
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
