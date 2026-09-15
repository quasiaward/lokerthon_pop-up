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
          child: Text(
            tr(question.titleKo, question.titleEn),
            style: Type.question,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tr(question.hint, question.hintEn),
          style: Type.bodyMuted.copyWith(fontSize: 23),
        ),
        const SizedBox(height: 36),
        Expanded(
          child: GridView.count(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 22,
            crossAxisSpacing: 22,
            childAspectRatio: 2.72,
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
          child: Text(
            error ?? tr('선택하면 다음 질문으로 넘어가요', 'Choose an answer to continue'),
            style: Type.caption.copyWith(
              fontSize: 19,
              color: error == null ? AppColors.muted : Colors.red.shade700,
            ),
          ),
        ),
      ],
    ),
  );
}
