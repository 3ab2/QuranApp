import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String todayDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            todayDate,
            style: GoogleFonts.amiri(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: cs.onSurface),
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
              PopupMenuItem(value: 'about', child: Text('About the App', style: TextStyle(color: cs.onSurface))),
              PopupMenuItem(value: 'help', child: Text('Help', style: TextStyle(color: cs.onSurface))),
              PopupMenuItem(value: 'rate', child: Text('Rate Us', style: TextStyle(color: cs.onSurface))),
              PopupMenuItem(value: 'trusted', child: Text('Trusted Sources', style: TextStyle(color: cs.onSurface))),
            ],
          ),
        ],
      ),
    );
  }
}
