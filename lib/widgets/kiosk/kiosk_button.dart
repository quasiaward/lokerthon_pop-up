import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'glass_surface.dart';

enum KioskButtonVariant { primary, secondary, text }

class KioskButton extends StatefulWidget {
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
  State<KioskButton> createState() => _KioskButtonState();
}

class _KioskButtonState extends State<KioskButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.variant == KioskButtonVariant.primary;
    final textOnly = widget.variant == KioskButtonVariant.text;
    final enabled = widget.onPressed != null;
    final foreground = primary ? AppColors.surface : AppColors.accentDeep;
    final reduced = MediaQuery.disableAnimationsOf(context);

    final content = Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: enabled
              ? (value) => setState(() => _pressed = value)
              : null,
          borderRadius: BorderRadius.circular(Radii.button),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: textOnly ? 12 : 22,
            ),
            child: Row(
              mainAxisSize: widget.fullWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: Type.cta.copyWith(color: foreground),
                  ),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 14),
                  AnimatedSlide(
                    offset: _pressed ? const Offset(0.12, 0) : Offset.zero,
                    duration: reduced ? Duration.zero : Motion.fast,
                    curve: Motion.curve,
                    child: Icon(widget.icon, size: 24, color: foreground),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: reduced ? Duration.zero : Motion.fast,
      curve: Motion.curve,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: textOnly ? 56 : 72),
            child: textOnly
                ? content
                : GlassSurface(
                    radius: Radii.button,
                    accented: primary,
                    strong: primary,
                    accentColor: widget.accentColor,
                    blurBackdrop: true,
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}
