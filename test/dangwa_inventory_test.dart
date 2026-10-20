import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dangwa_catalog.dart';
import 'package:haenggung_dagwa/services/dangwa_inventory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _MemoryPersistence implements DagwaInventoryPersistence {
  Set<String>? stored;

  @override
  Future<Set<String>?> load() async => stored?.toSet();

  @override
  Future<void> save(Set<String> menus) async => stored = menus.toSet();
}

void main() {
  group('업데이트 전후 저장값', _migrationTests);

  test('저장된 재고 설정을 다음 실행에 복원한다', () async {
    final persistence = _MemoryPersistence();
    final first = DagwaInventory(persistence: persistence);

    expect(await first.setInStock('금귤정과', false), isTrue);
    expect(first.value, isNot(contains('금귤정과')));

    final restored = DagwaInventory(persistence: persistence);
    await restored.initialize();
    expect(restored.value, first.value);
  });

  test('비운영 메뉴는 저장값에 있어도 재고 목록에 올리지 않는다', () async {
    final persistence = _MemoryPersistence()
      ..stored = {'양갱', '수원약과', '알 수 없는 메뉴'};
    final inventory = DagwaInventory(persistence: persistence);

    await inventory.initialize();

    expect(inventory.value, {'양갱'});
  });

  test('마지막 한 종은 품절 처리할 수 없다', () async {
    final inventory = DagwaInventory(persistence: _MemoryPersistence());
    for (final menu in activeDagwaMenus.take(activeDagwaMenus.length - 1)) {
      expect(await inventory.setInStock(menu, false), isTrue);
    }

    final last = inventory.value.single;
    expect(await inventory.setInStock(last, false), isFalse);
    expect(inventory.value, {last});
  });

  test('전체 재고 있음으로 복구한다', () async {
    final inventory = DagwaInventory(persistence: _MemoryPersistence());
    await inventory.setInStock('매작과', false);

    await inventory.restoreAll();

    expect(inventory.value, unorderedEquals(activeDagwaMenus));
  });
}

void _migrationTests() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test('업데이트 전 저장값은 그때의 5종 기준으로 읽고, 새로 켠 다과는 재고 있음이다', () async {
    // 업데이트 전 앱은 재고 있음 목록만 저장했다. 양갱만 꺼 둔 상태.
    await SharedPreferencesAsync().setStringList('available_dangwa_menus_v1', [
      '금귤정과',
      '매작과',
      '콩고물 도라지정과',
      '흑임자다식',
    ]);
    final inventory = DagwaInventory(
      persistence: SharedPreferencesDagwaInventoryPersistence(),
    );
    await inventory.initialize();

    expect(inventory.value, isNot(contains('양갱')));
    expect(
      inventory.value,
      containsAll(
        activeDagwaMenus.where(
          (m) => !SharedPreferencesDagwaInventoryPersistence.legacyKnownMenus
              .contains(m),
        ),
      ),
    );
    expect(inventory.value.length, activeDagwaMenus.length - 1);
  });

  test('저장 뒤 다과를 새로 켜도 저장한 품절 상태만 유지한다', () async {
    final persistence = SharedPreferencesDagwaInventoryPersistence();
    final first = DagwaInventory(persistence: persistence);
    expect(await first.setInStock('육포다식', false), isTrue);

    final restored = DagwaInventory(
      persistence: SharedPreferencesDagwaInventoryPersistence(),
    );
    await restored.initialize();
    expect(restored.value, first.value);

    // 저장 당시 몰랐던 다과는 품절로 보지 않는다.
    expect(
      SharedPreferencesDagwaInventoryPersistence.restore(
        {'금귤정과'},
        {'금귤정과', '매작과'},
      ),
      {'금귤정과', ...activeDagwaMenus.where((m) => m != '매작과')},
    );
  });
}
