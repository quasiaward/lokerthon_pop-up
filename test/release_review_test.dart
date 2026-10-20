import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsNode;
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
import 'package:haenggung_dagwa/services/dangwa_inventory.dart';
import 'package:haenggung_dagwa/services/recommendation_engine.dart';
import 'package:haenggung_dagwa/services/recommendation_service.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/widgets/kiosk/brand_mark.dart';
import 'package:haenggung_dagwa/widgets/kiosk/choice_card.dart';
import 'package:haenggung_dagwa/widgets/kiosk/story_sheet.dart';
import 'package:haenggung_dagwa/widgets/kiosk/store_directions_sheet.dart';
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

Future<void> start(
  WidgetTester tester, {
  RecommendationEngine? engine,
  DagwaInventory? inventory,
}) async {
  size(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: KioskPage(
        service: RecommendationService(engine: engine),
        inventory: inventory,
      ),
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

class MemoryInventoryPersistence implements DagwaInventoryPersistence {
  Set<String>? stored;

  @override
  Future<Set<String>?> load() async => stored?.toSet();

  @override
  Future<void> save(Set<String> menus) async => stored = menus.toSet();
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
    'VoiceOver story, scroll and close actions renew inactivity timeout',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = tester.ensureSemantics();
      await start(tester);
      await answerAll(tester);
      await tester.pump(TransitionScreen.duration);
      await frames(tester);
      await tester.ensureVisible(find.widgetWithText(InkWell, '이 다과 이야기 보기'));
      await frames(tester);
      await tester.pump(const Duration(seconds: 40));

      void activate(Finder target) {
        final node = tester.getSemantics(target);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
          node.id,
          SemanticsAction.tap,
        );
      }

      activate(find.widgetWithText(InkWell, '이 다과 이야기 보기'));
      await frames(tester);
      await tester.pump(const Duration(seconds: 6));
      expect(find.byType(StorySheet), findsOneWidget);
      expect(find.byType(IdleScreen), findsNothing);

      // Assistive scroll actions also have no pointer-down event.
      await tester.pump(const Duration(seconds: 33));
      final scrollable = find
          .descendant(
            of: find.byType(StorySheet),
            matching: find.byType(Scrollable),
          )
          .first;
      SemanticsNode? scrollNode;
      void visit(SemanticsNode node) {
        if (node.getSemanticsData().hasAction(SemanticsAction.scrollUp)) {
          scrollNode = node;
        }
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(
        tester
            .binding
            .renderViews
            .single
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!,
      );
      expect(scrollNode, isNotNull);
      tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
        scrollNode!.id,
        SemanticsAction.scrollUp,
      );
      await frames(tester);
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(0),
      );
      await tester.pump(const Duration(seconds: 6));
      expect(find.byType(StorySheet), findsOneWidget);

      await tester.pump(const Duration(seconds: 33));
      activate(
        find.descendant(
          of: find.byType(StorySheet),
          matching: find.byType(IconButton),
        ),
      );
      await frames(tester);
      await tester.pump(const Duration(seconds: 6));
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.byType(IdleScreen), findsNothing);
      await tester.pump(const Duration(seconds: 40));
      await frames(tester);
      expect(find.byType(IdleScreen), findsOneWidget);
      semantics.dispose();
    },
  );

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
        expect(title.contains('오늘, 나에게'), lang == Lang.ko);
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

  testWidgets(
    'a long press opens inventory settings and hides sold-out items',
    (tester) async {
      size(tester);
      final inventory = DagwaInventory(
        persistence: MemoryInventoryPersistence(),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: KioskPage(inventory: inventory),
        ),
      );
      await frames(tester);

      await tester.longPress(find.byKey(const ValueKey('admin-entry')));
      await frames(tester, 300);
      // 관리자 설정은 암호(초기값 2003)를 거쳐야 열린다.
      for (final digit in '2003'.split('')) {
        await tester.tap(find.byKey(ValueKey('pin-key-$digit')));
        await tester.pump();
      }
      await frames(tester, 300);
      expect(
        find.byKey(const ValueKey('admin-inventory-sheet')),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsNWidgets(activeDagwaMenus.length));

      final soldOut = activeDagwaMenus.first;
      await tester.tap(find.byType(Switch).first);
      await frames(tester, 300);
      expect(inventory.value, isNot(contains(soldOut)));

      await tester.tap(find.text('설정 완료'));
      await frames(tester, 300);
      expect(find.byKey(const ValueKey('admin-inventory-sheet')), findsNothing);
      expect(
        tester
            .widget<RotatingDangwaImage>(find.byType(RotatingDangwaImage))
            .menus,
        isNot(contains(soldOut)),
      );
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
    'store route card opens and closes the illustrated in-app guide',
    (tester) async {
      size(tester);
      for (final lang in Lang.values) {
        appLang.value = lang;
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: ResultScreen(
                key: ValueKey('route-${lang.name}'),
                menuName: activeDagwaMenus.first,
                onRestart: () {},
                onHome: () {},
              ),
            ),
          ),
        );
        await frames(tester, 40);

        await tester.tap(
          find.text(
            tr('행궁다과도 만나보세요', 'Visit Haenggung Dagwa', '行宮茶菓にもお立ち寄りください'),
          ),
        );
        await frames(tester, 800);

        expect(find.byType(StoreDirectionsSheet), findsOneWidget);
        expect(
          find.text(
            tr(
              '행궁다과까지\n걸어서 1분이에요',
              'Haenggung Dagwa is\njust a 1-minute walk',
              '行宮茶菓まで\n歩いて約1分です',
            ),
          ),
          findsOneWidget,
        );
        expect(find.text('98 m'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: lang.label);

        if (lang != Lang.ko) {
          final routeText = tester
              .widgetList<Text>(
                find.descendant(
                  of: find.byType(StoreDirectionsSheet),
                  matching: find.byType(Text),
                ),
              )
              .map((text) => text.data ?? '')
              .join();
          expect(RegExp(r'[가-힣]').hasMatch(routeText), isFalse);
        }

        await tester.tap(find.text(tr('확인했어요', 'Got it', '確認しました')));
        await frames(tester, 400);
        expect(find.byType(StoreDirectionsSheet), findsNothing);
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
