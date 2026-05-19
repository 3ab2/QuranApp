import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/duas/khatm_dua_repository.dart';
import 'package:quran_app/duas/quranic_dua_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('quranic_duas.json loads and parses', () async {
    final list = await QuranicDuaRepository().load();
    expect(list, isNotEmpty);
    expect(list.length, greaterThan(70));
    final ids = list.map((d) => d.id).toSet();
    expect(ids.length, list.length, reason: 'duplicate dua ids');
  });

  test('khatm_quran_dua.json loads and parses', () async {
    final c = await KhatmDuaRepository().load();
    expect(c.sections, isNotEmpty);
  });
}
