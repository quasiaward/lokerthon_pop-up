import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'brand_mark.dart';
import 'glass_surface.dart';
import 'kiosk_button.dart';

/// 팝업 장소에서 행궁다과까지의 짧은 도보 경로를 앱 안에서 보여 주는 안내 시트.
/// 실제 지도 캡처에서 도로·건물 모양만 뽑아 앱 색으로 다시 칠한 배경
/// (`assets/map/route_map.png`, `tool/build_route_map.py`) 위에 경로와
/// 이름표를 그리고, 경로가 출발지에서 도착지까지 반복해서 이어진다.
class StoreDirectionsSheet extends StatefulWidget {
  const StoreDirectionsSheet({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<StoreDirectionsSheet> createState() => _StoreDirectionsSheetState();
}

class _StoreDirectionsSheetState extends State<StoreDirectionsSheet>
    with TickerProviderStateMixin {
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

  /// 경로가 그려지고 도착지가 한 번 반짝인 뒤 다시 시작한다.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _loop
        ..stop()
        ..value = _RouteOverlayPainter.drawEnd;
    } else {
      if (_controller.isDismissed && !_closing) _controller.forward();
      if (!_loop.isAnimating) _loop.repeat();
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
    _loop.dispose();
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
                                  child: _RouteIllustration(loop: _loop),
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

/// 지도 배경 좌표. 캡처를 가로 2000px로 줄인 기준이며
/// `tool/build_route_map.py`의 CROP과 같아야 한다.
abstract final class _MapGeo {
  static const asset = 'assets/map/route_map.png';
  static const crop = Rect.fromLTWH(520, 0, 1120, 1194);

  /// 가회당 입구 → 행궁로 → 행궁다과 입구.
  static const route = [
    Offset(1170, 902),
    Offset(1146, 916),
    Offset(1015, 162),
    Offset(1040, 176),
  ];
  static const start = Offset(1205, 868);
  static const destination = Offset(1092, 196);
  static const walkBadge = Offset(1128, 540);

  /// [size] 영역을 BoxFit.cover로 채운 배경에서 [point]가 놓이는 위치.
  static Offset place(Offset point, Size size) {
    final scale = math.max(size.width / crop.width, size.height / crop.height);
    final dx = (size.width - crop.width * scale) / 2;
    final dy = (size.height - crop.height * scale) / 2;
    return Offset(
      dx + (point.dx - crop.left) * scale,
      dy + (point.dy - crop.top) * scale,
    );
  }
}

class _RouteIllustration extends StatelessWidget {
  const _RouteIllustration({required this.loop});

  final Animation<double> loop;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: tr(
      '가회당에서 행궁로를 따라 행궁다과 2층까지 이동하는 길 안내 지도',
      'Map of the route from Gahoedang along Haenggung-ro to Haenggung Dagwa on the second floor',
      'カフェダンから行宮路を通り、行宮茶菓2階までの案内地図',
    ),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            Offset at(Offset p) => _MapGeo.place(p, size);
            return Stack(
              children: [
                const Positioned.fill(
                  child: Image(
                    image: AssetImage(_MapGeo.asset),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                ..._roadLabels(at),
                ..._landmarks(at),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _RouteOverlayPainter(loop, [
                        for (final p in _MapGeo.route) at(p),
                      ], at(_MapGeo.destination)),
                    ),
                  ),
                ),
                _anchored(
                  at(_MapGeo.walkBadge),
                  const Alignment(-1, 0),
                  _WalkBadge(tr('1분', '1 min', '1分')),
                ),
                _anchored(
                  at(_MapGeo.start),
                  Alignment.bottomCenter,
                  const _MapPin(
                    color: AppColors.celadon,
                    icon: Icons.storefront_rounded,
                  ),
                ),
                _anchored(
                  at(_MapGeo.destination),
                  Alignment.bottomCenter,
                  const _MapPin(
                    color: AppColors.accent,
                    icon: Icons.local_cafe_rounded,
                  ),
                ),
                _besidePin(
                  at(_MapGeo.destination),
                  size,
                  _PlaceLabel(
                    eyebrow: tr('도착', 'ARRIVE', '到着'),
                    title: tr('행궁다과 · 2층', 'Haenggung Dagwa · 2F', '行宮茶菓・2階'),
                    detail: tr('행궁로 25', '25 Haenggung-ro', '行宮路25'),
                    color: AppColors.accent,
                  ),
                ),
                _besidePin(
                  at(_MapGeo.start),
                  size,
                  _PlaceLabel(
                    eyebrow: tr('출발 · 현재 위치', 'START · YOU ARE HERE', '出発・現在地'),
                    title: tr('가회당 · 팝업', 'Gahoedang · Pop-up', 'カフェダン・ポップアップ'),
                    detail: tr('행궁로 33', '33 Haenggung-ro', '行宮路33'),
                    color: AppColors.celadon,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  /// 핀 머리 오른쪽에 이름표를 붙인다. 지도 밖으로 넘치지 않게 폭을 줄인다.
  static Widget _besidePin(Offset tip, Size size, _PlaceLabel label) {
    const gap = 26.0;
    const edge = 12.0;
    final left = tip.dx + gap;
    return Positioned(
      left: left,
      // 핀 머리(끝에서 약 32px 위)와 이름표의 세로 가운데를 맞춘다.
      top: tip.dy - 32,
      child: FractionalTranslation(
        translation: const Offset(0, -0.5),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.max(120, size.width - left - edge),
          ),
          child: label,
        ),
      ),
    );
  }

  /// [point]에 자식의 [anchor] 지점이 오도록 놓는다.
  static Widget _anchored(Offset point, Alignment anchor, Widget child) =>
      Positioned(
        left: point.dx,
        top: point.dy,
        child: FractionalTranslation(
          translation: Offset(-(anchor.x + 1) / 2, -(anchor.y + 1) / 2),
          child: child,
        ),
      );

  static List<Widget> _roadLabels(Offset Function(Offset) at) => [
    _anchored(
      at(const Offset(1180, 1085)),
      Alignment.center,
      _RoadLabel(tr('행궁로', 'Haenggung-ro', '行宮路'), angle: 1.39),
    ),
    _anchored(
      at(const Offset(790, 418)),
      Alignment.center,
      _RoadLabel(
        tr('행궁로26번길', 'Haenggung-ro 26beon-gil', '行宮路26番ギル'),
        angle: -0.58,
      ),
    ),
    _anchored(
      at(const Offset(1275, 446)),
      Alignment.center,
      _RoadLabel(
        tr('정조로801번길', 'Jeongjo-ro 801beon-gil', '正祖路801番ギル'),
        angle: 0.55,
      ),
    ),
  ];

  /// 주변 건물 이름. 경로를 가리지 않도록 행궁로 왼쪽 건물은 이름이
  /// 왼쪽으로 뻗게([Alignment.centerRight]) 놓는다.
  static List<Widget> _landmarks(Offset Function(Offset) at) => [
    for (final (point, anchor, name) in [
      (
        const Offset(1080, 60),
        Alignment.centerLeft,
        tr('공차', 'Gong cha', 'ゴンチャ'),
      ),
      (
        const Offset(1050, 684),
        Alignment.centerRight,
        tr('메가MGC커피', 'MEGA MGC COFFEE', 'メガMGCコーヒー'),
      ),
      (
        const Offset(1352, 594),
        Alignment.center,
        tr('남양마트', 'Namyang Mart', 'ナミャンマート'),
      ),
      (
        const Offset(906, 776),
        Alignment.center,
        tr('남창동 열린문화공간', 'Namchang Culture Space', '南昌洞文化空間'),
      ),
      (
        const Offset(1306, 344),
        Alignment.center,
        tr('사진공예사', 'Photo Studio', '写真館'),
      ),
    ])
      _anchored(at(point), anchor, _Landmark(name)),
  ];
}

class _RoadLabel extends StatelessWidget {
  const _RoadLabel(this.text, {required this.angle});

  final String text;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Text(
      text,
      style: Type.caption.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.faint,
      ),
    ),
  );
}

class _Landmark extends StatelessWidget {
  const _Landmark(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.champagne,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 5),
      Text(
        name,
        style: Type.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
          shadows: const [Shadow(color: Colors.white, blurRadius: 4)],
        ),
      ),
    ],
  );
}

class _WalkBadge extends StatelessWidget {
  const _WalkBadge(this.label);

  /// 번역 문구는 밖에서 받는다. const 위젯 안에서 tr()을 부르면 언어가
  /// 바뀌어도 다시 그려지지 않을 수 있다.
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.directions_walk_rounded,
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Type.caption.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

/// 물방울 모양 지도 핀. 아래 꼭짓점이 좌표에 닿는다.
class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 54,
    child: CustomPaint(
      painter: _PinPainter(color),
      child: Align(
        alignment: const Alignment(0, -0.42),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    ),
  );
}

class _PinPainter extends CustomPainter {
  const _PinPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final tip = Offset(r, size.height);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(r - 6, size.height - 10, 0, r + 12, 0, r)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..cubicTo(size.width, r + 12, r + 6, size.height - 10, tip.dx, tip.dy)
      ..close();
    canvas
      ..drawShadow(path, AppColors.accentDeep, 4, false)
      ..drawPath(path, Paint()..color = color)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = Colors.white,
      );
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => oldDelegate.color != color;
}

class _PlaceLabel extends StatelessWidget {
  const _PlaceLabel({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.color,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 230),
    padding: const EdgeInsets.fromLTRB(14, 10, 16, 11),
    decoration: BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(18),
      border: Border(left: BorderSide(color: color, width: 4)),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentDeep.withValues(alpha: 0.1),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Type.eyebrow(color, latin: isEn, size: 11, tracking: 1.2),
        ),
        const SizedBox(height: 3),
        // 핀 옆 폭이 좁으면 잘리지 않고 두 줄로 흐른다.
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Type.section.copyWith(fontSize: 17, height: 1.25),
        ),
        Text(detail, style: Type.caption.copyWith(fontSize: 13)),
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

/// 경로 한 바퀴: 옅은 전체 경로 위로 진한 선이 출발지에서 도착지까지
/// 이어지고, 도착지에서 물결이 한 번 퍼진 뒤 사라졌다가 다시 시작한다.
class _RouteOverlayPainter extends CustomPainter {
  _RouteOverlayPainter(this.loop, this.points, this.destination)
    : super(repaint: loop);

  /// 한 바퀴 중 선이 다 그려지는 시점.
  static const drawEnd = 0.55;
  static const _fadeStart = 0.86;

  final Animation<double> loop;
  final List<Offset> points;
  final Offset destination;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final metric = path.computeMetrics().first;
    final t = loop.value;

    // 전체 경로 (옅게)
    canvas
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white,
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.accent.withValues(alpha: 0.22),
      );

    final draw = Curves.easeInOutCubic.transform((t / drawEnd).clamp(0.0, 1.0));
    final fade = t < _fadeStart
        ? 1.0
        : 1 - Curves.easeIn.transform((t - _fadeStart) / (1 - _fadeStart));
    if (draw > 0 && fade > 0) {
      final shown = metric.extractPath(0, metric.length * draw);
      canvas.drawPath(
        shown,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.accent.withValues(alpha: fade),
      );

      // 진행 방향 화살표
      final arrow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.9 * fade);
      for (var d = 26.0; d < metric.length * draw - 10; d += 24) {
        final tan = metric.getTangentForOffset(d)!;
        final dir = tan.vector;
        final normal = Offset(-dir.dy, dir.dx);
        final c = tan.position;
        canvas.drawPath(
          Path()
            ..moveTo(
              (c - dir * 2.5 + normal * 2.6).dx,
              (c - dir * 2.5 + normal * 2.6).dy,
            )
            ..lineTo((c + dir * 1.5).dx, (c + dir * 1.5).dy)
            ..lineTo(
              (c - dir * 2.5 - normal * 2.6).dx,
              (c - dir * 2.5 - normal * 2.6).dy,
            ),
          arrow,
        );
      }

      // 걷는 사람 위치
      if (draw < 1) {
        final head = metric.getTangentForOffset(metric.length * draw)!.position;
        canvas
          ..drawCircle(
            head,
            14,
            Paint()..color = AppColors.accent.withValues(alpha: 0.18),
          )
          ..drawCircle(head, 7.5, Paint()..color = Colors.white)
          ..drawCircle(head, 5, Paint()..color = AppColors.accent);
      }
    }

    // 도착 물결
    if (t >= drawEnd && t < _fadeStart + 0.1) {
      final p = ((t - drawEnd) / (_fadeStart + 0.1 - drawEnd)).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(p);
      canvas.drawCircle(
        destination,
        10 + 34 * eased,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.accent.withValues(alpha: 0.45 * (1 - p)),
      );
    }

    // 출발점
    canvas
      ..drawCircle(points.first, 7, Paint()..color = Colors.white)
      ..drawCircle(points.first, 4.5, Paint()..color = AppColors.celadon);
  }

  @override
  bool shouldRepaint(_RouteOverlayPainter oldDelegate) =>
      oldDelegate.destination != destination ||
      !_samePoints(oldDelegate.points, points);

  static bool _samePoints(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
