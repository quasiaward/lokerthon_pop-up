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
    duration: const Duration(milliseconds: 2600),
  );

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
                builder: (context, _) {
                  final progress = _motion.value;
                  final rawWave = progress <= 0.5
                      ? progress * 2
                      : (1 - progress) * 2;
                  final wave = Curves.easeInOutCubic.transform(rawWave);
                  return Transform.translate(
                    offset: Offset(0, 1.5 * wave),
                    child: Opacity(
                      opacity: 0.74 + (0.16 * wave),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.blossomSoft.withValues(
                                      alpha: 0.28 + (0.05 * wave),
                                    ),
                                    AppColors.blossom.withValues(alpha: 0.05),
                                    Colors.transparent,
                                  ],
                                  stops: const [0, 0.55, 1],
                                ),
                              ),
                              child: const SizedBox.square(dimension: 64),
                            ),
                            CustomPaint(
                              size: const Size.square(72),
                              painter: _TapRipplesPainter(intensity: wave),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 19),
                              child: Icon(
                                Icons.touch_app_outlined,
                                size: 41,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
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

/// 손끝 위에 두 개의 점선 반원을 그린다. 닫힌 동심원을 피해서 신호가 위쪽으로
/// 열리고, 배경과 맞닿은 안내가 답답해 보이지 않게 한다.
class _TapRipplesPainter extends CustomPainter {
  const _TapRipplesPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 17);
    final paint = Paint()..color = AppColors.charcoal;

    for (var ring = 0; ring < 2; ring++) {
      final radius = 8 + (ring * 6.2) + (intensity * 0.7);
      final dots = 11 + (ring * 7);
      final alpha = (0.68 - (ring * 0.16)) * (0.82 + (0.18 * intensity));
      for (var i = 0; i < dots; i++) {
        final angle = math.pi + ((math.pi * i) / (dots - 1));
        final point = Offset(
          center.dx + (math.cos(angle) * radius),
          center.dy + (math.sin(angle) * radius),
        );
        canvas.drawCircle(
          point,
          ring == 0 ? 0.85 : 0.7,
          paint..color = AppColors.charcoal.withValues(alpha: alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TapRipplesPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}
