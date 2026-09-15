import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 아주 느리게 떠다니는 색 덩어리.
///
/// 유리 표면이 굴절할 색을 뒤에 깔아 준다. 대비를 극도로 낮게 유지해
/// quiet luxury의 정적인 분위기를 깨지 않는다. 실제 blur 필터 대신
/// 방사형 그라데이션을 써서 매 프레임 비용을 낮췄다.
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
    final orbs = <_Orb>[
      _Orb(const Color(0xFF6D1F2B), 0.18, 620, -0.08, 0.02, 0.0),
      _Orb(const Color(0xFF4B5842), 0.14, 540, 0.68, -0.12, 0.3),
      _Orb(const Color(0xFF8A5A2B), 0.13, 560, 0.72, 0.58, 0.55),
      _Orb(widget.tint ?? const Color(0xFF8A2F45), 0.10, 480, 0.18, 0.66, 0.8),
    ];

    return IgnorePointer(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => LayoutBuilder(
            builder: (context, box) =>
                Stack(children: [for (final o in orbs) _buildOrb(o, box)]),
          ),
        ),
      ),
    );
  }

  Widget _buildOrb(_Orb o, BoxConstraints box) {
    // 위상을 달리한 느린 8자 궤도.
    final t = (_c.value + o.phase) * 2 * 3.1415926;
    final dx = 30 * _sin(t);
    final dy = -24 * _sin(t * 0.7 + 1.1);

    return Positioned(
      left: box.maxWidth * o.x + dx,
      top: box.maxHeight * o.y + dy,
      child: Container(
        width: o.size,
        height: o.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              o.color.withValues(alpha: o.alpha),
              o.color.withValues(alpha: o.alpha * 0.45),
              o.color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  static double _sin(double v) => math.sin(v);
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
