import 'package:flutter/material.dart';

import '../data/quiz_questions.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/choice_card.dart';
import '../widgets/kiosk/kiosk_progress.dart';
import '../widgets/kiosk/top_control.dart';

/// 03 · Question — 한 화면에 질문 하나.
///
/// 질문과 선택지는 기존 서비스의 것을 그대로 쓴다. 이 화면이 새로 만드는 것은
/// 조판과 배치, 선택의 감각뿐이다.
class QuestionScreen extends StatelessWidget {
  const QuestionScreen({
    super.key,
    required this.index,
    required this.question,
    required this.selected,
    required this.onSelect,
    required this.onBack,
    required this.onHome,
  });

  final int index;
  final QuizQuestion question;
  final String? selected;
  final ValueChanged<QuizOption> onSelect;
  final VoidCallback? onBack;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(96, 72, 96, 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TopControl(onBack: onBack, onHome: onHome),
              KioskProgress(step: index + 1, total: quizQuestions.length),
            ],
          ),

          // 상단 진행 표시는 자리를 지키고, 질문 블록만 옆으로 흘러 들어온다.
          Expanded(
            child: AnimatedSwitcher(
              duration: Motion.base,
              switchInCurve: Motion.curve,
              switchOutCurve: Motion.curve,
              transitionBuilder: (child, animation) {
                final incoming = child.key == ValueKey(index);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(incoming ? 0.035 : -0.02, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: RepaintBoundary(
                key: ValueKey(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuestionHeading(index: index, question: question),
                    const SizedBox(height: Space.xxl),
                    _ChoiceGrid(
                      question: question,
                      selected: selected,
                      onSelect: onSelect,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionHeading extends StatelessWidget {
  const _QuestionHeading({required this.index, required this.question});

  final int index;
  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final number = (index + 1).toString().padLeft(2, '0');

    return SizedBox(
      width: 900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TASTE $number', style: Type.eyebrow(AppColors.accent)),
          const SizedBox(height: Space.md),
          // 질문의 핵심 낱말만 accent로 들어 올린다.
          Text.rich(
            TextSpan(
              children: isEn
                  ? [
                      TextSpan(text: question.beforeEn),
                      TextSpan(
                        text: question.keywordEn,
                        style: TextStyle(color: AppColors.accent),
                      ),
                      TextSpan(text: question.afterEn),
                    ]
                  : [
                      TextSpan(text: question.before),
                      TextSpan(
                        text: question.keyword,
                        style: TextStyle(color: AppColors.accent),
                      ),
                      TextSpan(text: question.after),
                    ],
            ),
            style: Type.question,
          ),
          const SizedBox(height: Space.md),
          Text(tr(question.hint, question.hintEn), style: Type.bodyMuted),
        ],
      ),
    );
  }
}

/// 선택지 배치. 4개면 2×2, 3개면 3열, 2개면 2열.
class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final QuizQuestion question;
  final String? selected;
  final ValueChanged<QuizOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final options = question.options;
    final columns = options.length == 4 ? 2 : options.length;
    const gap = Space.lg;
    const cardHeight = 172.0;

    final rows = <Widget>[];
    for (var i = 0; i < options.length; i += columns) {
      final slice = options.skip(i).take(columns).toList();
      rows.add(
        SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              for (var j = 0; j < slice.length; j++) ...[
                if (j > 0) const SizedBox(width: gap),
                Expanded(
                  child: ChoiceCard(
                    option: slice[j],
                    selected: selected == slice[j].title,
                    onTap: () => onSelect(slice[j]),
                  ),
                ),
              ],
              // 마지막 줄이 덜 찼을 때 남는 칸을 비워 정렬을 유지한다.
              for (var k = slice.length; k < columns; k++) ...[
                const SizedBox(width: gap),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );
      if (i + columns < options.length) {
        rows.add(const SizedBox(height: gap));
      }
    }

    return Column(children: rows);
  }
}
