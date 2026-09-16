import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// 화면 전체가 터치 영역임을 알려 주는 수채화 제스처 안내.
///
/// 버튼처럼 보이는 별도 표면은 두지 않는다. 배경 장식과 같은 수채화 결 위에
/// 가느다란 손가락 픽토그램을 놓아 화면의 일부가 아니라 장면 전체를 터치하라는
/// 의미를 전달한다.
class TapCue extends StatefulWidget {
  const TapCue({super.key, this.supportingText});

  /// 화면에 맞는 시작 안내. 두 줄까지 같은 영역에 배치한다.
  final String? supportingText;

  @override
  State<TapCue> createState() => _TapCueState();
}

class _TapCueState extends State<TapCue> with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  // 잠깐 쉬고 → 손을 들어 → 톡 누르고 → 원위치로 돌아오는 한 번의 제스처.
  // 파문은 손과 함께 움직이지 않고 실제로 누른 자리에 남는다.
  static final _handTravel = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0), weight: 12),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: -8.0,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 18,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: -8.0,
        end: 2.0,
      ).chain(CurveTween(curve: Curves.easeInCubic)),
      weight: 10,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 2.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 18,
    ),
    TweenSequenceItem(tween: ConstantTween(0), weight: 42),
  ]);
  static final _press = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0), weight: 30),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInCubic)),
      weight: 10,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 18,
    ),
    TweenSequenceItem(tween: ConstantTween(0), weight: 42),
  ]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
      _motion.value = 0;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label =
        widget.supportingText ??
        tr('화면 어디든 터치해 시작하기', 'Touch anywhere to begin', '画面のどこでもタッチして開始');

    return RepaintBoundary(
      key: const ValueKey('tap-cue-surface'),
      child: SizedBox(
        width: 480,
        height: 142,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              height: 48,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Type.caption.copyWith(
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 56,
              child: AnimatedBuilder(
                animation: _motion,
                child: const Icon(
                  Icons.touch_app_outlined,
                  size: 46,
                  color: AppColors.charcoal,
                ),
                builder: (context, hand) {
                  final progress = _motion.value;
                  final press = _press.transform(progress);
                  return SizedBox.square(
                    dimension: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppColors.blossom.withValues(
                                  alpha: 0.10 + 0.16 * press,
                                ),
                                AppColors.blossomSoft.withValues(alpha: 0.10),
                                Colors.transparent,
                              ],
                              stops: const [0, 0.55, 1],
                            ),
                          ),
                          child: const SizedBox.square(dimension: 76),
                        ),
                        CustomPaint(
                          size: const Size.square(80),
                          painter: _TapRipplesPainter(
                            progress: progress,
                            reduced: MediaQuery.disableAnimationsOf(context),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, _handTravel.transform(progress)),
                          child: Transform.scale(
                            scale: 1 - 0.09 * press,
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: hand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 손끝이 닿는 순간 두 개의 열린 점선 파문이 짧게 퍼지고 사라진다.
/// 큰 동심원이나 버튼 테두리 없이 터치 동작 자체를 강조한다.
class _TapRipplesPainter extends CustomPainter {
  const _TapRipplesPainter({required this.progress, required this.reduced});

  final double progress;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 27);
    final paint = Paint();

    for (var ring = 0; ring < 2; ring++) {
      final elapsed = (progress - 0.39 - ring * 0.09) / 0.34;
      if (!reduced && (elapsed < 0 || elapsed > 1)) continue;
      final radius = reduced
          ? 9.0 + ring * 7
          : 8 + 18 * Curves.easeOutCubic.transform(elapsed);
      final alpha = reduced
          ? 0.38 - ring * 0.1
          : 0.65 * math.pow(1 - elapsed, 1.3);
      paint.color = AppColors.accent.withValues(alpha: alpha.toDouble());
      final dots = 13 + ring * 6;
      for (var i = 0; i < dots; i++) {
        final angle = math.pi + math.pi * i / (dots - 1);
        canvas.drawCircle(
          Offset(
            center.dx + math.cos(angle) * radius,
            center.dy + math.sin(angle) * radius,
          ),
          1.05 - ring * 0.15,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TapRipplesPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.reduced != reduced;
}
