import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/brand_mark.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/glass_surface.dart';

/// 히어로가 오른쪽 여백을 넘어 나가는 정도. 화면에 갇힌 카드가 아니라
/// 지면 밖으로 흐르는 편집물처럼 보이게 한다.
const double _heroBleed = 60;

/// 01 · Attract / Idle — 아무도 쓰지 않을 때 보이는 화면.
///
/// 이 화면에는 버튼을 두지 않는다. 화면 전체가 터치 영역이고, 대신 하단의
/// 맥박 신호가 "여기를 누르면 된다"를 말한다. 버튼과 안내 문구를 함께 두면
/// 어디를 눌러야 하는지 오히려 흐려진다.
class IdleScreen extends StatefulWidget {
  const IdleScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> with TickerProviderStateMixin {
  /// 히어로가 아주 느리게 떠오르내린다.
  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

  /// 터치 신호의 파문. 2~3m 밖에서도 눈에 들어오게 하는 유일한 움직임이다.
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  /// 안내 문구의 숨소리. 파문과 주기를 어긋나게 둬서 기계적으로 보이지 않는다.
  late final _breathe = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    _pulse.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onStart,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(88, 60, 88, 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 우상단은 언어 토글이 차지하므로 브랜드 마크만 둔다.
          const BrandMark(),
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
                      Text(
                        'TASTE OF HWASEONG',
                        style: Type.eyebrow(AppColors.accent, tracking: 3.2),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        tr(
                          '오늘, 나와\n어울리는 다과는?',
                          'Which dagwa\nsuits you today?',
                          '今日のあなたに\n似合う茶菓は？',
                        ),
                        style: Type.hero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(flex: 6, child: _Hero(float: _float)),
              ],
            ),
          ),
          _TapCue(pulse: _pulse, breathe: _breathe),
        ],
      ),
    ),
  );
}

/// 오른쪽 여백을 살짝 넘어가며 느리게 떠오르내리는 다과.
class _Hero extends StatelessWidget {
  const _Hero({required this.float});

  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(_heroBleed, 0),
      child: Center(
        // 세로 크기를 묶어 둔다. 칼럼 높이에 맡기면 카드가 위로 자라
        // 우상단 언어 토글에 붙고, 왼쪽 문구보다 무거워진다.
        child: SizedBox(
          height: 600,
          child: AnimatedBuilder(
            animation: float,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -14 * float.value),
              child: child,
            ),
            child: RepaintBoundary(
              child: DangwaImage(
                assetPath: dagwaResults['수원약과']!.imagePath,
                tone: toneFor('수원약과'),
                aspectRatio: 0.82,
                padding: 0.08,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 하단의 터치 신호 — 파문이 퍼지는 원과 손가락 아이콘, 그리고 안내 문구.
class _TapCue extends StatelessWidget {
  const _TapCue({required this.pulse, required this.breathe});

  final Animation<double> pulse;
  final Animation<double> breathe;

  static const _size = 60.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 밖으로 번져 나가는 파문.
                AnimatedBuilder(
                  animation: pulse,
                  builder: (context, _) => Transform.scale(
                    scale: 1 + 0.55 * pulse.value,
                    child: Opacity(
                      opacity: (0.5 * (1 - pulse.value)).clamp(0.0, 1.0),
                      child: Container(
                        width: _size,
                        height: _size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent),
                        ),
                      ),
                    ),
                  ),
                ),
                GlassSurface(
                  radius: _size / 2,
                  child: const SizedBox(
                    width: _size,
                    height: _size,
                    child: Icon(
                      Icons.touch_app_outlined,
                      color: AppColors.accent,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        AnimatedBuilder(
          animation: breathe,
          builder: (context, child) =>
              Opacity(opacity: 0.55 + 0.45 * breathe.value, child: child),
          child: Text(
            tr('화면 어디든 터치해 시작하기', 'Touch anywhere to begin', '画面のどこでもタッチして開始'),
            style: Type.section.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ],
    );
  }
}
