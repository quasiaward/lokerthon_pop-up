import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'glass_surface.dart';

/// "화면을 터치하면 시작된다"를 알리는 표시.
///
/// **버튼이 아니다.** Idle과 Intro 모두 화면 전체가 탭 영역이고, 이 위젯은
/// 그 사실을 알리는 안내다. 그래서 강조색으로 채운 CTA 대신 배경이 비치는
/// 가벼운 유리 캡슐을 써서, 행동은 또렷하게 보이되 특정 부분만 눌러야 한다는
/// 인상을 줄인다.
///
/// 멀리서도 눈에 들어와야 하는 몫은 대비가 아니라 움직임이 맡는다. 정지한
/// 고대비 덩어리보다 느린 파문이 주변시를 훨씬 잘 잡는다.
class TapCue extends StatefulWidget {
  const TapCue({super.key, this.supportingText});

  /// 다음 화면에서만 필요한 짧은 보조 설명. 안내 캡슐보다 위에 두어
  /// 캡슐 자체의 하단 위치는 화면마다 달라지지 않게 한다.
  final String? supportingText;

  @override
  State<TapCue> createState() => _TapCueState();
}

class _TapCueState extends State<TapCue> with TickerProviderStateMixin {
  static const _size = 60.0;

  /// 밖으로 번져 나가는 파문.
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _pulse.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.supportingText case final text?) ...[
          Text(
            text,
            textAlign: TextAlign.center,
            style: Type.caption.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),
        ],
        RepaintBoundary(
          key: const ValueKey('tap-cue-surface'),
          child: GlassSurface(
            radius: 36,
            blurBackdrop: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 22, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: _size,
                    height: _size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) {
                            final wave = Curves.easeOut.transform(_pulse.value);
                            return Transform.scale(
                              scale: 0.82 + (0.34 * wave),
                              child: Opacity(
                                opacity: (0.42 * (1 - wave)).clamp(0.0, 1.0),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accent,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.96),
                                AppColors.accentSoft.withValues(alpha: 0.9),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.16),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.touch_app_rounded,
                            color: AppColors.accent,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    tr(
                      '화면 어디든 터치해 시작하기',
                      'Touch anywhere to begin',
                      '画面のどこでもタッチして開始',
                    ),
                    style: Type.section.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.25,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
