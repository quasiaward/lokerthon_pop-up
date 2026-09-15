import 'package:flutter/material.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';

class LangToggle extends StatelessWidget {
  const LangToggle({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final lang in Lang.values)
        Semantics(
          selected: appLang.value == lang,
          child: TextButton(
            onPressed: () => appLang.value = lang,
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 52),
              foregroundColor: appLang.value == lang
                  ? AppColors.accent
                  : AppColors.muted,
              backgroundColor: appLang.value == lang
                  ? AppColors.accentSoft
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              lang == Lang.ko ? 'KO' : 'EN',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
    ],
  );
}
