import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class KioskProgress extends StatelessWidget {
  const KioskProgress({super.key, required this.step, required this.total});
  final int step;
  final int total;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$step',
        style: Type.section.copyWith(fontSize: 23, color: AppColors.accent),
      ),
      Text(' / $total', style: Type.bodyMuted.copyWith(fontSize: 23)),
      const SizedBox(width: 20),
      for (var i = 0; i < total; i++)
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Container(
            width: 26,
            height: 5,
            decoration: BoxDecoration(
              color: i < step ? AppColors.accent : AppColors.mist,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
    ],
  );
}
