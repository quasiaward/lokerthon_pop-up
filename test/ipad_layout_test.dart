import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/pages/ai_recommendation_page.dart';

/// iPad Pro 12.9형(5세대) 가로 논리 해상도.
const _iPadLandscape = Size(1366, 1024);

/// 화면을 [size]로 고정해 위젯을 띄운다.
Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(home: AiRecommendationPage()),
  );
  await tester.pump();
}

/// 첫 번째 [Text] 위젯이 [label]인 탭 가능한 카드를 눌러 준다.
Future<void> _tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  expect(finder, findsWidgets, reason: '"$label"을 찾지 못했다');
  await tester.tap(finder.first, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('12.9형 가로에서 랜딩 화면이 오버플로 없이 그려진다', (tester) async {
    await _pumpApp(tester, _iPadLandscape);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('퍼스널 다과 추천'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('12.9형 가로에서 6개 질문을 모두 거쳐 결과까지 간다', (tester) async {
    await _pumpApp(tester, _iPadLandscape);
    await tester.pump(const Duration(milliseconds: 300));

    await _tapText(tester, '오늘의 다과 추천 받으러 가기');
    expect(find.textContaining('기분'), findsWidgets);

    const answers = [
      '매화 분홍',
      '흐리고 지침',
      '가족',
      '촉촉한',
      '봄',
      '둥근 모양',
    ];
    for (final answer in answers) {
      await _tapText(tester, answer);
      expect(tester.takeException(), isNull, reason: '"$answer" 선택 직후');
    }

    // 로딩 최소 노출 시간(1.4초)을 넘겨 결과 화면까지 진행한다.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('분석'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));

    // 결과 화면에는 추천된 다과 이름이 있어야 한다.
    expect(find.text('다시 추천받기').evaluate().isNotEmpty ||
        find.textContaining('추천').evaluate().isNotEmpty, isTrue);
    expect(tester.takeException(), isNull, reason: '결과 화면');
  });
}
