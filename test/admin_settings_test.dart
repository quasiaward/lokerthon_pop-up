import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dangwa_catalog.dart';
import 'package:haenggung_dagwa/pages/kiosk_page.dart';
import 'package:haenggung_dagwa/services/admin_settings.dart';
import 'package:haenggung_dagwa/services/dangwa_inventory.dart';
import 'package:haenggung_dagwa/services/local_recommendation_engine.dart';
import 'package:haenggung_dagwa/services/recommendation_service.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';

class _MemorySettings implements AdminSettingsPersistence {
  String? pin;
  Map<String, double>? weights;

  @override
  Future<String?> loadPin() async => pin;

  @override
  Future<void> savePin(String value) async => pin = value;

  @override
  Future<Map<String, double>?> loadWeights() async => weights;

  @override
  Future<void> saveWeights(Map<String, double> value) async =>
      weights = Map.of(value);
}

class _MemoryInventory implements DagwaInventoryPersistence {
  Set<String>? stored;

  @override
  Future<Set<String>?> load() async => stored;

  @override
  Future<void> save(Set<String> menus) async => stored = menus.toSet();
}

Future<void> _frames(WidgetTester tester, [int ms = 400]) async {
  for (var t = 0; t < ms; t += 20) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.byKey(ValueKey('pin-key-$digit')));
    await tester.pump();
  }
  await _frames(tester);
}

Future<void> _pumpKiosk(WidgetTester tester, AdminSettings settings) async {
  tester.view.physicalSize = const Size(2732, 2048);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: KioskPage(
        inventory: DagwaInventory(persistence: _MemoryInventory()),
        adminSettings: settings,
      ),
    ),
  );
  await _frames(tester, 800);
  await tester.longPress(find.byKey(const ValueKey('admin-entry')));
  await _frames(tester);
}

void main() {
  group('AdminSettings', () {
    test('초기 암호는 2003이다', () {
      final settings = AdminSettings(persistence: _MemorySettings());
      expect(settings.checkPin('2003'), PinCheck.ok);
      expect(settings.checkPin('0000'), PinCheck.wrong);
    });

    test('바꾼 암호는 저장되어 다음 실행에도 쓰인다', () async {
      final store = _MemorySettings();
      await AdminSettings(persistence: store).changePin('1234');

      final restored = AdminSettings(persistence: store);
      await restored.initialize();
      expect(restored.checkPin('2003'), PinCheck.wrong);
      expect(restored.checkPin('1234'), PinCheck.ok);
    });

    test('4자리 숫자가 아닌 암호로는 바꿀 수 없다', () async {
      final settings = AdminSettings(persistence: _MemorySettings());
      for (final bad in ['123', '12345', '12a4', '']) {
        expect(() => settings.changePin(bad), throwsArgumentError);
      }
      expect(settings.checkPin('2003'), PinCheck.ok);
    });

    test('5번 연속 틀리면 30초 동안 맞는 암호도 받지 않는다', () {
      var now = DateTime(2026, 9, 17, 12);
      final settings = AdminSettings(
        persistence: _MemorySettings(),
        clock: () => now,
      );
      for (var i = 0; i < AdminSettings.maxFailures - 1; i++) {
        expect(settings.checkPin('1111'), PinCheck.wrong);
      }
      expect(settings.checkPin('1111'), PinCheck.locked);
      expect(settings.checkPin('2003'), PinCheck.locked);

      now = now.add(AdminSettings.lockDuration);
      expect(settings.lockRemaining, isNull);
      expect(settings.checkPin('2003'), PinCheck.ok);
    });

    test('비중은 범위·단위에 맞춰 저장되고, 1.0은 기본값으로 지운다', () async {
      final store = _MemorySettings();
      final settings = AdminSettings(persistence: store);

      await settings.setWeight('양갱', 3);
      expect(settings.weightOf('양갱'), AdminSettings.maxWeight);
      await settings.setWeight('매작과', 0.834);
      expect(settings.weightOf('매작과'), 0.83);
      await settings.setWeight('수원약과', 1.1); // 비활성 메뉴는 무시
      expect(settings.weights.containsKey('수원약과'), isFalse);

      final restored = AdminSettings(persistence: store);
      await restored.initialize();
      expect(restored.weights, {'양갱': 1.2, '매작과': 0.83});

      await restored.setWeight('양갱', 1.0);
      await restored.resetWeights();
      expect(restored.hasCustomWeights, isFalse);
      expect(store.weights, isEmpty);
    });
  });

  group('간단 설정 단계', () {
    test('낮음·보통·높음은 고급 설정 비중과 같은 값을 쓴다', () async {
      final settings = AdminSettings(persistence: _MemorySettings());
      expect(settings.levelOf('양갱'), WeightLevel.normal);

      await settings.setLevel('양갱', WeightLevel.high);
      expect(settings.weightOf('양갱'), WeightLevel.high.weight);
      await settings.setLevel('매작과', WeightLevel.low);
      expect(settings.weightOf('매작과'), WeightLevel.low.weight);

      // 고급 설정에서 단계 밖의 값을 고르면 어느 단계도 아니다.
      await settings.setWeight('양갱', 1.07);
      expect(settings.levelOf('양갱'), isNull);
      // 고급 설정에서 단계 값과 같게 맞추면 다시 그 단계로 보인다.
      await settings.setWeight('양갱', 0.85);
      expect(settings.levelOf('양갱'), WeightLevel.low);

      await settings.setLevel('양갱', WeightLevel.normal);
      expect(settings.weights.containsKey('양갱'), isFalse);
    });

    test('단계 값은 고급 설정 범위 안에 있고, 낮음 < 보통 < 높음 순으로 비율이 오른다', () {
      for (final level in WeightLevel.values) {
        expect(
          level.weight,
          inInclusiveRange(AdminSettings.minWeight, AdminSettings.maxWeight),
        );
        expect(AdminSettings.normalizeWeight(level.weight), level.weight);
      }
      for (final menu in activeDagwaMenus) {
        final shares = [
          for (final level in WeightLevel.values)
            LocalRecommendationEngine.expectedShares(
              weights: {menu: level.weight},
            )[menu]!,
        ];
        // 현장에서 체감할 만큼: 낮음은 기본의 65% 이하, 높음은 130% 이상.
        // (현재 낮음 50~62%, 높음 139~163%)
        expect(shares[0], lessThan(shares[1] * 0.65), reason: menu);
        expect(shares[2], greaterThan(shares[1] * 1.3), reason: menu);
      }
    });
  });

  group('추천 비중', () {
    test('비중이 없으면 기존 추천과 같다', () {
      final base = LocalRecommendationEngine.expectedShares();
      final same = LocalRecommendationEngine.expectedShares(
        weights: {for (final m in activeDagwaMenus) m: 1.0},
      );
      expect(same, base);
    });

    test('비중을 올리면 그 다과의 예상 비율이 오르고, 낮추면 내려간다', () {
      final base = LocalRecommendationEngine.expectedShares();
      for (final menu in activeDagwaMenus) {
        final up = LocalRecommendationEngine.expectedShares(
          weights: {menu: 1.1},
        );
        final down = LocalRecommendationEngine.expectedShares(
          weights: {menu: 0.9},
        );
        expect(up[menu]!, greaterThan(base[menu]!), reason: menu);
        expect(down[menu]!, lessThan(base[menu]!), reason: menu);
      }
    });

    test('예상 비율은 실제 추천 결과를 그대로 센 값과 같다', () {
      const weights = {'양갱': 1.12, '금귤정과': 0.93};
      const available = {'양갱', '금귤정과', '매작과', '흑임자다식'};
      final shares = LocalRecommendationEngine.expectedShares(
        availableMenus: available,
        weights: weights,
      );
      expect(shares.values.fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
      expect(shares.containsKey('콩고물 도라지정과'), isFalse);

      final counts = <String, int>{};
      var total = 0;
      void walk(List<String> prefix) {
        if (prefix.length == 6) {
          final menu = LocalRecommendationEngine.pick(
            prefix,
            availableMenus: available,
            weights: weights,
          );
          counts[menu] = (counts[menu] ?? 0) + 1;
          total++;
          return;
        }
        for (final option in _options[prefix.length]) {
          walk([...prefix, option]);
        }
      }

      walk([]);
      for (final menu in available) {
        expect(shares[menu], closeTo((counts[menu] ?? 0) / total, 1e-9));
      }
    });

    test('RecommendationService가 비중을 추천에 반영한다', () async {
      const weights = {'양갱': 0.8};
      List<String>? changed;
      void walk(List<String> prefix) {
        if (changed != null) return;
        if (prefix.length == 6) {
          if (LocalRecommendationEngine.pick(prefix) !=
              LocalRecommendationEngine.pick(prefix, weights: weights)) {
            changed = prefix;
          }
          return;
        }
        for (final option in _options[prefix.length]) {
          walk([...prefix, option]);
        }
      }

      walk([]);
      expect(changed, isNotNull);
      final service = RecommendationService();
      expect(
        await service.getRecommendation(changed!),
        LocalRecommendationEngine.pick(changed!),
      );
      expect(
        await service.getRecommendation(changed!, weights: weights),
        LocalRecommendationEngine.pick(changed!, weights: weights),
      );
      expect(
        await service.getRecommendation(changed!, weights: weights),
        isNot(await service.getRecommendation(changed!)),
      );
    });
  });

  group('관리자 화면', () {
    testWidgets('틀린 암호로는 열리지 않고, 맞는 암호로 열린다', (tester) async {
      await _pumpKiosk(tester, AdminSettings(persistence: _MemorySettings()));
      expect(find.byKey(const ValueKey('admin-pin-pad')), findsOneWidget);
      expect(find.byKey(const ValueKey('admin-inventory-sheet')), findsNothing);

      await _enterPin(tester, '1234');
      expect(find.text('암호가 올바르지 않아요.'), findsOneWidget);
      expect(find.byKey(const ValueKey('admin-inventory-sheet')), findsNothing);

      await _enterPin(tester, '2003');
      expect(find.byKey(const ValueKey('admin-pin-pad')), findsNothing);
      expect(
        find.byKey(const ValueKey('admin-inventory-sheet')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('취소하면 암호 패드가 닫힌다', (tester) async {
      await _pumpKiosk(tester, AdminSettings(persistence: _MemorySettings()));
      await tester.tap(find.byKey(const ValueKey('pin-cancel')));
      await _frames(tester);
      expect(find.byKey(const ValueKey('admin-pin-pad')), findsNothing);
      expect(find.byKey(const ValueKey('admin-inventory-sheet')), findsNothing);
    });

    testWidgets('재고 관리 타일 5개가 모두 시트 안에 온전히 보인다', (tester) async {
      await _pumpKiosk(tester, AdminSettings(persistence: _MemorySettings()));
      await _enterPin(tester, '2003');
      final sheet = tester.getRect(
        find.byKey(const ValueKey('admin-inventory-sheet')),
      );
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(activeDagwaMenus.length));
      for (final menu in activeDagwaMenus) {
        final name = tester.getRect(find.text(menu));
        expect(sheet.contains(name.bottomRight), isTrue, reason: menu);
      }
      // 마지막 타일이 버튼 줄 위에서 끝나야 한다.
      final lastTile = tester.getRect(
        find
            .ancestor(
              of: find.text(activeDagwaMenus.last),
              matching: find.byType(Container),
            )
            .first,
      );
      final buttons = tester.getRect(find.text('설정 완료'));
      // 사이의 안내 문구 칸(30)과 여백(10)을 비워 둬야 한다. 예전 고정 비율
      // 격자는 이 칸까지 내려와 마지막 줄이 잘렸다.
      expect(lastTile.bottom, lessThan(buttons.top - 40));
    });

    testWidgets('간단 설정 버튼이 고급 설정 비중과 연동된다', (tester) async {
      final store = _MemorySettings();
      final settings = AdminSettings(persistence: store);
      await _pumpKiosk(tester, settings);
      await _enterPin(tester, '2003');

      await tester.tap(find.byKey(const ValueKey('admin-tab-simple')));
      await _frames(tester);
      expect(find.text('간단 설정'), findsWidgets);

      const menu = '금귤정과';
      Finder level(String name) => find.descendant(
        of: find.byKey(const ValueKey('level-$menu')),
        matching: find.byKey(ValueKey('level-$name')),
      );
      await tester.tap(level('high'));
      await _frames(tester);
      expect(settings.weightOf(menu), WeightLevel.high.weight);
      expect(store.weights?[menu], WeightLevel.high.weight);

      // 고급 설정 슬라이더가 같은 값을 보여 준다.
      await tester.tap(find.byKey(const ValueKey('admin-tab-advanced')));
      await _frames(tester);
      final slider = tester.widget<Slider>(
        find.descendant(
          of: find.byKey(const ValueKey('weight-$menu')),
          matching: find.byType(Slider),
        ),
      );
      expect(slider.value, WeightLevel.high.weight);
      expect(find.text('비중 ×1.15'), findsOneWidget);

      // 고급 설정에서 바꾸면 간단 설정에서는 어느 단계도 켜지지 않는다.
      await settings.setWeight(menu, 1.04);
      await tester.tap(find.byKey(const ValueKey('admin-tab-simple')));
      await _frames(tester);
      expect(find.text('고급 설정 값 ×1.04'), findsOneWidget);

      await tester.tap(level('low'));
      await _frames(tester);
      expect(settings.weightOf(menu), WeightLevel.low.weight);
      expect(find.text('낮음 · 비중 ×0.85'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('고급 설정에서 비중을 바꾸고 암호를 변경한다', (tester) async {
      final store = _MemorySettings();
      final settings = AdminSettings(persistence: store);
      await _pumpKiosk(tester, settings);
      await _enterPin(tester, '2003');

      await tester.tap(find.byKey(const ValueKey('admin-tab-advanced')));
      await _frames(tester);
      expect(find.text('고급 설정'), findsWidgets);
      expect(find.byType(Slider), findsNWidgets(activeDagwaMenus.length));

      const menu = '양갱';
      final before = tester
          .widget<Text>(find.byKey(const ValueKey('share-$menu')))
          .data;
      final slider = find.descendant(
        of: find.byKey(const ValueKey('weight-$menu')),
        matching: find.byType(Slider),
      );
      await tester.drag(slider, const Offset(300, 0));
      await _frames(tester);
      expect(settings.weightOf(menu), greaterThan(1.0));
      expect(store.weights?[menu], settings.weightOf(menu));
      final after = tester
          .widget<Text>(find.byKey(const ValueKey('share-$menu')))
          .data;
      expect(after, isNot(before));

      await tester.tap(find.text('비중 초기화'));
      await _frames(tester);
      expect(settings.hasCustomWeights, isFalse);

      await tester.tap(find.text('암호 변경'));
      await _frames(tester);
      await _enterPin(tester, '1111');
      await _enterPin(tester, '2222');
      expect(find.textContaining('두 암호가 달라요'), findsOneWidget);
      await _enterPin(tester, '4321');
      await _enterPin(tester, '4321');
      expect(find.text('관리자 암호를 바꿨어요.'), findsOneWidget);
      expect(store.pin, '4321');
      expect(settings.checkPin('4321'), PinCheck.ok);
      expect(tester.takeException(), isNull);
    });
  });
}

const _options = [
  ['매화 분홍', '소나무 청록', '유자 노랑', '먹색'],
  ['맑고 활기참', '흐리고 지침', '잔잔하고 평온', '설레고 두근거려요'],
  ['소중한 사람', '혼자', '가족', '친구'],
  ['부드러운', '바삭한', '쫀득한', '촉촉한'],
  ['봄', '여름', '가을', '겨울'],
  ['둥근 모양', '물결 모양', '직선 모양', '별·꽃 모양'],
];
