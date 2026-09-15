import 'package:flutter/material.dart';
import '../../data/dagwa_results.dart';
import '../../data/dagwa_tones.dart';
import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'kiosk_button.dart';

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
    final r = widget.result;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      namesRoute: true,
      label: tr('다과 이야기', 'Dagwa story'),
      child: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _curve,
              child: ModalBarrier(
                color: AppColors.ink.withValues(alpha: 0.32),
                dismissible: true,
                onDismiss: _close,
                semanticsLabel: tr('닫기', 'Close'),
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
              child: Container(
                width: 1190,
                height: 840,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                padding: const EdgeInsets.fromLTRB(48, 20, 48, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.mist,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('THE STORY', style: Type.eyebrow(AppColors.accent)),
                    const SizedBox(height: 12),
                    Text(
                      r.menuName,
                      style: Type.section.copyWith(fontSize: 40),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: Scrollbar(
                        controller: _scroll,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scroll,
                          padding: const EdgeInsets.only(right: 24, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.description,
                                style: Type.body.copyWith(
                                  fontSize: 23,
                                  height: 1.65,
                                ),
                              ),
                              const SizedBox(height: 32),
                              _Note(
                                label: tr(
                                  '어울리는 차 · ${r.pairing}',
                                  'Pairs with · ${r.pairing}',
                                ),
                                body: r.pairingDesc,
                              ),
                              const SizedBox(height: 20),
                              _Note(
                                label: tr(
                                  '이런 다과도 · ${r.runnerUp}',
                                  'Also try · ${r.runnerUp}',
                                ),
                                body: r.runnerUpDesc,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    KioskButton(
                      label: tr('닫기', 'Close'),
                      onPressed: _close,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.label, required this.body});
  final String label;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.ground,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Type.section.copyWith(fontSize: 24)),
        const SizedBox(height: 12),
        Text(body, style: Type.bodyMuted.copyWith(fontSize: 21, height: 1.6)),
      ],
    ),
  );
}
