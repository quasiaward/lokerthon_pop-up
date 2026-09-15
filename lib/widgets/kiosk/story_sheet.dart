import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/dagwa_results.dart';
import '../../data/dagwa_tones.dart';
import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'glass_surface.dart';
import 'kiosk_button.dart';

/// 다과 상세 이야기. 화면을 정보 페이지로 만들지 않기 위해 아래에서 올라오는
/// 시트로 처리한다. 기존 결과 문구를 그대로 조판만 바꿔 보여 준다.
class StorySheet extends StatefulWidget {
  const StorySheet({
    super.key,
    required this.result,
    required this.tone,
    required this.onClose,
  });

  final DagwaResult result;
  final DagwaTone tone;
  final VoidCallback onClose;

  @override
  State<StorySheet> createState() => _StorySheetState();
}

class _StorySheetState extends State<StorySheet> {
  bool _up = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _up = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Stack(
      children: [
        // 뒤 화면을 눌러도 닫힌다.
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: AnimatedOpacity(
              opacity: _up ? 1 : 0,
              duration: Motion.fast,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: ColoredBox(color: AppColors.ink.withValues(alpha: 0.22)),
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSlide(
            offset: _up ? Offset.zero : const Offset(0, 1),
            duration: Motion.slow,
            curve: Motion.curve,
            child: GlassSurface(
              strong: true,
              blurBackdrop: true, // 뒤에 결과 화면이 있어 실제로 가려야 한다
              radius: Radii.sheet,
              child: SizedBox(
                width: 1366,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(96, 20, 96, 56),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 손잡이
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.lineStrong,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: Space.xl),

                      Text('THE STORY', style: Type.eyebrow(widget.tone.deep)),
                      const SizedBox(height: Space.md),
                      Text(
                        r.menuName,
                        style: Type.section.copyWith(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Space.lg),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Text(
                              r.description,
                              style: Type.body.copyWith(
                                fontSize: 20,
                                height: 1.65,
                              ),
                            ),
                          ),
                          const SizedBox(width: Space.x3),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Note(
                                  label: tr(
                                    '어울리는 차 · ${r.pairing}',
                                    'Pairs with · ${r.pairing}',
                                  ),
                                  body: r.pairingDesc,
                                  tone: widget.tone.deep,
                                ),
                                const SizedBox(height: Space.lg),
                                _Note(
                                  label: tr(
                                    '이런 다과도 · ${r.runnerUp}',
                                    'Also try · ${r.runnerUp}',
                                  ),
                                  body: r.runnerUpDesc,
                                  tone: widget.tone.deep,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: Space.xl),
                      Center(
                        child: SizedBox(
                          width: 420,
                          child: KioskButton(
                            label: tr('닫기', 'Close'),
                            onPressed: widget.onClose,
                            fullWidth: true,
                            accentColor: widget.tone.deep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.label, required this.body, required this.tone});

  final String label;
  final String body;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Type.eyebrow(tone, latin: false, size: 13)),
        const SizedBox(height: Space.xs),
        Text(body, style: Type.bodyMuted.copyWith(fontSize: 18, height: 1.55)),
      ],
    );
  }
}
