import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../data/quiz_questions.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/choice_card.dart';
import '../widgets/kiosk/kiosk_progress.dart';
import '../widgets/kiosk/top_control.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({
    super.key,
    required this.index,
    required this.question,
    required this.selected,
    required this.onSelect,
    required this.onBack,
    required this.onHome,
    this.bodyMotion = kAlwaysCompleteAnimation,
    this.error,
  });
  final int index;
  final QuizQuestion question;
  final String? selected;
  final ValueChanged<QuizOption> onSelect;
  final VoidCallback? onBack;
  final VoidCallback onHome;
  final String? error;

  /// 질문 블록의 등장 정도(0~1). 상단 조작과 진행 표시는 여기에 묶지 않는다.
  final Animation<double> bodyMotion;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(88, 48, 88, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TopControl(onBack: onBack, onHome: onHome),
        const SizedBox(height: 40),
        KioskProgress(step: index + 1, total: quizQuestions.length),
        const SizedBox(height: 20),
        Expanded(
          child: AnimatedBuilder(
            animation: bodyMotion,
            builder: (context, child) => Opacity(
              opacity: bodyMotion.value,
              child: Transform.translate(
                offset: Offset(0, 14 * (1 - bodyMotion.value)),
                child: child,
              ),
            ),
            child: RepaintBoundary(child: _body(context)),
          ),
        ),
      ],
    ),
  );

  Widget _body(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text.rich(
          TextSpan(
            style: Type.question,
            children: [
              TextSpan(text: question.before.t),
              TextSpan(
                text: question.keyword.t,
                style: Type.question.copyWith(color: AppColors.accent),
              ),
              TextSpan(text: question.after.t),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(question.hint.t, style: Type.bodyMuted.copyWith(fontSize: 23)),
      const SizedBox(height: 36),
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gap = 22.0;
            final rows = (question.options.length / 2).ceil();
            final cardWidth = (constraints.maxWidth - gap) / 2;
            final minimumHeight = question.options
                .map(
                  (option) =>
                      ChoiceCard.minimumHeight(context, option, cardWidth),
                )
                .reduce(math.max);
            // 폭만으로 높이를 정하면 mini처럼 가로 비율이 긴 iPad에서
            // 두 번째 행이 스크롤 불가능한 뷰포트 아래로 잘린다.
            final cardHeight = math.max(
              minimumHeight,
              math.min(
                cardWidth / 2.4,
                (constraints.maxHeight - gap * (rows - 1)) / rows,
              ),
            );
            return GridView.count(
              key: ValueKey(index),
              padding: EdgeInsets.zero,
              // 기본 크기는 네 선택지를 한 번에 표시한다. 큰 글자에서만
              // 필요한 만큼 스크롤해 문구를 줄이거나 잘라내지 않는다.
              physics: const ClampingScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: gap,
              crossAxisSpacing: gap,
              mainAxisExtent: cardHeight,
              children: [
                for (final option in question.options)
                  ChoiceCard(
                    key: ValueKey(option.title),
                    option: option,
                    selected: selected == option.title,
                    onTap: () => onSelect(option),
                  ),
              ],
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : Motion.base,
          switchInCurve: Motion.curve,
          child: Container(
            key: ValueKey(error),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: error == null
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.red.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: error == null
                    ? Colors.white.withValues(alpha: 0.68)
                    : Colors.red.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘은 할 일이 생겼을 때만 나온다. 평상시 안내는 문구로
                // 충분하고, 장식으로 얹은 아이콘은 의미를 만들지 못한다.
                if (error != null) ...[
                  Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 9),
                ],
                Flexible(
                  child: Text(
                    error ??
                        (index == quizQuestions.length - 1
                            ? tr(
                                '선택하면 나에게 어울리는 다과를 알려드려요',
                                'Choose an answer to discover your dagwa',
                                '選ぶとあなたに似合う茶菓をご紹介します',
                              )
                            : tr(
                                '선택하면 다음 질문으로 넘어가요',
                                'Choose an answer to continue',
                                '選ぶと次の質問に進みます',
                              )),
                    style: Type.caption.copyWith(
                      fontSize: 18,
                      color: error == null
                          ? AppColors.muted
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
