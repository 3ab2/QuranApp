import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import '../data/surah_data.dart';
import '../widgets/top_bar.dart';
import '../widgets/common_ui.dart';
import '../ui/app_tokens.dart';

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(title: l10n.homeQuran),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.builder(
                  itemCount: surahs.length,
                  itemBuilder: (ctx, i) {
                    final surah = surahs[i];
                    return AppCard(
                      child: ListTile(
                        title: Text(
                          '${surah["number"]}. ${surah["name"]}',
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: cs.onSurface,
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/surah/${surah["number"]}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}