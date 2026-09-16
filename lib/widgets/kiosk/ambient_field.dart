import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 버건디·금빛·쑥빛이 아주 느리게 움직이는 브랜드 배경.
///
/// 화면 전체를 덮는 배경이라 매 프레임 비용이 그대로 프레임 예산을 먹는다.
/// 그래서 위젯을 다시 만들지 않고 [CustomPaint] 한 장에 직접 그리며,
/// [RepaintBoundary]로 격리해 앞쪽 UI가 다시 그려져도 같이 끌려가지 않게 한다.
class AmbientField extends StatefulWidget {
  const AmbientField({super.key, this.tint});

  /// 결과 화면에서 다과 대표색을 살짝 섞고 싶을 때 쓴다.
  final Color? tint;

  @override
  State<AmbientField> createState() => _AmbientFieldState();
}

class _AmbientFieldState extends State<AmbientField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 32),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _AmbientPainter(
                progress: _c,
                tint: widget.tint ?? AppColors.accent,
              ),
            ),
            const RepaintBoundary(child: CustomPaint(painter: _GrainPainter())),
          ],
        ),
      ),
    );
  }
}

class _Orb {
  const _Orb(this.color, this.alpha, this.size, this.x, this.y, this.phase);

  final Color color;
  final double alpha;
  final double size;
  final double x;
  final double y;
  final double phase;
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.progress, required this.tint})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    // 워드마크의 열매 분홍, 잎의 연두, 브랜드 와인을 넓고 낮은 농도로
    // 겹친다. 어느 화면에서도 특정 색 덩어리가 먼저 보이지 않게 한다.
    final orbs = <_Orb>[
      const _Orb(AppColors.blossom, 0.10, 720, -0.14, -0.08, 0.0),
      const _Orb(AppColors.celadon, 0.09, 660, 0.68, -0.12, 0.3),
      const _Orb(Color(0xFFB6A3C0), 0.055, 620, 0.70, 0.60, 0.55),
      _Orb(tint, 0.065, 560, 0.08, 0.68, 0.8),
    ];

    for (final o in orbs) {
      // 위상을 달리한 느린 궤도.
      final t = (progress.value + o.phase) * 2 * math.pi;
      final center = Offset(
        size.width * o.x + o.size / 2 + 30 * math.sin(t),
        size.height * o.y + o.size / 2 - 24 * math.sin(t * 0.7 + 1.1),
      );
      final radius = o.size / 2;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            o.color.withValues(alpha: o.alpha),
            o.color.withValues(alpha: o.alpha * 0.45),
            o.color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) => old.tint != tint;
}

/// 한지의 섬유감을 흉내 내는 정적인 미세 패턴. 움직이는 오브와 분리해 두어
/// 60fps 애니메이션 중에는 다시 그리지 않는다.
class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grain = Paint()..color = AppColors.ink.withValues(alpha: 0.018);
    const gap = 44.0;
    for (double y = 18; y < size.height; y += gap) {
      final row = (y / gap).floor();
      for (double x = row.isEven ? 20 : 42; x < size.width; x += gap * 1.7) {
        canvas.drawCircle(Offset(x, y), 0.7, grain);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => false;
}
