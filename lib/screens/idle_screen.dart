import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/brand_mark.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/kiosk_button.dart';

/// 언어 토글이 화면 우상단에 떠 있는 만큼, 그 아래 콘텐츠를 내려 주는 여백.
/// 토글은 `kiosk_page.dart`에서 top: 52에 높이 약 56으로 놓인다.
const double _langToggleClearance = 48;

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
                        style: Type.eyebrow(AppColors.accent, tracking: 3.2),
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
                  // 언어 토글이 이 칼럼 바로 위에 떠 있다. 위쪽을 비워 두지 않으면
                  // 카드가 토글에 붙어 답답해 보인다. 카드도 세로를 꽉 채우는 대신
                  // 비율로 크기를 잡고 가운데에 둔다.
                  child: Padding(
                    padding: const EdgeInsets.only(top: _langToggleClearance),
                    child: Center(
                      child: DangwaImage(
                        assetPath: dagwaResults['수원약과']!.imagePath,
                        tone: toneFor('수원약과'),
                        aspectRatio: 0.78,
                        padding: 0.08,
                      ),
                    ),
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
