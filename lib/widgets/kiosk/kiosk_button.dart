import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

enum KioskButtonVariant { primary, secondary, text }

class KioskButton extends StatelessWidget {
  const KioskButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KioskButtonVariant.primary,
    this.fullWidth = false,
    this.accentColor = AppColors.accent,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final KioskButtonVariant variant;
  final bool fullWidth;
  final Color accentColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final primary = variant == KioskButtonVariant.primary;
    final foreground = primary ? Colors.white : AppColors.charcoal;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: variant == KioskButtonVariant.text ? 60 : 76,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: primary
              ? accentColor
              : variant == KioskButtonVariant.secondary
              ? AppColors.mist
              : Colors.transparent,
          disabledBackgroundColor: AppColors.mist,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.button),
          ),
          textStyle: Type.cta,
          animationDuration: Motion.fast,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(label, textAlign: TextAlign.center)),
            if (icon != null) ...[
              const SizedBox(width: 14),
              Icon(icon, size: 26),
            ],
          ],
        ),
      ),
    );
  }
}
