import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/services/admin_settings.dart';
import 'package:haenggung_dagwa/services/dangwa_inventory.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';
import 'package:haenggung_dagwa/widgets/kiosk/admin_inventory_sheet.dart';
import 'package:haenggung_dagwa/widgets/kiosk/admin_pin_pad.dart';
import 'package:haenggung_dagwa/widgets/kiosk/kiosk_canvas.dart';
import 'release_review_test.dart' show MemoryInventoryPersistence;

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

Widget _app(Widget child, double scale) => MaterialApp(
  theme: buildAppTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(body: KioskCanvas(child: child)),
);

void main() {
  setUpAll(() async {
    await (FontLoader(
      kSans,
    )..addFont(rootBundle.load('assets/fonts/PretendardVariable.ttf'))).load();
  });
  testWidgets(
    'admin tabs remain readable and scrollable across iPad sizes and fonts',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(bottom: 20);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      for (final size in [
        const Size(1024, 768),
        const Size(1133, 744),
        const Size(1366, 1024),
      ]) {
        tester.view.physicalSize = size;
        for (final scale in [1.0, 1.4, 1.6, 2.0]) {
          final settings = AdminSettings();
          final inventory = DagwaInventory(
            persistence: MemoryInventoryPersistence(),
          );
          await tester.pumpWidget(
            _app(
              AdminInventorySheet(
                inventory: inventory,
                settings: settings,
                onClose: () {},
              ),
              scale,
            ),
          );
          await tester.pump();
          for (final tab in ['inventory', 'simple', 'advanced']) {
            await tester.tap(find.byKey(ValueKey('admin-tab-$tab')));
            await tester.pump(const Duration(milliseconds: 300));
            final reason = '$size / $scale / $tab';
            expect(tester.takeException(), isNull, reason: reason);
            _expectCompleteText(
              tester,
              find.byType(AdminInventorySheet),
              reason,
            );
            final list = find
                .descendant(
                  of: find.byType(AdminInventorySheet),
                  matching: find.byType(Scrollable),
                )
                .first;
            final last = find.byKey(
              ValueKey(switch (tab) {
                'inventory' => 'stock-흑임자다식',
                'simple' => 'level-흑임자다식',
                _ => 'weight-흑임자다식',
              }),
            );
            await tester.scrollUntilVisible(last, 120, scrollable: list);
            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull, reason: reason);
            _expectCompleteText(
              tester,
              find.byType(AdminInventorySheet),
              reason,
            );
            expect(
              tester.getRect(list).overlaps(tester.getRect(last)),
              isTrue,
              reason: reason,
            );
            expect(find.text('설정 완료').hitTestable(), findsOneWidget);
          }
          await tester.pumpWidget(const SizedBox());
          settings.dispose();
          inventory.dispose();
        }
      }
    },
  );

  testWidgets('PIN lock notice grows with text and cancel stays reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1133, 744);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final scale in [1.0, 1.4, 1.6, 2.0]) {
      final settings = AdminSettings();
      for (var i = 0; i < AdminSettings.maxFailures; i++) {
        settings.checkPin('0000');
      }
      var canceled = false;
      await tester.pumpWidget(
        _app(
          AdminPinPad(
            settings: settings,
            onCancel: () => canceled = true,
            onDone: () {},
          ),
          scale,
        ),
      );
      await tester.pump();
      _expectCompleteText(tester, find.byType(AdminPinPad), 'PIN scale $scale');
      expect(tester.takeException(), isNull);
      final cancel = find.byKey(const ValueKey('pin-cancel'));
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      expect(canceled, isTrue);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    }
  });
}
