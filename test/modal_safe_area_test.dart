import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';
import 'package:haenggung_dagwa/data/dagwa_tones.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/widgets/kiosk/kiosk_canvas.dart';
import 'package:haenggung_dagwa/widgets/kiosk/story_sheet.dart';
import 'package:haenggung_dagwa/widgets/kiosk/store_directions_sheet.dart';

Future<void> _expectEvenBottom(WidgetTester tester, GlobalKey key) async {
  final result = await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = (await image.toByteData(
      format: ImageByteFormat.rawRgba,
    ))!.buffer.asUint8List();
    List<int> pixel(int y) {
      final offset = (y * image.width + 2) * 4;
      return bytes.sublist(offset, offset + 4);
    }

    final colors = [pixel(image.height - 40), pixel(image.height - 2)];
    image.dispose();
    return colors;
  });
  expect(result![0], result[1], reason: '하단 안전 영역 안팎의 덮개 색이 같아야 합니다.');
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      kSans,
    )..addFont(rootBundle.load('assets/fonts/PretendardVariable.ttf'))).load();
  });

  testWidgets(
    'modal dimming stays continuous while opening, closing and resizing',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      for (final story in [true, false]) {
        final key = GlobalKey();
        var closed = false;
        final Widget sheet = story
            ? StorySheet(
                result: dagwaResults['금귤정과']!,
                tone: toneFor('금귤정과'),
                onClose: () => closed = true,
              )
            : StoreDirectionsSheet(onClose: () => closed = true);
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              theme: buildAppTheme(),
              home: Scaffold(
                body: KioskCanvas(
                  background: const ColoredBox(color: Colors.amber),
                  child: sheet,
                ),
              ),
            ),
          ),
        );
        for (final elapsed in [0, 160, 800]) {
          await tester.pump(Duration(milliseconds: elapsed));
          await _expectEvenBottom(tester, key);
        }
        tester.view.physicalSize = const Size(1133, 744);
        await tester.pump();
        await _expectEvenBottom(tester, key);
        await tester.tapAt(const Offset(2, 742));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await _expectEvenBottom(tester, key);
        await tester.pump(const Duration(milliseconds: 400));
        expect(closed, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        tester.view.physicalSize = const Size(1024, 768);
      }
    },
  );

  for (final story in [true, false]) {
    testWidgets(
      '${story ? 'story' : 'directions'} dims and dismisses across the entire screen',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        for (final size in [
          const Size(1024, 768),
          const Size(1133, 744),
          const Size(1366, 1024),
          const Size(960, 600),
        ]) {
          tester.view.physicalSize = size;
          tester.view.padding = const FakeViewPadding(
            left: 12,
            top: 24,
            right: 16,
            bottom: 34,
          );
          var closed = false;
          final Widget sheet = story
              ? StorySheet(
                  result: dagwaResults['금귤정과']!,
                  tone: toneFor('금귤정과'),
                  onClose: () => closed = true,
                )
              : StoreDirectionsSheet(onClose: () => closed = true);
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: Scaffold(
                body: KioskCanvas(
                  background: const ColoredBox(color: Colors.amber),
                  child: sheet,
                ),
              ),
            ),
          );
          await tester.pump();
          final barrier = find.descendant(
            of: find.byWidget(sheet),
            matching: find.byType(ModalBarrier),
          );
          expect(tester.getRect(barrier), Offset.zero & size, reason: '$size');
          expect(tester.takeException(), isNull);
          // Bottom inset must be both dimmed and dismissible, not a bright strip.
          await tester.tapAt(Offset(4, size.height - 2));
          await tester.pump();
          expect(closed, isTrue, reason: '$size');
          await tester.pumpWidget(const SizedBox());
        }
      },
    );
  }
}
