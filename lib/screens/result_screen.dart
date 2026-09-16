import 'package:flutter/material.dart';
import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/glass_surface.dart';
import '../widgets/kiosk/kiosk_button.dart';
import '../widgets/kiosk/top_control.dart';
import '../widgets/kiosk/story_sheet.dart';

const _runnerUpAliases = <String, String>{'견과류 강정': '구움 견과 강정'};

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.menuName,
    required this.onRestart,
    required this.onHome,
  });
  final String menuName;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _story = const bool.fromEnvironment('KIOSK_STORY');
  @override
  Widget build(BuildContext context) {
    final result = dagwaResults[widget.menuName];
    if (result == null) {
      return Center(
        child: KioskButton(
          label: tr('처음으로', 'Home', 'はじめに戻る'),
          onPressed: widget.onHome,
        ),
      );
    }
    final runnerUp =
        dagwaResults[result.runnerUp] ??
        dagwaResults[_runnerUpAliases[result.runnerUp]];
    final tone = toneFor(result.menuName);
    return Stack(
      children: [
        ExcludeSemantics(
          excluding: _story,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(88, 48, 88, 52),
            child: Column(
              children: [
                TopControl(onHome: widget.onHome),
                const SizedBox(height: 28),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: DangwaImage(
                          assetPath: result.imagePath,
                          tone: tone,
                          aspectRatio: 0.95,
                          padding: 0.10,
                        ),
                      ),
                      const SizedBox(width: 64),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tr(
                                '당신과 가장 잘 어울리는 다과',
                                'Your dagwa today',
                                'あなたにいちばん似合う茶菓',
                              ),
                              // 번역되는 문구라 언어에 따라 자간을 가른다.
                              style: Type.eyebrow(
                                tone.deep,
                                latin: isEn,
                                tracking: 3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // 한국어·일본어 이름은 한 줄, 긴 영어 이름은 두 줄까지
                            // 흐른다. 칼럼은 세로 가운데 정렬이라 두 줄이 되어도
                            // 구성이 무너지지 않는다. 억지로 한 줄에 맞추면
                            // 45px까지 작아져 주인공 자리를 잃는다.
                            Text(
                              result.name.t,
                              maxLines: 2,
                              style: Type.resultTitle.copyWith(height: 1.12),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              result.title.t,
                              style: Type.body.copyWith(
                                fontSize: 22,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 26),
                            GlassSurface(
                              radius: 24,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 18,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: const BoxDecoration(
                                        color: AppColors.celadonSoft,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.local_cafe_outlined,
                                        color: tone.deep,
                                        size: 23,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      tr('어울리는 차', 'Pairs with', '相性のよいお茶'),
                                      style: Type.bodyMuted.copyWith(
                                        fontSize: 19,
                                      ),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                      child: Text(
                                        result.pairing.t,
                                        textAlign: TextAlign.right,
                                        style: Type.section.copyWith(
                                          fontSize: 22,
                                          color: tone.deep,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            KioskButton(
                              label: tr(
                                '이 다과 이야기 보기',
                                'Read the story',
                                'この茶菓の物語を読む',
                              ),
                              fullWidth: true,
                              icon: Icons.arrow_forward_rounded,
                              accentColor: tone.deep,
                              onPressed: () => setState(() => _story = true),
                            ),
                            const SizedBox(height: 12),
                            KioskButton(
                              label: tr('다시 추천받기', 'Try again', 'もう一度さがす'),
                              fullWidth: true,
                              variant: KioskButtonVariant.secondary,
                              onPressed: widget.onRestart,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (runnerUp != null) ...[
                  const SizedBox(height: 24),
                  GlassSurface(
                    radius: 26,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            child: DangwaImage(
                              assetPath: runnerUp.imagePath,
                              tone: toneFor(runnerUp.menuName),
                            ),
                          ),
                          const SizedBox(width: 22),
                          Text(
                            tr(
                              '이런 다과도 잘 어울려요',
                              'You may also like',
                              'こちらの茶菓もおすすめです',
                            ),
                            style: Type.bodyMuted.copyWith(fontSize: 19),
                          ),
                          const Spacer(),
                          Text(
                            runnerUp.name.t,
                            style: Type.section.copyWith(
                              fontSize: 23,
                              color: AppColors.accentDeep,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.celadon,
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_story)
          StorySheet(
            result: result,
            tone: tone,
            onClose: () => setState(() => _story = false),
          ),
      ],
    );
  }
}
