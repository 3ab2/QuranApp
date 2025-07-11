import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scientific_miracle_model.dart';

class MiracleService {
  static Future<List<ScientificMiracle>> loadMiracles() async {
    final String response = await rootBundle.loadString('assets/data/miracles.json');
    final data = json.decode(response) as List;
    return data.map((json) => ScientificMiracle.fromJson(json)).toList();
  }
} 