import 'package:flutter/material.dart';

import '../../data/quiz_questions.dart';
import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'glass_surface.dart';

/// 선택 카드 — 이 경험에서 가장 중요한 인터랙티브 컴포넌트.
///
/// 넓은 터치 면, 얇은 테두리, 거의 평평한 표면. 선택 상태는 톤 이동 +
/// 또렷한 테두리 + 작은 체크 표시로만 알린다(색 하나에만 기대지 않는다).
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
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.option;
    final title = tr(o.shownTitle, o.shownTitleEn);
    final subtitle = tr(o.shownSubtitle, o.shownSubtitleEn);

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.985 : (widget.selected ? 1.02 : 1),
        duration: Motion.fast,
        curve: Motion.curve,
        child: GlassSurface(
          accented: widget.selected,
          accentColor: widget.accentColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 24, 22),
            child: Row(
              children: [
                // 기존 선택지 이미지는 그대로 쓴다.
                _OptionImage(option: o),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Type.section.copyWith(
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          color: widget.selected
                              ? widget.accentColor
                              : AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        subtitle,
                        style: Type.caption.copyWith(
                          fontSize: 17,
                          color: AppColors.muted,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.md),
                _CheckDot(selected: widget.selected, color: widget.accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 선택지 이미지. 원본 에셋의 배경색을 그대로 깔고 이미지를 얹는다.
class _OptionImage extends StatelessWidget {
  const _OptionImage({required this.option});

  final QuizOption option;

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    final radius = option.imageStyle == QuizImageStyle.circle
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(18);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: option.bgColor.withValues(alpha: 0.55),
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        option.imagePath,
        fit: option.imageFit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1 : 0.6,
      duration: Motion.fast,
      curve: Motion.curve,
      child: AnimatedOpacity(
        opacity: selected ? 1 : 0,
        duration: Motion.fast,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Icon(
            Icons.check_rounded,
            size: 20,
            color: AppColors.ground,
          ),
        ),
      ),
    );
  }
}
