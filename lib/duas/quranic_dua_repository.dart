import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/quranic_dua.dart';

class QuranicDuaRepository {
  static const _assetPath = 'assets/data/quranic_duas.json';

  /// Loads and parses duas; skips invalid entries. Throws only if the asset is
  /// missing or the JSON root cannot be decoded.
  Future<List<QuranicDua>> load() async {
    final bd = await rootBundle.load(_assetPath);
    final bytes = bd.buffer.asUint8List();
    // Strip UTF-8 BOM if present (some editors prepend it).
    final slice = (bytes.length >= 3 &&
            bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF)
        ? bytes.sublist(3)
        : bytes;
    final raw = utf8.decode(slice, allowMalformed: true);
    final decoded = json.decode(raw);
    if (decoded is! Map) {
      throw const FormatException('quranic_duas.json: root must be an object');
    }
    final map = Map<String, dynamic>.from(decoded);
    final itemsRaw = map['items'];
    if (itemsRaw is! List) {
      return const [];
    }

    final out = <QuranicDua>[];
    var index = 0;
    for (final e in itemsRaw) {
      index++;
      if (e is! Map) {
        assert(() {
          debugPrint('[QuranicDuaRepository] skip item #$index: not an object');
          return true;
        }());
        continue;
      }
      final row = Map<String, dynamic>.from(e);
      final dua = QuranicDua.tryFromJson(row);
      if (dua != null) {
        out.add(dua);
      } else {
        assert(() {
          debugPrint('[QuranicDuaRepository] skip item #$index: invalid schema');
          return true;
        }());
      }
    }
    return out;
  }
}
