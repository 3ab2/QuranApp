import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;
    const Color gold = Color(0xFFD4AF37);
    const Color darkGreen = Color(0xFF006400);

    String todayDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: gold.withAlpha(51), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            todayDate,
            style: GoogleFonts.amiri(
              color: darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: darkGreen),
            onSelected: (value) {
              // Handle menu selection
              switch (value) {
                case 'about':
                  // Navigate to about
                  break;
                case 'help':
                  // Navigate to help
                  break;
                case 'rate':
                  // Open rate dialog
                  break;
                case 'trusted':
                  // Navigate to trusted sources
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'about', child: Text('About the App')),
              const PopupMenuItem(value: 'help', child: Text('Help')),
              const PopupMenuItem(value: 'rate', child: Text('Rate Us')),
              const PopupMenuItem(value: 'trusted', child: Text('Trusted Sources')),
            ],
          ),
        ],
      ),
    );
  }
}
