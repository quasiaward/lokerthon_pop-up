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
          : Motion.base,
      curve: Motion.curve,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: selected
              ? [
                  AppColors.accentSoft,
                  AppColors.celadonSoft.withValues(alpha: 0.62),
                ]
              : [
                  Colors.white.withValues(alpha: 0.76),
                  AppColors.surface.withValues(alpha: 0.54),
                ],
        ),
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(
          color: selected
              ? accentColor.withValues(alpha: 0.78)
              : Colors.white.withValues(alpha: 0.82),
          width: selected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(
              alpha: selected ? 0.12 : 0.06,
            ),
            blurRadius: selected ? 28 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.card),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: option.bgColor,
                    borderRadius: BorderRadius.circular(
                      option.imageStyle == QuizImageStyle.circle ? 60 : 22,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.88),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    option.imagePath,
                    fit: option.imageFit,
                    cacheWidth: 216,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label.t,
                        style: Type.section.copyWith(
                          fontSize: isEn ? 24 : 28,
                          color: selected
                              ? AppColors.accentDeep
                              : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.desc.t,
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
                AnimatedContainer(
                  duration: Motion.fast,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.5),
                    border: Border.all(
                      color: selected
                          ? AppColors.accentDeep
                          : AppColors.lineStrong,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
