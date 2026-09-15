import 'package:flutter/material.dart';
import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class TopControl extends StatelessWidget {
  const TopControl({super.key, this.onBack, required this.onHome});
  final VoidCallback? onBack;
  final VoidCallback onHome;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      if (onBack != null)
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 24),
          label: Text(tr('이전으로', 'Back')),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.charcoal,
            minimumSize: const Size(120, 56),
            textStyle: Type.caption.copyWith(fontSize: 20),
          ),
        )
      else
        Text('행궁다과', style: Type.section.copyWith(fontSize: 26)),
      TextButton.icon(
        onPressed: onHome,
        icon: const Icon(Icons.home_outlined, size: 24),
        label: Text(tr('처음으로', 'Home')),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.muted,
          minimumSize: const Size(120, 56),
          textStyle: Type.caption.copyWith(fontSize: 20),
        ),
      ),
    ],
  );
}
