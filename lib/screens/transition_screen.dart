import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/brand_mark.dart';
import '../widgets/kiosk/glass_surface.dart';

/// 결과 공개 직전의 로딩 연출.
///
/// 결과는 이미 정해져 있지만 여기서는 드러내지 않는다. 다과 이미지나
/// "찾았어요" 같은 문구를 먼저 보여 주면 결과 화면의 공개가 김이 빠진다.
class TransitionScreen extends StatefulWidget {
  const TransitionScreen({
    super.key,
    required this.menuName,
    required this.onDone,
  });

  final String menuName;
  final VoidCallback onDone;
  static const duration = Duration(milliseconds: 3000);

  /// 둘레를 도는 점이 로딩 동안 도는 바퀴 수. 딱 떨어져야 한 바퀴를 다 돈
  /// 뒤 결과로 넘어가 어색하게 끊기지 않는다.
  static const laps = 3;

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen>
    with TickerProviderStateMixin {
  static final _steps = [
    () => tr('고른 답을 살펴보고 있어요', 'Reading your answers', '選んだ答えを見ています'),
    () => tr('어울리는 다과를 고르고 있어요', 'Choosing a dagwa for you', '似合う茶菓を選んでいます'),
    () => tr('곧 보여 드릴게요', 'Almost ready', 'まもなくお見せします'),
  ];

  Timer? _timer;
  Timer? _stepTimer;
  int _step = 0;

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: TransitionScreen.duration ~/ TransitionScreen.laps,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _timer = Timer(TransitionScreen.duration, widget.onDone);
    final stepLength = TransitionScreen.duration ~/ _steps.length;
    _stepTimer = Timer.periodic(stepLength, (_) {
      if (_step < _steps.length - 1) setState(() => _step++);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _spin.stop();
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_spin.isAnimating) {
      _spin.repeat();
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stepTimer?.cancel();
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandMark(compact: true),
        const SizedBox(height: Space.lg),
        SizedBox(
          width: 350,
          height: 350,
          child: RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) {
                    final value = Curves.easeInOut.transform(_pulse.value);
                    return Container(
                      width: 292 - (8 * value),
                      height: 292 - (8 * value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.celadon.withValues(
                            alpha: 0.18 + (0.08 * (1 - value)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _spin,
                  builder: (context, _) => CustomPaint(
                    size: const Size.square(324),
                    painter: _OrbitPainter(_spin.value),
                  ),
                ),
                GlassSurface(
                  radius: 110,
                  blurBackdrop: true,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _spin,
                        builder: (context, _) => _BouncingDots(_spin.value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          // 앞 문구가 완전히 사라진 뒤 다음 문구가 올라온다. 두 문구가
          // 겹쳐 보이면 급하게 넘기는 인상을 준다.
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: const Interval(0.5, 1, curve: Motion.curve),
            switchOutCurve: const Interval(0.5, 1),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              _steps[_step](),
              key: ValueKey(_step),
              textAlign: TextAlign.center,
              style: Type.section.copyWith(fontSize: 32, height: 1.42),
            ),
          ),
        ),
        const SizedBox(height: Space.sm),
        Text(
          tr('잠시만 기다려 주세요', 'Just a moment, please', '少々お待ちください'),
          textAlign: TextAlign.center,
          style: Type.bodyMuted.copyWith(fontSize: 20),
        ),
      ],
    ),
  );
}

/// 원 둘레를 도는 점 여러 개. 앞선 점일수록 크고 진하다.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = AppColors.accent.withValues(alpha: 0.10),
    );
    const trail = 6;
    for (var i = 0; i < trail; i++) {
      final angle = 2 * math.pi * t - (i * 0.22) - math.pi / 2;
      final strength = 1 - i / trail;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        3 + 4 * strength,
        Paint()..color = AppColors.accent.withValues(alpha: strength),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t;
}

/// 가운데에서 차례로 튀어 오르는 점 세 개.
class _BouncingDots extends StatelessWidget {
  const _BouncingDots(this.t);

  final double t;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0) const SizedBox(width: Space.md),
        Builder(
          builder: (context) {
            final phase = (t - i * 0.15) % 1;
            final lift = math.max(0.0, math.sin(phase * 2 * math.pi));
            return Transform.translate(
              offset: Offset(0, -14 * lift),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    AppColors.champagne,
                    AppColors.accent,
                    0.35 + 0.65 * lift,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ],
  );
}
