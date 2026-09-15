import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';
import 'package:haenggung_dagwa/data/quiz_questions.dart';
import 'package:haenggung_dagwa/l10n/lang.dart';
import 'package:haenggung_dagwa/pages/kiosk_page.dart';
import 'package:haenggung_dagwa/screens/idle_screen.dart';
import 'package:haenggung_dagwa/screens/intro_screen.dart';
import 'package:haenggung_dagwa/screens/question_screen.dart';
import 'package:haenggung_dagwa/screens/result_screen.dart';
import 'package:haenggung_dagwa/screens/transition_screen.dart';

/// iPad Pro 12.9형(5세대) 가로 논리 해상도.
const _iPadLandscape = Size(1366, 1024);

Future<void> _pumpKiosk(WidgetTester tester) async {
  appLang.value = Lang.ko;
  tester.view.physicalSize = _iPadLandscape * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const MaterialApp(home: KioskPage()));
  await tester.pump(const Duration(milliseconds: 600));
}

/// 화면 전환 + 등장 애니메이션이 끝날 때까지 프레임을 흘린다.
Future<void> _settle(WidgetTester tester, [int ms = 1200]) async {
  for (var elapsed = 0; elapsed < ms; elapsed += 20) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<void> _tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  expect(finder, findsWidgets, reason: '"$label"을 찾지 못했다');
  await tester.tap(finder.first, warnIfMissed: false);
  await _settle(tester, 600);
}

void main() {
  testWidgets('전환 중 이전 화면과 다음 화면이 동시에 그려지지 않는다', (tester) async {
    await _pumpKiosk(tester);

    await tester.tap(find.text('취향 알아보기'));
    await tester.pump();

    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
      final mountedScreens =
          find.byType(IdleScreen).evaluate().length +
          find.byType(IntroScreen).evaluate().length;
      expect(mountedScreens, 1, reason: '$frame번째 전환 프레임');
    }

    expect(find.byType(IdleScreen), findsNothing);
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Idle → Intro → 6문항 → 전환 → 결과까지 예외 없이 진행된다', (tester) async {
    await _pumpKiosk(tester);

    // 01 · Idle
    expect(find.byType(IdleScreen), findsOneWidget);
    expect(find.text('오늘, 나와\n어울리는 다과는?'), findsOneWidget);

    // 화면 아무 곳이나 터치하면 Intro로
    await tester.tap(find.byType(IdleScreen), warnIfMissed: false);
    await _settle(tester);
    expect(find.byType(IntroScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 02 · Intro → 질문
    await _tapText(tester, '다과 추천 시작하기');
    await _settle(tester);
    expect(find.byType(QuestionScreen), findsOneWidget);

    // 03 · 6문항. 각 질문의 첫 선택지를 고른다.
    for (var i = 0; i < quizQuestions.length; i++) {
      expect(
        find.text(
          quizQuestions[i].before.ko +
              quizQuestions[i].keyword.ko +
              quizQuestions[i].after.ko,
        ),
        findsOneWidget,
        reason: '${i + 1}번째 질문 화면이 아니다',
      );

      final option = quizQuestions[i].options.first;
      await _tapText(tester, option.label.ko);
      expect(tester.takeException(), isNull, reason: '"${option.title}" 선택 직후');
    }

    // 전환 화면 → 결과
    expect(find.byType(TransitionScreen), findsOneWidget);
    await tester.pump(TransitionScreen.duration);
    await _settle(tester);

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.text('당신과 가장 잘 어울리는 다과'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: '결과 화면');
  });

  testWidgets('결과 화면에서 다과 이야기 시트를 열고 닫을 수 있다', (tester) async {
    await _pumpKiosk(tester);
    await tester.tap(find.byType(IdleScreen), warnIfMissed: false);
    await _settle(tester);
    await _tapText(tester, '다과 추천 시작하기');
    await _settle(tester);

    for (final q in quizQuestions) {
      await _tapText(tester, q.options.first.label.ko);
    }
    await _settle(tester, 600);
    await tester.pump(TransitionScreen.duration);
    await _settle(tester);

    await _tapText(tester, '이 다과 이야기 보기');
    await _settle(tester);
    expect(find.text('THE STORY'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _tapText(tester, '닫기');
    await _settle(tester);
    expect(find.text('THE STORY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('모든 다과의 결과 화면이 1366×1024에서 오버플로 없이 그려진다', (tester) async {
    tester.view.physicalSize = _iPadLandscape * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final menu in dagwaResults.keys) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: _iPadLandscape.width,
              height: _iPadLandscape.height,
              child: ResultScreen(
                menuName: menu,
                onRestart: () {},
                onHome: () {},
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: '$menu 결과 화면');
    }
  });
}
