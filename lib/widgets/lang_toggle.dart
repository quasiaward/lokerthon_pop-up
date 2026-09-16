import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import 'kiosk/glass_surface.dart';

class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Lang>(
    valueListenable: appLang,
    builder: (context, selectedLang, _) => GlassSurface(
      radius: 22,
      blurBackdrop: true,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final lang in Lang.values)
              Semantics(
                selected: selectedLang == lang,
                child: AnimatedScale(
                  scale: selectedLang == lang ? 1 : 0.97,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : Motion.base,
                  curve: Motion.curve,
                  child: TextButton(
                    onPressed: () => appLang.value = lang,
                    style:
                        TextButton.styleFrom(
                          minimumSize: const Size(62, 46),
                          foregroundColor: selectedLang == lang
                              ? AppColors.surface
                              : AppColors.muted,
                          backgroundColor: selectedLang == lang
                              ? AppColors.accent
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
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
                        fontSize: 17,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w700,
                        color: selectedLang == lang
                            ? AppColors.surface
                            : AppColors.muted,
                      ),
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
