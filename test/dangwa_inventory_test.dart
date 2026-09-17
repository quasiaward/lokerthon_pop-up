import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dangwa_catalog.dart';
import 'package:haenggung_dagwa/services/dangwa_inventory.dart';

class _MemoryPersistence implements DagwaInventoryPersistence {
  Set<String>? stored;

  @override
  Future<Set<String>?> load() async => stored?.toSet();

  @override
  Future<void> save(Set<String> menus) async => stored = menus.toSet();
}

void main() {
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
