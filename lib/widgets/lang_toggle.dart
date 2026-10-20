import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import 'kiosk/glass_surface.dart';

class LangToggle extends StatelessWidget {
  const LangToggle({super.key, this.onActivity});

  final VoidCallback? onActivity;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Lang>(
    valueListenable: appLang,
    builder: (context, selectedLang, _) => GlassSurface(
      radius: 24,
      blurBackdrop: true,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final lang in Lang.values)
              Semantics(
                selected: selectedLang == lang,
                child: TextButton(
                  onPressed: () {
                    onActivity?.call();
                    appLang.value = lang;
                  },
                  style:
                      TextButton.styleFrom(
                        minimumSize: const Size(60, 48),
                        foregroundColor: selectedLang == lang
                            ? AppColors.surface
                            : AppColors.muted,
                        backgroundColor: selectedLang == lang
                            ? AppColors.accent
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ).copyWith(
                        animationDuration:
                            MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : Motion.base,
                      ),
                  child: Text(
                    lang.label,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w700,
                      color: selectedLang == lang
                          ? AppColors.surface
                          : AppColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
