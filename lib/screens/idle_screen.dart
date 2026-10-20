import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../data/dangwa_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/brand_mark.dart';
import '../widgets/kiosk/tap_cue.dart';
import '../widgets/kiosk/kiosk_reading_panel.dart';
import '../widgets/kiosk/rotating_dangwa_image.dart';

/// 01 · Attract / Idle — 아무도 쓰지 않을 때 보이는 화면.
///
/// 이 화면에는 버튼을 두지 않는다. 화면 전체가 터치 영역이고, 대신 하단의
/// 맥박 신호가 "여기를 누르면 된다"를 말한다. 버튼과 안내 문구를 함께 두면
/// 어디를 눌러야 하는지 오히려 흐려진다.
class IdleScreen extends StatefulWidget {
  const IdleScreen({
    super.key,
    required this.onStart,
    this.onAdmin,
    this.availableMenus = activeDagwaMenus,
  });

  final VoidCallback onStart;
  final VoidCallback? onAdmin;
  final List<String> availableMenus;

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> with TickerProviderStateMixin {
  /// 히어로가 아주 느리게 떠오르내린다.
  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _float.stop();
      _float.value = 0;
    } else if (!_float.isAnimating) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    excludeSemantics: true,
    onTap: widget.onStart,
    label: tr(
      '화면 어디든 터치해 다과 추천 시작하기',
      'Touch anywhere to start your dagwa recommendation',
      '画面のどこでもタッチして茶菓のおすすめを始める',
    ),
    child: GestureDetector(
      excludeFromSemantics: true,
      onTap: widget.onStart,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(88, 60, 88, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 우상단은 언어 토글이 차지하므로 브랜드 마크만 둔다.
            GestureDetector(
              key: const ValueKey('admin-entry'),
              behavior: HitTestBehavior.opaque,
              onLongPress: widget.onAdmin,
              child: const BrandMark(),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: KioskReadingPanel(
                      children: [
                        Text(
                          'TASTE OF HWASEONG',
                          style: Type.eyebrow(AppColors.accent, tracking: 3.2),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          tr(
                            '오늘, 나에게\n어울리는 다과는?',
                            'Which dagwa\nsuits you today?',
                            '今日のあなたに\n似合う茶菓は？',
                          ),
                          style: Type.hero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 70),
                  Expanded(
                    flex: 5,
                    child: _Hero(
                      float: _float,
                      availableMenus: widget.availableMenus,
                    ),
                  ),
                ],
              ),
            ),
            // const로 두면 안 된다. 언어가 바뀌어 화면이 다시 그려져도
            // 같은 const 인스턴스라 Flutter가 이 가지를 건너뛰고,
            // 안내 문구만 이전 언어로 남는다.
            Align(alignment: Alignment.bottomCenter, child: TapCue()),
          ],
        ),
      ),
    ),
  );
}

/// 오른쪽 여백을 살짝 넘어가며 느리게 떠오르내리는 다과.
class _Hero extends StatelessWidget {
  const _Hero({required this.float, required this.availableMenus});

  final Animation<double> float;
  final List<String> availableMenus;

  @override
  Widget build(BuildContext context) {
    return Center(
      // 오른쪽 칼럼의 정중앙에 카드를 둔다.
      child: AnimatedBuilder(
        animation: float,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -12 * float.value),
          child: child,
        ),
        child: RepaintBoundary(
          // 다음 화면과 같은 크기·비율·여백으로 둔다. 세로형 카드에 높이를
          // 따로 박아 두면 전환할 때 카드가 한 번 튀어 보인다.
          child: RotatingDangwaImage(
            initialIndex: 11,
            padding: 0.10,
            menus: availableMenus,
          ),
        ),
      ),
    );
  }
}
