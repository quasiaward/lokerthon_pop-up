import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// 질문 진행 표시. 칸마다 트랙 위를 채움이 왼쪽에서 오른쪽으로 흐른다.
///
/// 칸의 높이·배경을 바꾸지 않고 채움 폭만 움직여서, 단계가 바뀌어도
/// 선이 끊기거나 튀지 않는다.
class KioskProgress extends StatelessWidget {
  const KioskProgress({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Motion.slow;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
          ),
          child: Text(
            '$step',
            style: Type.section.copyWith(fontSize: 20, color: AppColors.accent),
          ),
        ),
        const SizedBox(width: 9),
        Text('/ $total', style: Type.bodyMuted.copyWith(fontSize: 19)),
        const SizedBox(width: 22),
        Expanded(
          child: RepaintBoundary(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: step.toDouble()),
              duration: duration,
              curve: Motion.curve,
              builder: (context, filled, _) => Row(
                children: [
                  for (var i = 0; i < total; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
                        child: _Segment(fill: (filled - i).clamp(0.0, 1.0)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.fill});

  final double fill;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: SizedBox(
      height: 6,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.mist),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fill,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.celadon],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
