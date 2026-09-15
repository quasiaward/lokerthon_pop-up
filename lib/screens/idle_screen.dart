import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';

/// Idle 화면의 히어로로 세우는 대표 다과.
const _heroMenu = '수원약과';

/// 01 · Attract / Idle — 아무도 쓰지 않을 때 보이는 화면.
/// 사실상 팝업 공간의 디지털 포스터다. 2~3m 거리에서 걸음을 멈추게 만든다.
class IdleScreen extends StatefulWidget {
  const IdleScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onStart,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(96, 80, 96, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 상단 브랜드 마크 ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '행궁다과',
                  style: Type.section.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'TASTING KIOSK',
                  style: Type.eyebrow(
                    AppColors.faint,
                  ).copyWith(fontSize: 12, letterSpacing: 12 * 0.28),
                ),
              ],
            ),

            // ── 히어로 ──
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FadeUp(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            tr('취향으로 만나는', 'Found by taste'),
                            style: Type.bodyMuted.copyWith(fontSize: 19),
                          ),
                        ),
                        const SizedBox(height: Space.sm),
                        _FadeUp(
                          delay: const Duration(milliseconds: 450),
                          child: Text(
                            tr(
                              '오늘, 나와\n어울리는 다과는?',
                              'Which dagwa\nsuits you today?',
                            ),
                            style: Type.hero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Space.xxl),
                  // 히어로 오브젝트는 오른쪽 여백을 살짝 넘어간다.
                  Expanded(
                    flex: 6,
                    child: Transform.translate(
                      offset: const Offset(60, 0),
                      child: AnimatedBuilder(
                        animation: _breathe,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, -14 * _breathe.value),
                          child: Transform.scale(
                            scale: 1 + 0.012 * _breathe.value,
                            child: child,
                          ),
                        ),
                        child: DangwaImage(
                          assetPath: dagwaResults[_heroMenu]!.imagePath,
                          tone: toneFor(_heroMenu),
                          aspectRatio: 4 / 5,
                          padding: 0.14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 하단 CTA — 버튼 상자 없이 절제된 텍스트로 ──
            _TouchHint(controller: _breathe),
          ],
        ),
      ),
    );
  }
}

/// 느리게 명멸하는 터치 안내. 놀이공원 키오스크처럼 움직이지 않는다.
class _TouchHint extends StatelessWidget {
  const _TouchHint({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Opacity(
          opacity: 0.45 + 0.55 * t,
          child: Row(
            children: [
              Text(
                tr('화면을 터치해 시작하기', 'Touch anywhere to begin'),
                style: Type.bodyMuted.copyWith(fontSize: 19),
              ),
              const SizedBox(width: Space.sm),
              Transform.translate(
                offset: Offset(6 * t, 0),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 아래에서 위로 천천히 떠오르는 등장.
class _FadeUp extends StatefulWidget {
  const _FadeUp({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_FadeUp> createState() => _FadeUpState();
}

class _FadeUpState extends State<_FadeUp> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.12),
      duration: const Duration(milliseconds: 1000),
      curve: Motion.curve,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: const Duration(milliseconds: 1000),
        curve: Motion.curve,
        child: widget.child,
      ),
    );
  }
}
