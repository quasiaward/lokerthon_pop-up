import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class KioskProgress extends StatelessWidget {
  const KioskProgress({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : Motion.base,
        curve: Motion.curve,
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
        child: Row(
          children: [
            for (var i = 0; i < total; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
                  child: AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : Motion.base,
                    curve: Motion.curve,
                    height: i < step ? 6 : 4,
                    decoration: BoxDecoration(
                      gradient: i < step
                          ? const LinearGradient(
                              colors: [AppColors.accent, AppColors.celadon],
                            )
                          : null,
                      color: i < step ? null : AppColors.mist,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
