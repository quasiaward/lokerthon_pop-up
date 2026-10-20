import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dangwa_catalog.dart';
import 'package:haenggung_dagwa/services/admin_settings.dart';
import 'package:haenggung_dagwa/services/dangwa_inventory.dart';

class _SettingsStore implements AdminSettingsPersistence {
  final writes = <Completer<void>>[];
  Map<String, double>? weights;
  String? pin;

  Future<void> _wait() {
    final gate = Completer<void>();
    writes.add(gate);
    return gate.future;
  }

  @override
  Future<String?> loadPin() async => pin;
  @override
  Future<Map<String, double>?> loadWeights() async => weights;
  @override
  Future<void> savePin(String value) async {
    await _wait();
    pin = value;
  }

  @override
  Future<void> saveWeights(Map<String, double> value) async {
    await _wait();
    weights = Map.of(value);
  }
}

class _InventoryStore implements DagwaInventoryPersistence {
  final writes = <Completer<void>>[];
  Set<String>? stored;

  @override
  Future<Set<String>?> load() async => stored;
  @override
  Future<void> save(Set<String> value) async {
    final gate = Completer<void>();
    writes.add(gate);
    await gate.future;
    stored = Set.of(value);
  }
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'overlapping weight edits persist in order and survive restart',
    () async {
      final store = _SettingsStore();
      final settings = AdminSettings(persistence: store);
      final first = settings.setWeight('양갱', 1.15);
      final second = settings.setWeight('매작과', 0.85);
      await _flush();
      expect(store.writes, hasLength(1));
      store.writes.first.complete();
      await first;
      await _flush();
      expect(store.writes, hasLength(2));
      store.writes.last.complete();
      await second;
      expect(settings.weights, {'양갱': 1.15, '매작과': 0.85});
      final restored = AdminSettings(persistence: store);
      await restored.initialize();
      expect(restored.weights, settings.weights);
    },
  );

  test('failed weight edit rolls back before applying the next edit', () async {
    final store = _SettingsStore();
    final settings = AdminSettings(persistence: store);
    final failed = expectLater(
      settings.setWeight('양갱', 1.15),
      throwsStateError,
    );
    final next = settings.setWeight('매작과', 0.85);
    await _flush();
    store.writes.first.completeError(StateError('disk failure'));
    await failed;
    await _flush();
    store.writes.last.complete();
    await next;
    expect(settings.weights, {'매작과': 0.85});
    expect(store.weights, settings.weights);
  });

  test(
    'reset waits for pending edits and remains the final stored value',
    () async {
      final store = _SettingsStore();
      final settings = AdminSettings(persistence: store);
      final edit = settings.setWeight('양갱', 1.15);
      final reset = settings.resetWeights();
      await _flush();
      expect(store.writes, hasLength(1));
      store.writes.first.complete();
      await edit;
      await _flush();
      store.writes.last.complete();
      await reset;
      expect(store.weights, isEmpty);
      expect(settings.weights, isEmpty);
    },
  );

  test('failed PIN save keeps old PIN and permits a later change', () async {
    final store = _SettingsStore();
    final settings = AdminSettings(persistence: store);
    final failed = expectLater(settings.changePin('1111'), throwsStateError);
    final next = settings.changePin('2222');
    await _flush();
    expect(settings.checkPin('2003'), PinCheck.ok);
    store.writes.first.completeError(StateError('disk failure'));
    await failed;
    await _flush();
    expect(settings.checkPin('2003'), PinCheck.ok);
    store.writes.last.complete();
    await next;
    expect(settings.checkPin('2222'), PinCheck.ok);
    final restored = AdminSettings(persistence: store);
    await restored.initialize();
    expect(restored.checkPin('2222'), PinCheck.ok);
  });

  test('failed stock edit cannot revert a later successful edit', () async {
    final store = _InventoryStore();
    final inventory = DagwaInventory(persistence: store);
    final failed = expectLater(
      inventory.setInStock('양갱', false),
      throwsStateError,
    );
    final next = inventory.setInStock('매작과', false);
    await _flush();
    expect(store.writes, hasLength(1));
    store.writes.first.completeError(StateError('disk failure'));
    await failed;
    await _flush();
    store.writes.last.complete();
    expect(await next, isTrue);
    expect(inventory.isInStock('양갱'), isTrue);
    expect(inventory.isInStock('매작과'), isFalse);
    final restored = DagwaInventory(persistence: store);
    await restored.initialize();
    expect(restored.value, inventory.value);
  });

  test('restore all runs after pending stock edits', () async {
    final store = _InventoryStore();
    final inventory = DagwaInventory(persistence: store);
    final edit = inventory.setInStock('양갱', false);
    final restore = inventory.restoreAll();
    await _flush();
    expect(store.writes, hasLength(1));
    store.writes.first.complete();
    await edit;
    await _flush();
    store.writes.last.complete();
    await restore;
    expect(store.stored, unorderedEquals(activeDagwaMenus));
    expect(inventory.value, store.stored);
  });
}
