import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/pages/kiosk_page.dart';
import 'package:haenggung_dagwa/screens/idle_screen.dart';
import 'package:haenggung_dagwa/screens/intro_screen.dart';
import 'package:haenggung_dagwa/services/admin_settings.dart';
import 'package:haenggung_dagwa/services/dangwa_inventory.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/widgets/kiosk/admin_pin_pad.dart';

class _Settings implements AdminSettingsPersistence {
  @override
  Future<String?> loadPin() async => null;
  @override
  Future<void> savePin(String pin) async {}
  @override
  Future<Map<String, double>?> loadWeights() async => null;
  @override
  Future<void> saveWeights(Map<String, double> weights) async {}
}

class _Inventory implements DagwaInventoryPersistence {
  @override
  Future<Set<String>?> load() async => null;
  @override
  Future<void> save(Set<String> menus) async {}
}

void main() {
  testWidgets('Android 뒤로 가기로 앱이 닫히지 않고, 관리자 화면만 닫힌다', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final exits = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.pop') exits.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: KioskPage(
          inventory: DagwaInventory(persistence: _Inventory()),
          adminSettings: AdminSettings(persistence: _Settings()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(IdleScreen), findsOneWidget);
    expect(exits, isEmpty);

    await tester.longPress(find.byKey(const ValueKey('admin-entry')));
    await tester.pump();
    expect(find.byType(AdminPinPad), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AdminPinPad), findsNothing);
    expect(find.byType(IdleScreen), findsOneWidget);

    await tester.tap(find.byType(IdleScreen));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(IntroScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(exits, isEmpty);
  });
}
