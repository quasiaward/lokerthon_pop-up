import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'brand_mark.dart';
import 'glass_surface.dart';

class TopControl extends StatelessWidget {
  const TopControl({super.key, this.onBack, required this.onHome});

  final VoidCallback? onBack;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: math.max(60, MediaQuery.textScalerOf(context).scale(18) * 1.4 + 24),
    child: Stack(
      alignment: Alignment.center,
      children: [
        const BrandMark(compact: true),
        if (onBack != null)
          Align(
            alignment: Alignment.centerLeft,
            child: _GlassControl(
              onPressed: onBack!,
              icon: Icons.arrow_back_rounded,
              label: tr('이전으로', 'Back', '戻る'),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: _GlassControl(
            onPressed: onHome,
            icon: Icons.home_rounded,
            label: tr('처음으로', 'Home', 'はじめに戻る'),
            muted: true,
          ),
        ),
      ],
    ),
  );
}

class _GlassControl extends StatelessWidget {
  const _GlassControl({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.muted = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: 23,
    blurBackdrop: true,
    child: Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(23),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: muted ? AppColors.celadonSoft : AppColors.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: muted ? AppColors.muted : AppColors.accent,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: Type.caption.copyWith(
                    fontSize: 18,
                    color: muted ? AppColors.muted : AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
