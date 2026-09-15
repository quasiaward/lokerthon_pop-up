import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/brand_mark.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/glass_surface.dart';
import '../widgets/kiosk/kiosk_button.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onStart, required this.onHome});

  final VoidCallback onStart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(88, 52, 88, 58),
    child: Column(
      children: [
        SizedBox(
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const BrandMark(compact: true),
              Align(
                alignment: Alignment.centerLeft,
                child: GlassSurface(
                  radius: 22,
                  blurBackdrop: true,
                  child: TextButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.arrow_back_rounded, size: 23),
                    label: Text(tr('이전으로', 'Back', '戻る')),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.charcoal,
                      minimumSize: const Size(132, 54),
                      textStyle: Type.caption.copyWith(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
                      'YOUR TASTE, OUR HERITAGE',
                      style: Type.eyebrow(
                        AppColors.accent,
                      ).copyWith(letterSpacing: 2.6),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tr(
                        '몇 가지 취향을\n알려주세요.',
                        'Tell us a few\nof your tastes.',
                        'いくつかの好みを\n教えてください。',
                      ),
                      style: Type.headline,
                    ),
                    const SizedBox(height: 28),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 590),
                      child: Text(
                        tr(
                          '6개의 짧은 질문으로, 당신에게 어울리는 한국 전통 다과를 골라드릴게요.',
                          'Answer 6 short questions and we will find the Korean confection that suits you.',
                          '6つの短い質問から、あなたに似合う韓国の伝統茶菓をお選びします。',
                        ),
                        style: Type.bodyMuted.copyWith(
                          fontSize: 23,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 70),
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
          label: tr('다과 추천 시작하기', 'Start the tasting', '茶菓さがしを始める'),
          onPressed: onStart,
          fullWidth: true,
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: 16),
        Text(
          tr(
            '천천히 골라도 약 1분이면 충분해요',
            'Take your time—it takes about a minute',
            'ゆっくり選んでも約1分で終わります',
          ),
          style: Type.caption.copyWith(fontSize: 18),
        ),
      ],
    ),
  );
}
