import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dangwa_catalog.dart';

abstract interface class DagwaInventoryPersistence {
  Future<Set<String>?> load();
  Future<void> save(Set<String> menus);
}

class SharedPreferencesDagwaInventoryPersistence
    implements DagwaInventoryPersistence {
  SharedPreferencesDagwaInventoryPersistence({SharedPreferencesAsync? prefs})
    : _prefs = prefs;

  static const _key = 'available_dangwa_menus_v1';
  SharedPreferencesAsync? _prefs;

  SharedPreferencesAsync get _client => _prefs ??= SharedPreferencesAsync();

  @override
  Future<Set<String>?> load() async {
    final saved = await _client.getStringList(_key);
    return saved?.toSet();
  }

  @override
  Future<void> save(Set<String> menus) =>
      _client.setStringList(_key, menus.toList(growable: false));
}

/// 팝업 당일 재고 상태.
///
/// 앱에서 운영하는 5종 안에서만 재고를 조절하며, 마지막 한 종은 끌 수 없다.
/// 값은 기기에 저장되어 앱을 종료하거나 아이패드를 재시작해도 유지된다.
class DagwaInventory extends ValueNotifier<Set<String>> {
  DagwaInventory({DagwaInventoryPersistence? persistence})
    : _persistence =
          persistence ?? SharedPreferencesDagwaInventoryPersistence(),
      super(Set<String>.unmodifiable(activeDagwaMenus));

  final DagwaInventoryPersistence _persistence;

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
  Future<bool> setInStock(String menu, bool inStock) async {
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
  }

  Future<void> restoreAll() async {
    final previous = value;
    value = Set<String>.unmodifiable(activeDagwaMenus);
    try {
      await _persistence.save(value);
    } catch (_) {
      value = previous;
      rethrow;
    }
  }
}

final dagwaInventory = DagwaInventory();
