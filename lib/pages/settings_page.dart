import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import '../widgets/top_bar.dart';
import '../providers/settings_provider.dart';
import '../widgets/common_ui.dart';
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
        // Use scaffold background from theme
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(title: l10n.settingsTitle),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        title: Text(
                          l10n.settingsAdhanEnabled,
                          style: GoogleFonts.amiri(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: settings.isAdhanEnabled,
                        activeColor: cs.primary,
                        onChanged: (val) => settings.setAdhanEnabled(val),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        title: Text(
                          l10n.settingsDarkMode,
                          style: GoogleFonts.amiri(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: settings.isDarkMode,
                        activeColor: cs.primary,
                        onChanged: (val) => settings.setDarkMode(val),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        title: Text(
                          l10n.settingsPrayerReminder,
                          style: GoogleFonts.amiri(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: settings.isReminderEnabled,
                        activeColor: cs.primary,
                        onChanged: (val) => settings.setReminderEnabled(val),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.settingsSelectReciter,
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: cs.onSurface,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.secondary),
                      ),
                      child: DropdownButton<String>(
                        value: settings.selectedReciter,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: reciters.map((reciter) {
                          return DropdownMenuItem<String>(
                            value: reciter,
                            child: Text(
                              reciter,
                              style: GoogleFonts.amiri(color: cs.onSurface),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => settings.setSelectedReciter(value!),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.settingsSelectLanguage,
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: cs.onSurface,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.secondary),
                      ),
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
                              style: GoogleFonts.amiri(color: cs.onSurface),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => settings.setSelectedLanguage(value!),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.settingsVolume,
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: cs.onSurface,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Clear temporary data logic
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
                        icon: const Icon(Icons.delete),
                        label: Text(
                          l10n.settingsClearTempData,
                          style: GoogleFonts.amiri(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
