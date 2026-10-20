import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';
import 'package:haenggung_dagwa/data/quiz_questions.dart';
import 'package:haenggung_dagwa/l10n/lang.dart';
import 'package:haenggung_dagwa/screens/idle_screen.dart';
import 'package:haenggung_dagwa/screens/intro_screen.dart';
import 'package:haenggung_dagwa/screens/question_screen.dart';
import 'package:haenggung_dagwa/screens/result_screen.dart';
import 'package:haenggung_dagwa/screens/transition_screen.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/data/dagwa_tones.dart';
import 'package:haenggung_dagwa/widgets/kiosk/story_sheet.dart';
import 'package:haenggung_dagwa/widgets/kiosk/store_directions_sheet.dart';
import 'package:haenggung_dagwa/widgets/kiosk/bloom_backdrop.dart';
import 'package:haenggung_dagwa/widgets/kiosk/dangwa_image.dart';
import 'package:haenggung_dagwa/widgets/kiosk/kiosk_canvas.dart';
import 'package:haenggung_dagwa/widgets/kiosk/tap_cue.dart';

const _sizes = [
  Size(1024, 768),
  Size(1133, 744),
  Size(1180, 820),
  Size(1194, 834),
  Size(1210, 834),
  Size(1366, 1024),
  Size(1376, 1032),
  Size(1024, 600),
  Size(960, 600),
  Size(1920, 1080),
];

Widget _app(Widget child, double scale) => MaterialApp(
  theme: buildAppTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(
    body: KioskCanvas(background: const BloomBackdrop(), child: child),
  ),
);

/// Flutter can clip a paragraph without raising a RenderFlex overflow.
/// Compare its painted box with the height needed by the real font as well.
void _expectCompleteText(WidgetTester tester, Finder scope, String reason) {
  for (final element
      in find
          .descendant(of: scope, matching: find.byType(RichText))
          .evaluate()) {
    final paragraph = element.renderObject! as RenderParagraph;
    final painter =
        TextPainter(
          text: paragraph.text,
          textDirection: paragraph.textDirection,
          textScaler: paragraph.textScaler,
          maxLines: paragraph.maxLines,
          ellipsis: paragraph.overflow == TextOverflow.ellipsis ? '…' : null,
          locale: paragraph.locale,
          strutStyle: paragraph.strutStyle,
          textWidthBasis: paragraph.textWidthBasis,
          textHeightBehavior: paragraph.textHeightBehavior,
        )..layout(
          minWidth: paragraph.constraints.minWidth,
          maxWidth: paragraph.constraints.maxWidth,
        );
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: '$reason / ${paragraph.text.toPlainText()}',
    );
    expect(
      paragraph.size.height + 0.5,
      greaterThanOrEqualTo(painter.height),
      reason: '$reason / ${paragraph.text.toPlainText()}',
    );
    painter.dispose();
  }
}

void _setUpView(WidgetTester tester) {
  tester.view.devicePixelRatio = 2;
  tester.view.padding = const FakeViewPadding(bottom: 40);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      kSans,
    )..addFont(rootBundle.load('assets/fonts/PretendardVariable.ttf'))).load();
  });
  tearDown(() => appLang.value = Lang.ko);

  testWidgets(
    'start guidance stays complete and above the safe area at enlarged text sizes',
    (tester) async {
      _setUpView(tester);
      for (final screen in _sizes) {
        tester.view.physicalSize = screen * 2;
        for (final scale in [1.0, 1.2, 1.4, 1.6, 2.0]) {
          for (final lang in Lang.values) {
            appLang.value = lang;
            for (final child in [
              IdleScreen(onStart: () {}),
              IntroScreen(onStart: () {}, onHome: () {}),
            ]) {
              await tester.pumpWidget(_app(child, scale));
              await tester.pump(const Duration(milliseconds: 400));
              final reason =
                  '$screen / $scale / ${lang.name} / ${child.runtimeType}';
              expect(tester.takeException(), isNull, reason: reason);
              final cue = find.byType(TapCue);
              _expectCompleteText(
                tester,
                find.byType(child.runtimeType),
                reason,
              );
              final bounds = tester.getRect(cue);
              expect(
                bounds.bottom,
                lessThanOrEqualTo(screen.height - 20),
                reason: reason,
              );
              expect(bounds.left, greaterThanOrEqualTo(0), reason: reason);
              expect(
                bounds.right,
                lessThanOrEqualTo(screen.width),
                reason: reason,
              );
            }
          }
        }
      }
    },
  );

  testWidgets(
    'result footer grows evenly and keeps every translated line visible',
    (tester) async {
      _setUpView(tester);
      for (final screen in _sizes) {
        tester.view.physicalSize = screen * 2;
        for (final scale in [1.0, 1.2, 1.4, 1.6, 2.0]) {
          for (final lang in Lang.values) {
            appLang.value = lang;
            for (final menu in dagwaResults.keys) {
              await tester.pumpWidget(
                _app(
                  ResultScreen(
                    key: ValueKey(menu),
                    menuName: menu,
                    onRestart: () {},
                    onHome: () {},
                  ),
                  scale,
                ),
              );
              await tester.pump(const Duration(milliseconds: 400));
              final reason = '$screen / $scale / ${lang.name} / $menu';
              expect(tester.takeException(), isNull, reason: reason);
              final pickup = find.byKey(const ValueKey('pickup-notice'));
              final route = find.byKey(const ValueKey('store-route-card'));
              _expectCompleteText(tester, find.byType(ResultScreen), reason);
              final pickupBounds = tester.getRect(pickup);
              final routeBounds = tester.getRect(route);
              expect(
                pickupBounds.top,
                closeTo(routeBounds.top, .1),
                reason: reason,
              );
              expect(
                pickupBounds.bottom,
                closeTo(routeBounds.bottom, .1),
                reason: reason,
              );
              expect(
                pickupBounds.bottom,
                lessThanOrEqualTo(screen.height - 20),
                reason: reason,
              );
              final image = tester.widget<DangwaImage>(
                find.byType(DangwaImage),
              );
              final imageBounds = tester.getRect(
                find.descendant(
                  of: find.byType(DangwaImage),
                  matching: find.byType(AspectRatio),
                ),
              );
              expect(
                imageBounds.width / imageBounds.height,
                closeTo(image.aspectRatio, .001),
                reason: reason,
              );
            }
          }
        }
      }
    },
  );

  testWidgets(
    'all question choices remain usable after screen and text size changes',
    (tester) async {
      _setUpView(tester);
      for (final screen in _sizes) {
        tester.view.physicalSize = screen * 2;
        for (final scale in [1.0, 1.4, 1.6, 2.0]) {
          for (final lang in Lang.values) {
            appLang.value = lang;
            for (var index = 0; index < quizQuestions.length; index++) {
              String? selected;
              await tester.pumpWidget(
                _app(
                  QuestionScreen(
                    index: index,
                    question: quizQuestions[index],
                    selected: null,
                    onSelect: (option) => selected = option.title,
                    onBack: () {},
                    onHome: () {},
                  ),
                  scale,
                ),
              );
              await tester.pump(const Duration(milliseconds: 400));
              expect(
                tester.takeException(),
                isNull,
                reason: '$screen / $scale / ${lang.name} / q${index + 1}',
              );
              final reason = '$screen / $scale / ${lang.name} / q${index + 1}';
              for (final option in quizQuestions[index].options) {
                final card = find.byKey(ValueKey(option.title));
                await tester.scrollUntilVisible(
                  card,
                  100,
                  scrollable: find.descendant(
                    of: find.byType(GridView),
                    matching: find.byType(Scrollable),
                  ),
                );
                await tester.pump();
                _expectCompleteText(tester, card, reason);
                await tester.tap(
                  find.descendant(of: card, matching: find.byType(InkWell)),
                );
                expect(selected, option.title, reason: reason);
              }
              _expectCompleteText(tester, find.byType(QuestionScreen), reason);
            }
          }
        }
      }
    },
  );
  testWidgets(
    'transition messages remain complete while enlarged and changing steps',
    (tester) async {
      _setUpView(tester);
      for (final screen in _sizes) {
        tester.view.physicalSize = screen * 2;
        for (final scale in [1.0, 1.4, 2.0]) {
          for (final lang in Lang.values) {
            appLang.value = lang;
            final reason = '$screen / $scale / ${lang.name}';
            await tester.pumpWidget(
              _app(
                TransitionScreen(
                  key: ValueKey(reason),
                  menuName: '금귤정과',
                  onDone: () {},
                ),
                scale,
              ),
            );
            await tester.pump();
            for (var step = 0; step < 3; step++) {
              expect(tester.takeException(), isNull, reason: reason);
              _expectCompleteText(
                tester,
                find.byType(TransitionScreen),
                reason,
              );
              await tester.pump(const Duration(seconds: 1));
              await tester.pump(const Duration(milliseconds: 600));
            }
          }
        }
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'enlarged story and directions keep readable text and a reachable close button',
    (tester) async {
      _setUpView(tester);
      for (final screen in _sizes) {
        tester.view.physicalSize = screen * 2;
        for (final scale in [1.0, 1.4, 2.0]) {
          for (final lang in Lang.values) {
            appLang.value = lang;
            var closed = false;
            final reason = '$screen / $scale / ${lang.name}';
            final result = dagwaResults['금귤정과']!;
            await tester.pumpWidget(
              _app(
                StorySheet(
                  result: result,
                  tone: toneFor(result.menuName),
                  onClose: () => closed = true,
                ),
                scale,
              ),
            );
            await tester.pump(const Duration(milliseconds: 400));
            expect(tester.takeException(), isNull, reason: '$reason / story');
            _expectCompleteText(tester, find.byType(StorySheet), reason);
            final close = find.text(tr('닫기', 'Close', '閉じる')).last;
            expect(
              tester.getRect(close).bottom,
              lessThan(screen.height - 20),
              reason: reason,
            );
            await tester.tap(close);
            await tester.pump();
            expect(closed, isTrue);
            closed = false;
            await tester.pumpWidget(
              _app(StoreDirectionsSheet(onClose: () => closed = true), scale),
            );
            await tester.pump(const Duration(milliseconds: 400));
            expect(
              tester.takeException(),
              isNull,
              reason: '$reason / directions',
            );
            _expectCompleteText(
              tester,
              find.byKey(const ValueKey('store-directions-details')),
              reason,
            );
            final gotIt = find.text(tr('확인했어요', 'Got it', '確認しました'));
            expect(
              tester.getRect(gotIt).bottom,
              lessThan(screen.height - 20),
              reason: reason,
            );
            await tester.tap(gotIt);
            await tester.pump();
            expect(closed, isTrue);
          }
        }
      }
    },
  );
}
