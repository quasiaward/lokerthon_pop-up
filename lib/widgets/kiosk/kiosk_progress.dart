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
      Text(
        '$step',
        style: Type.section.copyWith(fontSize: 22, color: AppColors.accent),
      ),
      Text(' / $total', style: Type.bodyMuted.copyWith(fontSize: 21)),
      const SizedBox(width: 22),
      Expanded(
        child: Row(
          children: [
            for (var i = 0; i < total; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
                  child: AnimatedContainer(
                    duration: Motion.base,
                    curve: Motion.curve,
                    height: 5,
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
