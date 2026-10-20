import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dangwa_catalog.dart';
import 'serial_task_queue.dart';

abstract interface class DagwaInventoryPersistence {
  Future<Set<String>?> load();
  Future<void> save(Set<String> menus);
}

class SharedPreferencesDagwaInventoryPersistence
    implements DagwaInventoryPersistence {
  SharedPreferencesDagwaInventoryPersistence({SharedPreferencesAsync? prefs})
    : _prefs = prefs;

  static const _key = 'available_dangwa_menus_v1';

  /// 재고를 저장할 때 운영 중이던 다과. 저장 뒤 새로 켠 다과를 품절로
  /// 오해하지 않도록 함께 남긴다.
  static const _knownKey = 'known_dangwa_menus_v1';

  /// [_knownKey]가 생기기 전 운영하던 5종. 그때 저장된 값은 이 기준으로 읽는다.
  static const legacyKnownMenus = {'금귤정과', '매작과', '양갱', '콩고물 도라지정과', '흑임자다식'};

  SharedPreferencesAsync? _prefs;

  SharedPreferencesAsync get _client => _prefs ??= SharedPreferencesAsync();

  @override
  Future<Set<String>?> load() async {
    final saved = await _client.getStringList(_key);
    if (saved == null) return null;
    final known = await _client.getStringList(_knownKey);
    return restore(saved.toSet(), known?.toSet() ?? legacyKnownMenus);
  }

  /// 저장값은 "재고 있음" 목록이라, 저장 당시 몰랐던 다과는 들어 있지 않다.
  /// 그때 운영하던 다과([known]) 가운데 빠진 것만 품절로 보고, 이후 새로 켠
  /// 다과는 재고 있음으로 되살린다.
  static Set<String> restore(Set<String> saved, Set<String> known) => {
    ...saved,
    for (final menu in activeDagwaMenus)
      if (!known.contains(menu)) menu,
  };

  @override
  Future<void> save(Set<String> menus) async {
    // 재고 목록을 먼저 쓴다. 뒤 저장이 실패해도 새 다과가 품절로 숨지 않고
    // 재고 있음으로 되살아나는 쪽으로 어긋난다.
    await _client.setStringList(_key, menus.toList(growable: false));
    await _client.setStringList(_knownKey, activeDagwaMenus);
  }
}

/// 팝업 당일 재고 상태.
///
/// 앱에서 운영하는 다과(`activeDagwaMenus`) 안에서만 재고를 조절하며,
/// 마지막 한 종은 끌 수 없다.
/// 값은 기기에 저장되어 앱을 종료하거나 아이패드를 재시작해도 유지된다.
class DagwaInventory extends ValueNotifier<Set<String>> {
  DagwaInventory({DagwaInventoryPersistence? persistence})
    : _persistence =
          persistence ?? SharedPreferencesDagwaInventoryPersistence(),
      super(Set<String>.unmodifiable(activeDagwaMenus));

  final DagwaInventoryPersistence _persistence;
  final _writes = SerialTaskQueue();

  bool get isEmpty => value.isEmpty;
  bool isInStock(String menu) => value.contains(menu);

  Future<void> initialize() async {
    try {
      final saved = await _persistence.load();
      if (saved == null) return;
      final valid = saved.intersection(activeDagwaMenuSet);
      if (valid.isNotEmpty) value = Set<String>.unmodifiable(valid);
    } catch (error, stackTrace) {
      debugPrint('재고 설정을 불러오지 못했습니다: $error\n$stackTrace');
    }
  }

  /// 변경에 성공하면 true, 마지막 재고를 끄려는 요청이면 false를 돌려준다.
  Future<bool> setInStock(String menu, bool inStock) => _writes.run(() async {
    if (!activeDagwaMenuSet.contains(menu)) return false;

    final previous = value;
    final next = previous.toSet();
    inStock ? next.add(menu) : next.remove(menu);
    if (next.isEmpty) return false;
    if (setEquals(previous, next)) return true;

    value = Set<String>.unmodifiable(next);
    try {
      await _persistence.save(value);
      return true;
    } catch (_) {
      value = previous;
      rethrow;
    }
  });

  Future<void> restoreAll() => _writes.run(() async {
    final previous = value;
    value = Set<String>.unmodifiable(activeDagwaMenus);
    try {
      await _persistence.save(value);
    } catch (_) {
      value = previous;
      rethrow;
    }
  });
}

final dagwaInventory = DagwaInventory();
