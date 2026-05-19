import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../widgets/top_bar.dart';
import '../providers/settings_provider.dart';
import '../widgets/common_ui.dart';
import '../ui/app_scroll.dart';
import '../ui/app_tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    List<String> reciters = [
      'ماهر المعيقلي',
      'عبد الباسط عبد الصمد',
      'مشاري العفاسي',
      'سعد الغامدي',
    ];

    const languages = ['العربية', 'English', 'Français'];
    final selectedLanguage = languages.contains(settings.selectedLanguage)
        ? settings.selectedLanguage
        : 'العربية';

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(title: l10n.settingsTitle),
              const SizedBox(height: AppSpacing.afterHeader),
              Expanded(
                child: ListView(
                  physics: AppScrollPhysics.list(context),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageH,
                    0,
                    AppSpacing.pageH,
                    AppSpacing.listBottom,
                  ),
                  children: [
                    AppCard(
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        title: Text(
                          l10n.settingsDarkMode,
                          style: AppTypography.listTitle(cs),
                        ),
                        value: settings.isDarkMode,
                        onChanged: (val) => settings.setDarkMode(val),
                      ),
                    ),
                    AppSectionTitle(text: l10n.settingsSelectReciter),
                    AppCard(
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: DropdownButton<String>(
                        value: settings.selectedReciter,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: reciters.map((reciter) {
                          return DropdownMenuItem<String>(
                            value: reciter,
                            child: Text(
                              reciter,
                              style: GoogleFonts.amiri(
                                color: cs.onSurface,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => settings.setSelectedReciter(value!),
                      ),
                    ),
                    AppSectionTitle(text: l10n.settingsSelectLanguage),
                    AppCard(
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: languages.map((lang) {
                          final display = switch (lang) {
                            'العربية' => l10n.languageArabic,
                            'English' => l10n.languageEnglish,
                            'Français' => l10n.languageFrench,
                            _ => lang,
                          };
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(
                              display,
                              style: GoogleFonts.amiri(
                                color: cs.onSurface,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => settings.setSelectedLanguage(value!),
                      ),
                    ),
                    AppSectionTitle(text: l10n.settingsVolume),
                    AppCard(
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Slider(
                        value: settings.volume,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        label: '${(settings.volume * 100).round()}%',
                        activeColor: cs.primary,
                        inactiveColor: cs.primary.withValues(alpha: 0.3),
                        onChanged: (val) => settings.setVolume(val),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                        title: Text(
                          l10n.settingsClearTempData,
                          style: GoogleFonts.amiri(
                            color: cs.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.settingsTempDataDeleted,
                                style: GoogleFonts.amiri(),
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
