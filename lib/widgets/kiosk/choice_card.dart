import 'package:flutter/material.dart';

import '../../data/quiz_questions.dart';
import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class ChoiceCard extends StatefulWidget {
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
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final selected = widget.selected;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: reduced ? Duration.zero : Motion.fast,
      curve: Motion.curve,
      child: Semantics(
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : Motion.base,
          curve: Motion.curve,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      AppColors.surface,
                      AppColors.accentSoft.withValues(alpha: 0.90),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.82),
                      AppColors.surface.withValues(alpha: 0.62),
                    ],
            ),
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(
              color: selected
                  ? widget.accentColor.withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.90),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentDeep.withValues(
                  alpha: selected ? 0.13 : 0.065,
                ),
                blurRadius: selected ? 32 : 24,
                spreadRadius: selected ? -3 : -6,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              borderRadius: BorderRadius.circular(Radii.card),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: reduced ? Duration.zero : Motion.base,
                      curve: Motion.curve,
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: widget.option.bgColor,
                        borderRadius: BorderRadius.circular(
                          widget.option.imageStyle == QuizImageStyle.circle
                              ? 60
                              : 24,
                        ),
                        border: Border.all(
                          color: selected
                              ? widget.accentColor.withValues(alpha: 0.20)
                              : Colors.white.withValues(alpha: 0.92),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.option.bgColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        widget.option.imagePath,
                        fit: widget.option.imageFit,
                        cacheWidth: 224,
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
                            widget.option.label.t,
                            style: Type.section.copyWith(
                              fontSize: isEn ? 24 : 28,
                              color: selected
                                  ? AppColors.accentDeep
                                  : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.option.desc.t,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Type.caption.copyWith(
                              fontSize: 18,
                              height: 1.38,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    AnimatedContainer(
                      duration: reduced ? Duration.zero : Motion.fast,
                      curve: Motion.curve,
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? widget.accentColor
                            : Colors.white.withValues(alpha: 0.62),
                        border: Border.all(
                          color: selected
                              ? widget.accentColor
                              : AppColors.lineStrong,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: reduced ? Duration.zero : Motion.fast,
                        switchInCurve: Motion.curve,
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey('selected'),
                                size: 20,
                                color: Colors.white,
                              )
                            : const SizedBox(key: ValueKey('unselected')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
