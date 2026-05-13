import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/khatm_dua_content.dart';

class KhatmDuaRepository {
  static const _assetPath = 'assets/data/khatm_quran_dua.json';

  /// Loads khatm JSON; drops malformed sections. Throws if asset missing or JSON invalid.
  Future<KhatmDuaContent> load() async {
    final bd = await rootBundle.load(_assetPath);
    final bytes = bd.buffer.asUint8List();
    final slice = (bytes.length >= 3 &&
            bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF)
        ? bytes.sublist(3)
        : bytes;
    final raw = utf8.decode(slice, allowMalformed: true);
    final decoded = json.decode(raw);
    if (decoded is! Map) {
      throw const FormatException('khatm_quran_dua.json: root must be an object');
    }
    final map = Map<String, dynamic>.from(decoded);
    final content = KhatmDuaContent.fromJson(map);
    if (content.introAr.isEmpty && content.sections.isEmpty) {
      assert(() {
        debugPrint('[KhatmDuaRepository] warning: intro and sections are empty after parse');
        return true;
      }());
    }
    return content;
  }
}
