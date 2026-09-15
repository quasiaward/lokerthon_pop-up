import 'package:flutter/material.dart';
import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';
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
        child: KioskButton(label: tr('처음으로', 'Home'), onPressed: widget.onHome),
      );
    }
    final runnerUp =
        dagwaResults[result.runnerUp] ??
        dagwaResults[_runnerUpAliases[result.runnerUp]];
    return Stack(
      children: [
        ExcludeSemantics(
          excluding: _story,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(88, 48, 88, 52),
            child: Column(
              children: [
                TopControl(onHome: widget.onHome),
                const SizedBox(height: 32),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: DangwaImage(
                          assetPath: result.imagePath,
                          tone: toneFor(result.menuName),
                          aspectRatio: 0.95,
                          padding: 0.10,
                        ),
                      ),
                      const SizedBox(width: 60),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tr('당신과 가장 잘 어울리는 다과', 'Your dagwa today'),
                              style: Type.bodyMuted.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 18),
                            Text(result.menuName, style: Type.resultTitle),
                            const SizedBox(height: 22),
                            Text(
                              result.title,
                              style: Type.body.copyWith(
                                fontSize: 23,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_cafe_outlined,
                                  color: AppColors.muted,
                                  size: 26,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  tr('어울리는 차', 'Pairs with'),
                                  style: Type.bodyMuted.copyWith(fontSize: 21),
                                ),
                                const SizedBox(width: 18),
                                Flexible(
                                  child: Text(
                                    result.pairing,
                                    style: Type.section.copyWith(fontSize: 24),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),
                            KioskButton(
                              label: tr('이 다과 이야기 보기', 'Read the story'),
                              fullWidth: true,
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () => setState(() => _story = true),
                            ),
                            const SizedBox(height: 14),
                            KioskButton(
                              label: tr('다시 추천받기', 'Try again'),
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
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 76,
                          child: DangwaImage(
                            assetPath: runnerUp.imagePath,
                            tone: toneFor(runnerUp.menuName),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          tr('이런 다과도 잘 어울려요', 'You may also like'),
                          style: Type.bodyMuted.copyWith(fontSize: 21),
                        ),
                        const Spacer(),
                        Text(
                          runnerUp.menuName,
                          style: Type.section.copyWith(fontSize: 25),
                        ),
                      ],
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
            tone: toneFor(result.menuName),
            onClose: () => setState(() => _story = false),
          ),
      ],
    );
  }
}
