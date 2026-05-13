/// Structured Khatm al-Qur'an supplication (see `assets/data/khatm_quran_dua.json`).
class KhatmDuaSection {
  final String titleAr;
  final String bodyAr;

  const KhatmDuaSection({required this.titleAr, required this.bodyAr});

  static KhatmDuaSection? tryFromJson(dynamic e) {
    if (e is! Map) return null;
    try {
      final m = Map<String, dynamic>.from(e);
      final t = m['titleAr'];
      final b = m['bodyAr'];
      if (t is! String || b is! String) return null;
      if (t.trim().isEmpty && b.trim().isEmpty) return null;
      return KhatmDuaSection(titleAr: t.trim(), bodyAr: b.trim());
    } catch (_) {
      return null;
    }
  }

  factory KhatmDuaSection.fromJson(Map<String, dynamic> j) {
    final s = tryFromJson(j);
    if (s == null) throw const FormatException('Invalid KhatmDuaSection');
    return s;
  }
}

class KhatmDuaContent {
  final String introAr;
  final List<KhatmDuaSection> sections;
  final String? footerNoteAr;

  const KhatmDuaContent({
    required this.introAr,
    required this.sections,
    this.footerNoteAr,
  });

  factory KhatmDuaContent.fromJson(Map<String, dynamic> j) {
    final raw = j['sections'];
    final sections = <KhatmDuaSection>[];
    if (raw is List) {
      for (final e in raw) {
        final s = KhatmDuaSection.tryFromJson(e);
        if (s != null) sections.add(s);
      }
    }
    final intro = j['introAr'] is String ? (j['introAr'] as String).trim() : '';
    final footer = j['footerNoteAr'] is String ? (j['footerNoteAr'] as String).trim() : null;
    return KhatmDuaContent(
      introAr: intro,
      sections: sections,
      footerNoteAr: (footer == null || footer.isEmpty) ? null : footer,
    );
  }
}
