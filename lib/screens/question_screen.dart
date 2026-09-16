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
    this.error,
  });
  final int index;
  final QuizQuestion question;
  final String? selected;
  final ValueChanged<QuizOption> onSelect;
  final VoidCallback? onBack;
  final VoidCallback onHome;
  final String? error;
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
          child: GridView.count(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 22,
            crossAxisSpacing: 22,
            childAspectRatio: 2.4,
            children: [
              for (final option in question.options)
                ChoiceCard(
                  key: ValueKey(option.title),
                  option: option,
                  selected: selected == option.title,
                  onTap: () => onSelect(option),
                ),
            ],
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
                  Text(
                    error ??
                        tr(
                          '선택하면 다음 질문으로 넘어가요',
                          'Choose an answer to continue',
                          '選ぶと次の質問に進みます',
                        ),
                    style: Type.caption.copyWith(
                      fontSize: 18,
                      color: error == null
                          ? AppColors.muted
                          : Colors.red.shade700,
                    ),
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
