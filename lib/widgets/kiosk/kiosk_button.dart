import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

enum KioskButtonVariant { primary, secondary, text }

/// Primary / Secondary / Text 버튼.
///
/// 터치 시 0.97로 눌렸다 돌아오는 것 외의 장식은 두지 않는다.
/// gradient·shine은 쓰지 않는다.
class KioskButton extends StatefulWidget {
  const KioskButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KioskButtonVariant.primary,
    this.fullWidth = false,
    this.accentColor = AppColors.accent,
  });

  final String label;
  final VoidCallback? onPressed;
  final KioskButtonVariant variant;
  final bool fullWidth;
  final Color accentColor;

  @override
  State<KioskButton> createState() => _KioskButtonState();
}

class _KioskButtonState extends State<KioskButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final isText = widget.variant == KioskButtonVariant.text;

    final Color background;
    final Color foreground;
    switch (widget.variant) {
      case KioskButtonVariant.primary:
        background = widget.accentColor;
        foreground = AppColors.ground;
      case KioskButtonVariant.secondary:
        background = AppColors.mist;
        foreground = AppColors.charcoal;
      case KioskButtonVariant.text:
        background = Colors.transparent;
        foreground = AppColors.muted;
    }

    final style = isText
        ? Type.cta.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: foreground,
          )
        : Type.cta.copyWith(color: foreground);

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            height: isText ? 56 : 72,
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: isText ? 8 : 40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(isText ? 0 : Radii.button),
            ),
            child: Text(widget.label, style: style),
          ),
        ),
      ),
    );
  }
}
