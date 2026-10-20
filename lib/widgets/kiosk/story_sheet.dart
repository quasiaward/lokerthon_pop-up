import 'package:flutter/material.dart';

import '../../data/dagwa_results.dart';
import '../../data/dagwa_tones.dart';
import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'brand_mark.dart';
import 'glass_surface.dart';
import 'kiosk_button.dart';

class StorySheet extends StatefulWidget {
  const StorySheet({
    super.key,
    required this.result,
    required this.tone,
    required this.onClose,
    this.onActivity,
  });

  final DagwaResult result;
  final DagwaTone tone;
  final VoidCallback onClose;
  final VoidCallback? onActivity;

  @override
  State<StorySheet> createState() => _StorySheetState();
}

class _StorySheetState extends State<StorySheet>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Motion.slow,
    reverseDuration: Motion.base,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.curve,
    reverseCurve: Curves.easeInCubic,
  );
  final _scroll = ScrollController();
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed && !_closing) {
      _controller.forward();
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    widget.onActivity?.call();
    _closing = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      try {
        await _controller.reverse().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (mounted) widget.onClose();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      namesRoute: true,
      label: tr('다과 이야기', 'Dagwa story', '茶菓の物語'),
      child: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _curve,
              child: ModalBarrier(
                color: AppColors.accentDeep.withValues(alpha: 0.38),
                dismissible: true,
                onDismiss: _close,
                semanticsLabel: tr('닫기', 'Close', '閉じる'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_curve),
              child: ScaleTransition(
                scale: Tween(begin: 0.985, end: 1.0).animate(_curve),
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: GlassSurface(
                    radius: Radii.sheet,
                    strong: true,
                    blurBackdrop: true,
                    child: SizedBox(
                      width: 1188,
                      height: 824,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(48, 18, 48, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 54,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.lineStrong.withValues(
                                    alpha: 0.42,
                                  ),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const BrandMark(compact: true),
                                const Spacer(),
                                Text(
                                  'THE STORY',
                                  style: Type.eyebrow(
                                    AppColors.accent,
                                    tracking: 2.8,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                IconButton(
                                  onPressed: _close,
                                  tooltip: tr('닫기', 'Close', '閉じる'),
                                  icon: const Icon(Icons.close_rounded),
                                  color: AppColors.charcoal,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.46,
                                    ),
                                    minimumSize: const Size(48, 48),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    result.name.t,
                                    style: Type.resultTitle.copyWith(
                                      fontSize: 48,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 54,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        widget.tone.deep,
                                        AppColors.celadon,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: Scrollbar(
                                controller: _scroll,
                                thumbVisibility: true,
                                // 마지막 줄까지 선명하게 읽을 수 있도록 스크롤바로만
                                // 이어지는 내용을 알린다. 고정 마스크는 끝에서도 글을 가린다.
                                child: SingleChildScrollView(
                                  controller: _scroll,
                                  padding: const EdgeInsets.only(
                                    right: 24,
                                    bottom: 32,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.description.t,
                                        style: Type.body.copyWith(
                                          fontSize: 22,
                                          height: 1.68,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      _Note(
                                        icon: Icons.local_cafe_rounded,
                                        label: tr(
                                          '어울리는 차',
                                          'Pairs with',
                                          '相性のよいお茶',
                                        ),
                                        value: result.pairing.t,
                                        body: result.pairingDesc.t,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            KioskButton(
                              label: tr('닫기', 'Close', '閉じる'),
                              onPressed: _close,
                              fullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상세 시트 하단의 부가 정보 한 칸.
///
/// [label]은 무엇에 대한 항목인지, [value]는 그 답이다. 둘을 하나의 문자열로
/// 이어 붙이면 같은 굵기로 나란히 놓여 어디까지가 항목이고 어디부터가 답인지
/// 눈이 구분하지 못한다. 크기와 색을 갈라 답이 먼저 읽히게 한다.
class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.label,
    required this.value,
    required this.body,
  });

  final IconData icon;
  final String label;
  final String value;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.48),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.celadonSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accent, size: 23),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    label,
                    style: Type.caption.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      value,
                      style: Type.section.copyWith(
                        fontSize: 23,
                        color: AppColors.accentDeep,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: Type.bodyMuted.copyWith(fontSize: 20, height: 1.55),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
