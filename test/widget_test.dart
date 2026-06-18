import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';

void main() {
  test('recommendation result data covers API menu names', () {
    const apiMenus = [
      '흑임자다식',
      '도라지정과',
      '육포다식',
      '콩고물 도라지정과',
      '곶감 호두말이',
      '구움 견과 강정',
      '금귤정과',
      '깨강정',
      '영양찰떡',
      '양갱',
      '매작과',
      '수원약과',
    ];

    expect(dagwaResults.keys, containsAll(apiMenus));
    for (final menu in apiMenus) {
      final result = dagwaResults[menu]!;
      expect(result.menuName, menu);
      expect(result.imagePath, isNotEmpty);
    }
  });
}
