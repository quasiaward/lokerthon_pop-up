import 'package:flutter/material.dart';
import '../../data/quiz_questions.dart';
import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    this.accentColor = AppColors.accent,
  });
  final QuizOption option;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Motion.fast,
      decoration: BoxDecoration(
        color: selected ? AppColors.accentSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(
          color: selected ? accentColor : AppColors.line,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.card),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    option.imageStyle == QuizImageStyle.circle ? 60 : 20,
                  ),
                  child: ColoredBox(
                    color: option.bgColor,
                    child: Image.asset(
                      option.imagePath,
                      width: 108,
                      height: 108,
                      fit: option.imageFit,
                      cacheWidth: 216,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(option.shownTitle, option.shownTitleEn),
                        style: Type.section.copyWith(
                          fontSize: isEn ? 25 : 29,
                          fontWeight: FontWeight.w700,
                          color: selected ? accentColor : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr(option.shownSubtitle, option.shownSubtitleEn),
                        style: Type.caption.copyWith(
                          fontSize: 18,
                          height: 1.4,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? accentColor : AppColors.line,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
