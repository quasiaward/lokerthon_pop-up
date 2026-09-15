import 'package:flutter/material.dart';
import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../data/quiz_questions.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/kiosk_button.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onStart, required this.onHome});
  final VoidCallback onStart;
  final VoidCallback onHome;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(88, 56, 88, 64),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: onHome,
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(tr('이전으로', 'Back')),
          style: TextButton.styleFrom(minimumSize: const Size(120, 56)),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tr('몇 가지 취향을\n알려주세요.', 'Tell us a few\nof your tastes.'),
                      style: Type.headline,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      tr(
                        '${quizQuestions.length}개의 짧은 질문으로, 당신에게 어울리는 한국 전통 다과를 골라드릴게요.',
                        'Answer ${quizQuestions.length} short questions and we will find the Korean confection that suits you.',
                      ),
                      style: Type.bodyMuted.copyWith(fontSize: 25, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                flex: 5,
                child: DangwaImage(
                  assetPath: dagwaResults['흑임자다식']!.imagePath,
                  tone: toneFor('흑임자다식'),
                  padding: 0.10,
                ),
              ),
            ],
          ),
        ),
        KioskButton(
          label: tr('다과 추천 시작하기', 'Start the tasting'),
          onPressed: onStart,
          fullWidth: true,
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            tr('약 1분이면 충분해요', 'It takes about a minute'),
            style: Type.caption.copyWith(fontSize: 20),
          ),
        ),
      ],
    ),
  );
}
