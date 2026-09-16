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
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _AmbientPainter(
            progress: _c,
            tint: widget.tint ?? AppColors.accent,
          ),
          size: Size.infinite,
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
    // 금색 덩어리를 걷어내고 청자와 자두빛으로 바꿨다. 금빛이 화면 전체를
    // 누렇게 덮으면서 예스러운 인상을 만들던 가장 큰 원인이었다.
    // 세기도 낮춰 바탕이 깨끗하게 남도록 했다.
    final orbs = <_Orb>[
      const _Orb(Color(0xFF7D2742), 0.13, 660, -0.10, -0.04, 0.0),
      const _Orb(Color(0xFF7E9A90), 0.11, 600, 0.66, -0.10, 0.3),
      const _Orb(Color(0xFF8E7F9B), 0.08, 560, 0.72, 0.58, 0.55),
      _Orb(tint, 0.07, 500, 0.12, 0.66, 0.8),
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
