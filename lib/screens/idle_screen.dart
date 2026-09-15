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

class IdleScreen extends StatelessWidget {
  const IdleScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onStart,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(88, 60, 88, 58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TASTE OF HWASEONG',
                        style: Type.eyebrow(
                          AppColors.accent,
                        ).copyWith(letterSpacing: 3.2),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        tr(
                          '오늘, 나와\n어울리는 다과는?',
                          'Which dagwa\nsuits you today?',
                          '今日のあなたに\n似合う茶菓は？',
                        ),
                        style: Type.hero,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tr(
                          '수원에서 빚은 다과를 취향으로 만나보세요.',
                          'Meet Suwon through a confection chosen for you.',
                          '水原で生まれた茶菓を、あなたの好みから見つけます。',
                        ),
                        style: Type.bodyMuted.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 42),
                      SizedBox(
                        width: 340,
                        child: KioskButton(
                          label: tr('취향 알아보기', 'Find my taste', '好みを見つける'),
                          onPressed: onStart,
                          fullWidth: true,
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        tr(
                          '약 1분 · 6개의 질문',
                          'About 1 minute · 6 questions',
                          '約1分 · 6つの質問',
                        ),
                        style: Type.caption.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 54),
                Expanded(
                  flex: 5,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: DangwaImage(
                          assetPath: dagwaResults['수원약과']!.imagePath,
                          tone: toneFor('수원약과'),
                          padding: 0.08,
                          aspectRatio: 0.9,
                        ),
                      ),
                      Positioned(
                        left: -28,
                        bottom: 48,
                        child: GlassSurface(
                          radius: 24,
                          blurBackdrop: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: AppColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  tr(
                                    '행궁에서 만나는 한입',
                                    'A bite of Haenggung',
                                    'ヘングンで出会うひと口',
                                  ),
                                  style: Type.caption.copyWith(
                                    fontSize: 18,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            tr('화면 어디든 터치해 시작하기', 'Touch anywhere to begin', '画面のどこでもタッチして開始'),
            style: Type.caption.copyWith(fontSize: 18),
          ),
        ],
      ),
    ),
  );
}
