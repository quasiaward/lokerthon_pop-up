import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';
import 'package:haenggung_dagwa/data/quiz_questions.dart';
import 'package:haenggung_dagwa/l10n/lang.dart';
import 'package:haenggung_dagwa/main.dart';
import 'package:haenggung_dagwa/pages/kiosk_page.dart';
import 'package:haenggung_dagwa/screens/idle_screen.dart';
import 'package:haenggung_dagwa/screens/intro_screen.dart';
import 'package:haenggung_dagwa/screens/question_screen.dart';
import 'package:haenggung_dagwa/screens/result_screen.dart';
import 'package:haenggung_dagwa/screens/transition_screen.dart';
import 'package:haenggung_dagwa/services/recommendation_engine.dart';
import 'package:haenggung_dagwa/services/recommendation_service.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/widgets/kiosk/brand_mark.dart';
import 'package:haenggung_dagwa/widgets/kiosk/choice_card.dart';
import 'package:haenggung_dagwa/widgets/kiosk/story_sheet.dart';
import 'package:haenggung_dagwa/widgets/kiosk/top_control.dart';
import 'package:haenggung_dagwa/widgets/kiosk/ambient_field.dart';
import 'package:haenggung_dagwa/widgets/kiosk/dangwa_image.dart';
import 'package:haenggung_dagwa/widgets/kiosk/rotating_dangwa_image.dart';
import 'package:haenggung_dagwa/widgets/kiosk/tap_cue.dart';

Future<void> frames(WidgetTester tester, [int ms = 800]) async {
  for (var time = 0; time < ms; time += 20) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void size(WidgetTester tester) {
  tester.view.physicalSize = const Size(2732, 2048);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> start(WidgetTester tester, {RecommendationEngine? engine}) async {
  size(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: KioskPage(service: RecommendationService(engine: engine)),
    ),
  );
  await frames(tester);
  await tester.tap(find.byType(IdleScreen));
  await frames(tester);
  await tester.tap(find.byType(IntroScreen));
  await frames(tester);
}

Future<void> answerAll(WidgetTester tester) async {
  for (final q in quizQuestions) {
    await tester.tap(find.text(q.options.first.label.t));
    await frames(tester);
  }
}

class PendingEngine implements RecommendationEngine {
  final result = Completer<String>();
  int calls = 0;
  @override
  Future<String> recommend(List<String> answers) {
    calls++;
    return result.future;
  }
}

class RetryEngine implements RecommendationEngine {
  int calls = 0;
  @override
  Future<String> recommend(List<String> answers) async {
    if (++calls == 1) throw StateError('test failure');
    return dagwaMenus.first;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      kSans,
    )..addFont(rootBundle.load('assets/fonts/PretendardVariable.ttf'))).load();
  });
  setUp(() => appLang.value = Lang.ko);
  tearDown(() => appLang.value = Lang.ko);

  testWidgets(
    'every question shows four complete cards in all three languages',
    (tester) async {
      size(tester);
      for (final lang in Lang.values) {
        appLang.value = lang;
        for (var i = 0; i < quizQuestions.length; i++) {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(),
              home: Scaffold(
                body: QuestionScreen(
                  index: i,
                  question: quizQuestions[i],
                  selected: null,
                  onSelect: (_) {},
                  onBack: () {},
                  onHome: () {},
                ),
              ),
            ),
          );
          await frames(tester, 40);
          expect(
            tester.takeException(),
            isNull,
            reason: '${lang.label} question ${i + 1}',
          );
          final grid = tester.getRect(find.byType(GridView));
          final cards = find.byType(ChoiceCard);
          expect(cards, findsNWidgets(4));
          for (var n = 0; n < 4; n++) {
            expect(
              grid.contains(
                tester.getBottomRight(cards.at(n)) - const Offset(.1, .1),
              ),
              isTrue,
              reason:
                  '${lang.label} question ${i + 1} card $n must not be clipped',
            );
          }
        }
      }
    },
  );

  testWidgets('start and back expose distinct accessible tap actions', (
    tester,
  ) async {
    size(tester);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: IntroScreen(onStart: () {}, onHome: () {}),
        ),
      ),
    );
    for (final label in ['이전으로', '화면을 터치해 다과 추천 질문 시작하기']) {
      final data = tester
          .getSemantics(find.bySemanticsLabel(label))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue, reason: label);
      expect(data.hasAction(SemanticsAction.tap), isTrue, reason: label);
    }
    semantics.dispose();
  });

  testWidgets(
    'reduced motion stops repeating effects and pauses image rotation',
    (tester) async {
      size(tester);
      Widget scene(bool reduced) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(
            body: Stack(
              children: [
                Positioned.fill(child: AmbientField()),
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(width: 300, child: RotatingDangwaImage()),
                ),
                Align(alignment: Alignment.bottomCenter, child: TapCue()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(scene(false));
      final initial = tester
          .widget<DangwaImage>(find.byType(DangwaImage))
          .assetPath;
      await tester.pump(const Duration(seconds: 5));
      await frames(tester);
      expect(
        tester.widget<DangwaImage>(find.byType(DangwaImage)).assetPath,
        isNot(initial),
      );
      await tester.pumpWidget(scene(true));
      await frames(tester);
      final paused = tester
          .widget<DangwaImage>(find.byType(DangwaImage))
          .assetPath;
      await tester.pump(const Duration(seconds: 10));
      expect(
        tester.widget<DangwaImage>(find.byType(DangwaImage)).assetPath,
        paused,
      );
      expect(tester.binding.transientCallbackCount, 0);
      await tester.pumpWidget(scene(false));
      await tester.pump(const Duration(seconds: 5));
      await frames(tester);
      expect(
        tester.widget<DangwaImage>(find.byType(DangwaImage)).assetPath,
        isNot(paused),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'live language changes update both screens without starting the quiz',
    (tester) async {
      size(tester);
      await tester.pumpWidget(const DagwaRecommendationApp());
      await frames(tester);
      for (final lang in [Lang.en, Lang.ja, Lang.ko]) {
        await tester.tap(find.text(lang.label));
        await frames(tester);
        expect(find.byType(IdleScreen), findsOneWidget);
        final title = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .join();
        expect(title.contains('오늘, 나와'), lang == Lang.ko);
      }
      await tester.tap(find.byType(IdleScreen));
      await frames(tester);
      for (final lang in [Lang.en, Lang.ja, Lang.ko]) {
        await tester.tap(find.text(lang.label));
        await frames(tester);
        expect(find.byType(IntroScreen), findsOneWidget);
        expect(
          find.text(
            tr(
              '몇 가지 취향을\n알려주세요.',
              'Tell us a few\nof your tastes.',
              'いくつかの好みを\n教えてください。',
            ),
          ),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('intro edges start once and back remains independent', (
    tester,
  ) async {
    size(tester);
    for (final point in [
      const Offset(20, 500),
      const Offset(1340, 500),
      const Offset(680, 1000),
    ]) {
      var starts = 0;
      var backs = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: IntroScreen(
              key: UniqueKey(),
              onStart: () => starts++,
              onHome: () => backs++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('이전으로'));
      await frames(tester, 200);
      expect(backs, 1);
      expect(starts, 0);
      await tester.tapAt(point);
      await tester.tapAt(point);
      await frames(tester, 200);
      expect(starts, 1, reason: 'edge $point');
    }
  });

  testWidgets('header logo stays centered with every language and back state', (
    tester,
  ) async {
    size(tester);
    for (final lang in Lang.values) {
      appLang.value = lang;
      for (final back in [true, false]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: TopControl(onBack: back ? () {} : null, onHome: () {}),
            ),
          ),
        );
        expect(
          tester.getCenter(find.byType(BrandMark)).dx,
          closeTo(683, .1),
          reason: '${lang.label} back=$back',
        );
      }
    }
  });

  testWidgets(
    'all results and stories fit and stay localized in three languages',
    (tester) async {
      size(tester);
      for (final lang in Lang.values) {
        appLang.value = lang;
        for (final menu in dagwaResults.keys) {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(),
              home: Scaffold(
                body: ResultScreen(
                  key: ValueKey('${lang.name}-$menu'),
                  menuName: menu,
                  onRestart: () {},
                  onHome: () {},
                ),
              ),
            ),
          );
          await frames(tester, 40);
          expect(
            tester.takeException(),
            isNull,
            reason: '${lang.label} $menu result',
          );
          await tester.tap(
            find.text(tr('이 다과 이야기 보기', 'Read the story', 'この茶菓の物語を読む')),
          );
          await frames(tester, 500);
          expect(
            tester.takeException(),
            isNull,
            reason: '${lang.label} $menu story',
          );
          if (lang != Lang.ko) {
            final storyText = tester
                .widgetList<Text>(
                  find.descendant(
                    of: find.byType(StorySheet),
                    matching: find.byType(Text),
                  ),
                )
                .map((t) => t.data ?? '')
                .join();
            expect(
              RegExp(r'[가-힣]').hasMatch(storyText),
              isFalse,
              reason: '${lang.label} $menu story',
            );
          }
        }
      }
    },
  );

  testWidgets(
    'rapid choices advance once and back retains the selected answer',
    (tester) async {
      await start(tester);
      final option = find.text(quizQuestions.first.options.first.label.t);
      await tester.tap(option);
      await tester.tap(option);
      await frames(tester);
      expect(
        tester.widget<QuestionScreen>(find.byType(QuestionScreen)).index,
        1,
      );
      await tester.tap(find.text('이전으로'));
      await frames(tester);
      expect(
        tester.widget<QuestionScreen>(find.byType(QuestionScreen)).index,
        0,
      );
      expect(
        tester
            .widgetList<ChoiceCard>(find.byType(ChoiceCard))
            .where((c) => c.selected)
            .single
            .option
            .title,
        quizQuestions.first.options.first.title,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('a delayed recommendation cannot reopen an expired session', (
    tester,
  ) async {
    final engine = PendingEngine();
    await start(tester, engine: engine);
    await answerAll(tester);
    expect(engine.calls, 1);
    await tester.pump(const Duration(seconds: 46));
    expect(find.byType(IdleScreen), findsOneWidget);
    engine.result.complete(dagwaMenus.first);
    await frames(tester);
    expect(find.byType(IdleScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'failed recommendation retries and an open story resets after inactivity',
    (tester) async {
      final engine = RetryEngine();
      await start(tester, engine: engine);
      await answerAll(tester);
      expect(find.byType(QuestionScreen), findsOneWidget);
      expect(
        tester.widget<QuestionScreen>(find.byType(QuestionScreen)).error,
        isNotNull,
      );
      await tester.tap(find.text(quizQuestions.last.options.first.label.t));
      await frames(tester);
      await tester.pump(TransitionScreen.duration);
      await frames(tester);
      expect(engine.calls, 2);
      expect(find.byType(ResultScreen), findsOneWidget);
      await tester.tap(find.text('이 다과 이야기 보기'));
      await frames(tester);
      expect(find.byType(StorySheet), findsOneWidget);
      await tester.pump(const Duration(seconds: 46));
      expect(find.byType(IdleScreen), findsOneWidget);
      expect(find.byType(StorySheet), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
