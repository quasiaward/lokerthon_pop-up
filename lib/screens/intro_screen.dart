import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/tap_cue.dart';
import '../widgets/kiosk/brand_mark.dart';
import '../widgets/kiosk/glass_surface.dart';
import '../widgets/kiosk/rotating_dangwa_image.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.onStart, required this.onHome});

  final VoidCallback onStart;
  final VoidCallback onHome;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _starting = false;

  Future<void> _start() async {
    if (_starting) return;
    setState(() => _starting = true);

    if (!MediaQuery.disableAnimationsOf(context)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (mounted) widget.onStart();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    excludeFromSemantics: true,
    onTap: _start,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(88, 52, 88, 56),
      child: Column(
        children: [
          // 실제 버튼이 시작 제스처보다 먼저 터치를 처리한다.
          // 여백은 시작 영역으로, 이전·언어 버튼은 각자의 조작으로 유지한다.
          SizedBox(
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const BrandMark(compact: true),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _IntroBackControl(
                    onPressed: widget.onHome,
                    label: tr('이전으로', 'Back', '戻る'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Semantics(
              button: true,
              onTap: _start,
              excludeSemantics: true,
              label: tr(
                '화면을 터치해 다과 추천 질문 시작하기',
                'Touch the screen to start the recommendation questions',
                '画面をタッチして茶菓のおすすめ質問を始める',
              ),
              child: Column(
                children: [
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
                                  tracking: 2.6,
                                ),
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
                                constraints: const BoxConstraints(
                                  maxWidth: 620,
                                ),
                                child: Text(
                                  // 한국어·일본어는 음절 단위로 줄이 바뀌어서, 폭에 맡기면
                                  // "골라드/릴게요"처럼 낱말 중간이 끊긴다. 의미 단위로
                                  // 줄바꿈을 직접 넣어 둔다.
                                  tr(
                                    '6개의 짧은 질문으로,\n당신에게 어울리는 한국 전통 다과를 골라드릴게요.',
                                    'Answer 6 short questions and we will\nfind the Korean confection that suits you.',
                                    '6つの短い質問から、\nあなたに似合う韓国の伝統茶菓をお選びします。',
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
                          child: RotatingDangwaImage(
                            initialIndex: 4,
                            interval: Duration(milliseconds: 4900),
                            padding: 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedScale(
                    scale: _starting ? 0.985 : 1,
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : Motion.fast,
                    curve: Motion.curve,
                    child: TapCue(
                      supportingText: tr(
                        '화면 어디든 터치해\n나에게 어울리는 다과를 찾아보세요',
                        'Touch anywhere to discover\nthe dagwa that suits you',
                        '画面のどこでもタッチして\nあなたに似合う茶菓を見つけましょう',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 언어 선택기와 같은 높이·모서리·유리 농도를 쓰는 상단 이전 버튼.
class _IntroBackControl extends StatelessWidget {
  const _IntroBackControl({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: GlassSurface(
      radius: 24,
      blurBackdrop: true,
      child: Semantics(
        button: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 5, 17, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: Type.caption.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
