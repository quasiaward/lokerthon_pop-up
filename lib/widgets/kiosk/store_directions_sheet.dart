import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'brand_mark.dart';
import 'glass_surface.dart';
import 'kiosk_button.dart';

/// 팝업 장소에서 행궁다과까지의 짧은 도보 경로를 앱 안에서 보여 주는 안내 시트.
/// 실제 지도 대신 거리의 구조와 출발·도착 관계만 남긴 안내 그림으로 빠르게 읽힌다.
class StoreDirectionsSheet extends StatefulWidget {
  const StoreDirectionsSheet({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<StoreDirectionsSheet> createState() => _StoreDirectionsSheetState();
}

class _StoreDirectionsSheetState extends State<StoreDirectionsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
    reverseDuration: Motion.base,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.emphasized,
    reverseCurve: Curves.easeInCubic,
  );
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed && !_closing) {
      _controller.forward();
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      try {
        await _controller.reverse().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (mounted) widget.onClose();
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    scopesRoute: true,
    explicitChildNodes: true,
    namesRoute: true,
    label: tr('행궁다과 길 안내', 'Directions to Haenggung Dagwa', '行宮茶菓への道案内'),
    child: Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _curve,
            child: ModalBarrier(
              color: AppColors.accentDeep.withValues(alpha: 0.38),
              dismissible: true,
              onDismiss: _close,
              semanticsLabel: tr('닫기', 'Close', '閉じる'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(_curve),
            child: ScaleTransition(
              scale: Tween(begin: 0.985, end: 1.0).animate(_curve),
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: GlassSurface(
                  radius: Radii.sheet,
                  strong: true,
                  blurBackdrop: true,
                  child: SizedBox(
                    width: 1188,
                    height: 824,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(44, 18, 44, 34),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 54,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.lineStrong.withValues(
                                  alpha: 0.42,
                                ),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const BrandMark(compact: true),
                              const Spacer(),
                              Text(
                                'A SHORT WALK',
                                style: Type.eyebrow(
                                  AppColors.accent,
                                  tracking: 2.8,
                                ),
                              ),
                              const Spacer(),
                              Semantics(
                                button: true,
                                label: tr('닫기', 'Close', '閉じる'),
                                child: IconButton.filledTonal(
                                  onPressed: _close,
                                  icon: const Icon(Icons.close_rounded),
                                  iconSize: 26,
                                  style: IconButton.styleFrom(
                                    fixedSize: const Size(50, 50),
                                    backgroundColor: AppColors.accentSoft,
                                    foregroundColor: AppColors.accentDeep,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: _RouteIllustration(progress: _curve),
                                ),
                                const SizedBox(width: 34),
                                Expanded(
                                  flex: 4,
                                  child: _RouteDetails(onClose: _close),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RouteIllustration extends StatelessWidget {
  const _RouteIllustration({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: tr(
      '가회당에서 행궁로를 따라 행궁다과 2층까지 이동하는 길 안내 그림',
      'Illustrated route from Gahoedang along Haenggung-ro to Haenggung Dagwa on the second floor',
      'カフェダンから行宮路を通り、行宮茶菓2階までの案内図',
    ),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.ground.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) => Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _RouteMapPainter(progress.value)),
              ),
              Positioned(
                left: 30,
                top: 36,
                child: _PlaceLabel(
                  eyebrow: tr('출발', 'START', '出発'),
                  title: tr('가회당 · 팝업', 'Gahoedang · Pop-up', 'カフェダン・ポップアップ'),
                  detail: tr('행궁로 33', '33 Haenggung-ro', '行宮路33'),
                  icon: Icons.storefront_rounded,
                  color: AppColors.celadon,
                ),
              ),
              Positioned(
                right: 30,
                bottom: 34,
                child: _PlaceLabel(
                  eyebrow: tr('도착', 'ARRIVE', '到着'),
                  title: tr('행궁다과 · 2층', 'Haenggung Dagwa · 2F', '行宮茶菓・2階'),
                  detail: tr('행궁로 25', '25 Haenggung-ro', '行宮路25'),
                  icon: Icons.location_on_rounded,
                  color: AppColors.accent,
                  alignEnd: true,
                ),
              ),
              Center(
                child: Transform.rotate(
                  angle: -0.16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      tr('행궁로', 'HAENGGUNG-RO', '行宮路'),
                      style: Type.eyebrow(
                        AppColors.muted,
                        latin: isEn,
                        size: 12,
                        tracking: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PlaceLabel extends StatelessWidget {
  const _PlaceLabel({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    this.alignEnd = false,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 250),
    padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentDeep.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: alignEnd ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 11),
        Flexible(
          child: Column(
            crossAxisAlignment: alignEnd
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Type.eyebrow(
                  color,
                  latin: isEn,
                  size: 11,
                  tracking: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
                style: Type.section.copyWith(fontSize: 18),
              ),
              Text(
                detail,
                textDirection: TextDirection.ltr,
                style: Type.caption.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RouteDetails extends StatelessWidget {
  const _RouteDetails({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        tr(
          '행궁다과까지\n걸어서 1분이에요',
          'Haenggung Dagwa is\njust a 1-minute walk',
          '行宮茶菓まで\n歩いて約1分です',
        ),
        style: Type.question.copyWith(fontSize: 38, height: 1.2),
      ),
      const SizedBox(height: 12),
      Text(
        tr(
          '팝업을 나와 행궁로를 따라 98m만 걸어오세요.',
          'Leave the pop-up and follow Haenggung-ro for 98 m.',
          'ポップアップを出て、行宮路を98mほどお進みください。',
        ),
        style: Type.bodyMuted.copyWith(fontSize: 18, height: 1.48),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          _RouteMetric(
            icon: Icons.directions_walk_rounded,
            value: tr('약 1분', '1 min', '約1分'),
          ),
          const SizedBox(width: 10),
          _RouteMetric(icon: Icons.route_rounded, value: '98 m'),
        ],
      ),
      const SizedBox(height: 20),
      _RouteStep(
        number: '1',
        title: tr('팝업에서 출발', 'Leave the pop-up', 'ポップアップを出発'),
        body: tr(
          '가회당에서 나와 행궁로를 따라 걸어주세요.',
          'Exit Gahoedang and follow Haenggung-ro.',
          'カフェダンを出て、行宮路に沿ってお進みください。',
        ),
      ),
      const SizedBox(height: 10),
      _RouteStep(
        number: '2',
        title: tr('건물 2층에 도착', 'Head up to the 2nd floor', '建物の2階へ'),
        body: tr(
          '행궁로 25 건물 2층에서 기다리고 있어요.',
          'We’re waiting on the 2nd floor at 25 Haenggung-ro.',
          '行宮路25の建物2階でお待ちしています。',
        ),
      ),
      const Spacer(),
      KioskButton(
        label: tr('확인했어요', 'Got it', '確認しました'),
        fullWidth: true,
        icon: Icons.check_rounded,
        onPressed: onClose,
      ),
    ],
  );
}

class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.celadonSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: AppColors.celadon),
          const SizedBox(width: 8),
          Text(value, style: Type.section.copyWith(fontSize: 17)),
        ],
      ),
    ),
  );
}

class _RouteStep extends StatelessWidget {
  const _RouteStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: Type.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Type.section.copyWith(fontSize: 18)),
              const SizedBox(height: 3),
              Text(
                body,
                style: Type.caption.copyWith(fontSize: 14, height: 1.42),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RouteMapPainter extends CustomPainter {
  const _RouteMapPainter(this.progress);

  final double progress;

  Path _route(Size size) => Path()
    ..moveTo(size.width * 0.30, size.height * 0.20)
    ..cubicTo(
      size.width * 0.34,
      size.height * 0.37,
      size.width * 0.58,
      size.height * 0.58,
      size.width * 0.72,
      size.height * 0.80,
    );

  @override
  void paint(Canvas canvas, Size size) {
    final wash = Paint()..style = PaintingStyle.fill;
    wash.color = AppColors.blossomSoft.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(size.width * 0.03, size.height * 0.84), 120, wash);
    wash.color = AppColors.celadonSoft.withValues(alpha: 0.78);
    canvas.drawCircle(Offset(size.width * 0.98, size.height * 0.11), 118, wash);

    final blocks = Paint()..color = AppColors.surface.withValues(alpha: 0.72);
    final outlines = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.line.withValues(alpha: 0.45);
    final blockRects = <RRect>[
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-18, size.height * 0.28, size.width * 0.25, 112),
        const Radius.circular(22),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.56,
          size.width * 0.27,
          124,
        ),
        const Radius.circular(22),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.66,
          size.height * 0.17,
          size.width * 0.38,
          118,
        ),
        const Radius.circular(22),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.77,
          size.height * 0.51,
          size.width * 0.28,
          116,
        ),
        const Radius.circular(22),
      ),
    ];
    for (final block in blockRects) {
      canvas
        ..drawRRect(block, blocks)
        ..drawRRect(block, outlines);
    }

    final route = _route(size);
    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 86
        ..strokeCap = StrokeCap.round
        ..color = AppColors.cream.withValues(alpha: 0.92),
    );
    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.lineStrong.withValues(alpha: 0.28),
    );

    final metric = route.computeMetrics().first;
    final shown = metric.extractPath(0, metric.length * progress);
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = AppColors.accent;
    for (final shownMetric in shown.computeMetrics()) {
      var cursor = 0.0;
      while (cursor < shownMetric.length) {
        canvas.drawPath(
          shownMetric.extractPath(
            cursor,
            math.min(cursor + 13, shownMetric.length),
          ),
          dashPaint,
        );
        cursor += 23;
      }
    }

    final current = metric.getTangentForOffset(metric.length * progress);
    if (current != null) {
      canvas.drawCircle(
        current.position,
        17,
        Paint()..color = AppColors.accent.withValues(alpha: 0.13),
      );
      canvas.drawCircle(current.position, 7, Paint()..color = AppColors.accent);
    }

    final end = metric.getTangentForOffset(metric.length)?.position;
    if (end != null) {
      final pin = Path()
        ..moveTo(end.dx, end.dy + 16)
        ..cubicTo(
          end.dx - 5,
          end.dy + 7,
          end.dx - 15,
          end.dy - 1,
          end.dx - 15,
          end.dy - 12,
        )
        ..arcToPoint(
          Offset(end.dx + 15, end.dy - 12),
          radius: const Radius.circular(15),
          largeArc: true,
        )
        ..cubicTo(
          end.dx + 15,
          end.dy - 1,
          end.dx + 5,
          end.dy + 7,
          end.dx,
          end.dy + 16,
        )
        ..close();
      canvas.drawPath(pin, Paint()..color = AppColors.accentDeep);
      canvas.drawCircle(
        Offset(end.dx, end.dy - 12),
        5,
        Paint()..color = AppColors.surface,
      );
    }
  }

  @override
  bool shouldRepaint(_RouteMapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
