import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/widgets/kiosk/choice_card.dart';
import 'package:haenggung_dagwa/widgets/kiosk/kiosk_button.dart';
import 'package:haenggung_dagwa/widgets/kiosk/kiosk_canvas.dart';
import 'package:haenggung_dagwa/widgets/kiosk/story_sheet.dart';
import 'package:haenggung_dagwa/widgets/kiosk/store_directions_sheet.dart';

const _landscapeSizes = [
  Size(1024, 768),
  Size(1133, 744),
  Size(1180, 820),
  Size(1194, 834),
  Size(1210, 834),
  Size(1366, 1024),
  Size(1376, 1032),
  Size(1024, 600),
];

Widget _app(Widget child) => MaterialApp(
  theme: buildAppTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(body: KioskCanvas(child: child)),
);

Future<void> _frames(WidgetTester tester, [int ms = 200]) async {
  for (var elapsed = 0; elapsed < ms; elapsed += 20) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void _setUpView(WidgetTester tester) {
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      kSans,
    )..addFont(rootBundle.load('assets/fonts/PretendardVariable.ttf'))).load();
  });
  tearDown(() => appLang.value = Lang.ko);

  testWidgets('all four answers stay visible and tappable across iPad sizes', (
    tester,
  ) async {
    _setUpView(tester);

    for (final screen in _landscapeSizes) {
      tester.view.physicalSize = screen * 2;
      for (final lang in Lang.values) {
        appLang.value = lang;
        for (var index = 0; index < quizQuestions.length; index++) {
          String? selected;
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(),
              home: Scaffold(
                body: KioskCanvas(
                  child: QuestionScreen(
                    index: index,
                    question: quizQuestions[index],
                    selected: null,
                    onSelect: (option) => selected = option.title,
                    onBack: () {},
                    onHome: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          final reason = '$screen / ${lang.name} / question ${index + 1}';
          expect(tester.takeException(), isNull, reason: reason);
          final grid = tester.getRect(find.byType(GridView));
          final cards = find.byType(ChoiceCard);
          expect(cards, findsNWidgets(4), reason: reason);
          for (var card = 0; card < 4; card++) {
            final bounds = tester.getRect(cards.at(card));
            expect(
              grid.inflate(0.1).contains(bounds.topLeft),
              isTrue,
              reason: '$reason / card $card top',
            );
            expect(
              grid.inflate(0.1).contains(bounds.bottomRight),
              isTrue,
              reason: '$reason / card $card bottom',
            );
            await tester.tap(
              find.descendant(
                of: cards.at(card),
                matching: find.byType(InkWell),
              ),
            );
            expect(
              selected,
              quizQuestions[index].options[card].title,
              reason: '$reason / card $card tap',
            );
          }
        }
      }
    }
  });

  testWidgets(
    'canvas fills the available area while respecting system insets',
    (tester) async {
      _setUpView(tester);
      tester.view.padding = const FakeViewPadding(
        left: 48,
        top: 24,
        right: 24,
        bottom: 40,
      );
      addTearDown(tester.view.resetPadding);
      const marker = ValueKey('canvas-content');
      for (final screen in [..._landscapeSizes, const Size(1200, 940)]) {
        tester.view.physicalSize = screen * 2;
        await tester.pumpWidget(_app(const SizedBox.expand(key: marker)));
        final bounds = tester.getRect(find.byKey(marker));
        expect(bounds.left, closeTo(24, 0.01));
        expect(bounds.top, closeTo(12, 0.01));
        expect(bounds.right, closeTo(screen.width - 12, 0.01));
        expect(bounds.bottom, closeTo(screen.height - 20, 0.01));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'all results and their sheets fit each iPad size in three languages',
    (tester) async {
      _setUpView(tester);
      for (final screen in _landscapeSizes) {
        tester.view.physicalSize = screen * 2;
        for (final lang in Lang.values) {
          appLang.value = lang;
          for (final menu in dagwaResults.keys) {
            final reason = '$screen / ${lang.name} / $menu';
            await tester.pumpWidget(
              _app(
                ResultScreen(
                  key: ValueKey('$screen-${lang.name}-$menu'),
                  menuName: menu,
                  onRestart: () {},
                  onHome: () {},
                ),
              ),
            );
            await _frames(tester);
            expect(tester.takeException(), isNull, reason: reason);
            final viewport = Offset.zero & screen;
            final buttons = find.byType(KioskButton);
            for (var index = 0; index < buttons.evaluate().length; index++) {
              final bounds = tester.getRect(buttons.at(index));
              expect(viewport.contains(bounds.topLeft), isTrue, reason: reason);
              expect(
                viewport.contains(bounds.bottomRight),
                isTrue,
                reason: reason,
              );
            }

            // 한 기기·언어마다 상세와 지도를 실제로 열고 닫는다.
            if (menu != dagwaResults.keys.first) continue;
            await tester.tap(
              find.text(tr('이 다과 이야기 보기', 'Read the story', 'この茶菓の物語を読む')),
            );
            await _frames(tester);
            expect(find.byType(StorySheet), findsOneWidget, reason: reason);
            expect(tester.takeException(), isNull, reason: '$reason / story');
            await tester.tap(find.text(tr('닫기', 'Close', '閉じる')).last);
            await _frames(tester);
            expect(find.byType(StorySheet), findsNothing);
            await tester.tap(
              find.text(
                tr('행궁다과도 만나보세요', 'Visit Haenggung Dagwa', '行宮茶菓にもお立ち寄りください'),
              ),
            );
            await _frames(tester);
            expect(
              find.byType(StoreDirectionsSheet),
              findsOneWidget,
              reason: reason,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '$reason / directions',
            );
            await tester.tap(
              find.descendant(
                of: find.byType(StoreDirectionsSheet),
                matching: find.byType(IconButton),
              ),
            );
            await _frames(tester);
            expect(find.byType(StoreDirectionsSheet), findsNothing);
          }
        }
      }
    },
  );

  testWidgets(
    'background branch reaches the screen bottom outside the safe area',
    (tester) async {
      _setUpView(tester);
      tester.view.padding = const FakeViewPadding(bottom: 40);
      addTearDown(tester.view.resetPadding);
      for (final screen in _landscapeSizes) {
        tester.view.physicalSize = screen * 2;
        await tester.pumpWidget(
          MaterialApp(theme: buildAppTheme(), home: const KioskPage()),
        );
        await _frames(tester);
        final branch = find.byWidgetPredicate((widget) {
          if (widget is! Image) return false;
          final provider = widget.image;
          final source = provider is ResizeImage
              ? provider.imageProvider
              : provider;
          return source is AssetImage &&
              source.assetName ==
                  'assets/figma/deco/deco_watercolor_pink_branch.png';
        });
        expect(branch, findsOneWidget);
        expect(
          tester.getRect(branch).bottom,
          closeTo(screen.height, 0.01),
          reason:
              '$screen: the background must continue behind the home indicator',
        );
        final cue = tester.getRect(
          find.byKey(const ValueKey('tap-cue-surface')),
        );
        expect(cue.bottom, lessThanOrEqualTo(screen.height - 20));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'resizing during a quiz preserves the answer and finishes the flow',
    (tester) async {
      _setUpView(tester);
      tester.view.physicalSize = _landscapeSizes.first * 2;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const KioskPage(),
        ),
      );
      await _frames(tester);
      await tester.tap(find.byType(IdleScreen));
      await _frames(tester);
      await tester.tap(find.byType(IntroScreen));
      await _frames(tester);
      await tester.tap(find.text(quizQuestions.first.options.last.label.ko));
      await _frames(tester);
      tester.view.physicalSize = const Size(1133, 744) * 2;
      await _frames(tester);
      expect(
        tester.widget<QuestionScreen>(find.byType(QuestionScreen)).index,
        1,
      );
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await _frames(tester);
      expect(
        tester.widget<QuestionScreen>(find.byType(QuestionScreen)).selected,
        quizQuestions.first.options.last.title,
      );
      for (var index = 0; index < quizQuestions.length; index++) {
        tester.view.physicalSize = _landscapeSizes[index] * 2;
        await _frames(tester);
        await tester.tap(find.text(quizQuestions[index].options.last.label.ko));
        await _frames(tester);
        expect(tester.takeException(), isNull);
      }
      await tester.pump(TransitionScreen.duration);
      await _frames(tester);
      expect(find.byType(ResultScreen), findsOneWidget);
      await tester.tap(find.text('다시 추천받기'));
      await _frames(tester);
      expect(find.byType(IntroScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
