import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/l10n/lang.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/widgets/kiosk/store_directions_sheet.dart';

Future<void> _pumpSheet(
  WidgetTester tester, {
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = const Size(2732, 2048);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(1366, 1024),
          disableAnimations: reduceMotion,
        ),
        child: Scaffold(body: StoreDirectionsSheet(onClose: () {})),
      ),
    ),
  );
}

void main() {
  tearDown(() => appLang.value = Lang.ko);

  testWidgets('지도 배경 위에 출발·도착과 주변 건물 이름을 보여 준다', (tester) async {
    for (final lang in Lang.values) {
      appLang.value = lang;
      await _pumpSheet(tester);
      await tester.pump(const Duration(seconds: 1));

      final map = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == 'assets/map/route_map.png',
      );
      expect(map, findsOneWidget);
      expect(
        find.text(tr('행궁다과 · 2층', 'Haenggung Dagwa · 2F', '行宮茶菓・2階')),
        findsOneWidget,
      );
      expect(
        find.text(tr('가회당 · 팝업', 'Gahoedang · Pop-up', 'カフェダン・ポップアップ')),
        findsOneWidget,
      );
      expect(find.text(tr('남양마트', 'Namyang Mart', 'ナミャンマート')), findsOneWidget);
      // 지도 위 도보 배지. 영어는 오른쪽 소요 시간과 문구가 같다.
      expect(find.text(tr('1분', '1 min', '1分')), findsWidgets);
      if (lang != Lang.ko) {
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .join();
        expect(RegExp(r'[가-힣]').hasMatch(texts), isFalse, reason: lang.label);
      }
      expect(tester.takeException(), isNull, reason: lang.label);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('상단 문구가 시트 가운데에 온다', (tester) async {
    await _pumpSheet(tester);
    await tester.pump(const Duration(seconds: 1));
    final sheet = tester.getRect(
      find
          .ancestor(
            of: find.byKey(const ValueKey('directions-eyebrow')),
            matching: find.byType(SizedBox),
          )
          .last,
    );
    final text = tester.getRect(
      find.byKey(const ValueKey('directions-eyebrow')),
    );
    expect(sheet.width, 1188);
    // 자간 보정(2.8)의 절반 이내로 가운데에 맞아야 한다.
    expect(text.center.dx - 1.4, closeTo(sheet.center.dx, 0.5));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('경로 애니메이션이 끝나지 않고 반복된다', (tester) async {
    await _pumpSheet(tester);
    for (var i = 0; i < 12 * 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    // 12초(세 바퀴 가까이)가 지나도 다음 프레임이 예약돼 있어야 한다.
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('동작 줄이기에서는 경로를 멈춘 채 보여 준다', (tester) async {
    await _pumpSheet(tester, reduceMotion: true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
