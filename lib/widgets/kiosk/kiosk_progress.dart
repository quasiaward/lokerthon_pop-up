import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// 진행 표시 — 숫자를 타이포로 쓰고, 그 옆에 아주 얇은 트랙 하나.
/// 긴 progress bar보다 시선을 덜 가져간다.
class KioskProgress extends StatelessWidget {
  const KioskProgress({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final numberStyle = TextStyle(
      fontFamily: kSans,
      fontFamilyFallback: kSansFallback,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1,
      letterSpacing: -0.3,
      color: AppColors.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$step', style: numberStyle),
              TextSpan(
                text: '  /  ',
                style: numberStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.lineStrong,
                ),
              ),
              TextSpan(
                text: '$total',
                style: numberStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.faint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Space.md),
        SizedBox(
          width: 128,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(color: AppColors.line),
                AnimatedFractionallySizedBox(
                  duration: Motion.base,
                  curve: Motion.curve,
                  widthFactor: (step / total).clamp(0.0, 1.0),
                  alignment: Alignment.centerLeft,
                  child: Container(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
