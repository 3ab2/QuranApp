/// Built-in muezzin / city style identifiers. Audio resolves under
/// `assets/sounds/adhan/voices/<id>/` then falls back to flat `assets/sounds/adhan/`.
class AdhanVoiceOption {
  final String id;
  final String labelEn;
  final String labelFr;
  final String labelAr;

  const AdhanVoiceOption({
    required this.id,
    required this.labelEn,
    required this.labelFr,
    required this.labelAr,
  });
}

const List<AdhanVoiceOption> kAdhanVoiceCatalog = [
  AdhanVoiceOption(
    id: 'bundled_default',
    labelEn: 'App default (offline)',
    labelFr: 'Par défaut de l’app (hors ligne)',
    labelAr: 'الافتراضي (دون اتصال)',
  ),
  AdhanVoiceOption(
    id: 'mishary',
    labelEn: 'Mishary Alafasy (if bundled)',
    labelFr: 'Mishary Alafasy (si inclus)',
    labelAr: 'مشاري العفاسي (إن وُجد)',
  ),
  AdhanVoiceOption(
    id: 'madinah',
    labelEn: 'Madinah style (if bundled)',
    labelFr: 'Style Médine (si inclus)',
    labelAr: 'أسلوب المدينة (إن وُجد)',
  ),
  AdhanVoiceOption(
    id: 'makkah',
    labelEn: 'Makkah style (if bundled)',
    labelFr: 'Style La Mecque (si inclus)',
    labelAr: 'أسلوب مكة (إن وُجد)',
  ),
  AdhanVoiceOption(
    id: 'morocco',
    labelEn: 'Moroccan Adhan (if bundled)',
    labelFr: 'Adhan marocain (si inclus)',
    labelAr: 'أذان مغربي (إن وُجد)',
  ),
];

AdhanVoiceOption? adhanVoiceById(String id) {
  for (final v in kAdhanVoiceCatalog) {
    if (v.id == id) return v;
  }
  return null;
}
