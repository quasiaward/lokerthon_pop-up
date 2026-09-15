import 'package:flutter/material.dart';
import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/kiosk_button.dart';

class IdleScreen extends StatelessWidget {
  const IdleScreen({super.key, required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onStart,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(88, 64, 88, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '행궁다과',
            style: Type.section.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
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
                        tr(
                          '오늘, 나와\n어울리는 다과는?',
                          'Which dagwa\nsuits you today?',
                        ),
                        style: Type.hero,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        tr('취향으로 만나는', 'Found by taste'),
                        style: Type.bodyMuted.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 48),
                      KioskButton(
                        label: tr('취향 알아보기', 'Find my taste'),
                        onPressed: onStart,
                        icon: Icons.arrow_forward_rounded,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        tr('약 1분 · 6개의 질문', 'About 1 minute · 6 questions'),
                        style: Type.caption.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 5,
                  child: DangwaImage(
                    assetPath: dagwaResults['수원약과']!.imagePath,
                    tone: toneFor('수원약과'),
                    padding: 0.08,
                    aspectRatio: 0.88,
                  ),
                ),
              ],
            ),
          ),
          Text(
            tr('화면을 터치해 시작하기', 'Touch anywhere to begin'),
            style: Type.caption.copyWith(fontSize: 20),
          ),
        ],
      ),
    ),
  );
}
