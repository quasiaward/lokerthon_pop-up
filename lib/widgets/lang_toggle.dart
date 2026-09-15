import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import 'kiosk/glass_surface.dart';

class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: 22,
    blurBackdrop: true,
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lang in Lang.values)
            Semantics(
              selected: appLang.value == lang,
              child: TextButton(
                onPressed: () => appLang.value = lang,
                style: TextButton.styleFrom(
                  minimumSize: const Size(62, 46),
                  foregroundColor: appLang.value == lang
                      ? AppColors.surface
                      : AppColors.muted,
                  backgroundColor: appLang.value == lang
                      ? AppColors.accent
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Text(
                  lang.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: appLang.value == lang
                        ? AppColors.surface
                        : AppColors.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
