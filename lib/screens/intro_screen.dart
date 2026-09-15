import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../data/quiz_questions.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/kiosk_button.dart';
import '../widgets/kiosk/top_control.dart';

/// Intro 화면에 장식으로 세우는 다과.
const _introMenu = '흑임자다식';

/// 02 · Intro — 시작해도 된다는 확신을 주는 화면.
/// 설명하는 화면이 아니므로 정보를 많이 보여주지 않는다.
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onStart, required this.onHome});

  final VoidCallback onStart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(96, 72, 96, 72),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('THE TASTING', 'THE TASTING'),
                      style: Type.eyebrow(AppColors.accent),
                    ),
                    const SizedBox(height: Space.lg),
                    Text(
                      tr('몇 가지 취향을\n알려주세요.', 'Tell us a few\nof your tastes.'),
                      style: Type.headline,
                    ),
                    const SizedBox(height: Space.xl),
                    SizedBox(
                      width: 520,
                      child: Text(
                        tr(
                          '${quizQuestions.length}개의 짧은 질문으로, 당신에게 어울리는 '
                              '한국 전통 다과를 골라드릴게요.',
                          'Answer ${quizQuestions.length} short questions and we will '
                              'find the Korean confection that suits you.',
                        ),
                        style: Type.body.copyWith(
                          fontSize: 23,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.x3),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: DangwaImage(
                    assetPath: dagwaResults[_introMenu]!.imagePath,
                    tone: toneFor(_introMenu),
                    padding: 0.16,
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(left: 96, top: 64, child: TopControl(onHome: onHome)),

        // 하단에 고정된 전폭 primary CTA.
        Positioned(
          left: 96,
          right: 96,
          bottom: 64,
          child: Column(
            children: [
              KioskButton(
                label: tr('다과 추천 시작하기', 'Start the tasting'),
                onPressed: onStart,
                fullWidth: true,
              ),
              const SizedBox(height: Space.md),
              Text(
                tr('약 1분이면 충분해요', 'It takes about a minute'),
                style: Type.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
