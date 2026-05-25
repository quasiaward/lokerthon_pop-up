import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa_flutter/main.dart';

void main() {
  testWidgets('captures desktop first fold for Figma AI', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;

    const captureKey = ValueKey('figma-desktop-first-fold');
    await tester.pumpWidget(
      const RepaintBoundary(
        key: captureKey,
        child: HaenggungDagwaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(captureKey),
      matchesGoldenFile('screenshots/haenggung_desktop_first_fold.png'),
    );
  });

  testWidgets('captures desktop long page for Figma AI', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(1440, 6800);
    tester.view.devicePixelRatio = 1;

    const captureKey = ValueKey('figma-desktop-long-page');
    await tester.pumpWidget(
      const RepaintBoundary(
        key: captureKey,
        child: HaenggungDagwaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(captureKey),
      matchesGoldenFile('screenshots/haenggung_desktop_long_page.png'),
    );
  });
}
