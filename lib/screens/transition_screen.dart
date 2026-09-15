import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// 추천 결과 공개 직전의 연출.
///
/// "시스템 처리 중"이 아니라 기대를 만드는 장면이다. spinner와 progress bar는
/// 쓰지 않는다. 추천된 다과의 실루엣이 천천히 떠오르며 결과를 예고한다.
class TransitionScreen extends StatefulWidget {
  const TransitionScreen({
    super.key,
    required this.menuName,
    required this.onDone,
  });

  final String menuName;
  final VoidCallback onDone;

  /// 기대감을 만드는 데 필요한 최소 시간.
  static const duration = Duration(milliseconds: 2200);

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
    Future.delayed(TransitionScreen.duration, () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tone = toneFor(widget.menuName);
    final result = dagwaResults[widget.menuName];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _shown ? 1 : 0.94,
            duration: const Duration(milliseconds: 1400),
            curve: Motion.curve,
            child: AnimatedOpacity(
              opacity: _shown ? 1 : 0,
              duration: const Duration(milliseconds: 1400),
              child: SizedBox(
                width: 300,
                height: 300,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [tone.soft, AppColors.cream],
                    ),
                  ),
                  child: result == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.all(54),
                          // 실루엣만 보이도록 낮은 불투명도로 얹는다.
                          child: Opacity(
                            opacity: 0.55,
                            child: Image.asset(
                              result.imagePath,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.x3),
          AnimatedSlide(
            offset: _shown ? Offset.zero : const Offset(0, 0.3),
            duration: const Duration(milliseconds: 900),
            curve: Motion.curve,
            child: AnimatedOpacity(
              opacity: _shown ? 1 : 0,
              duration: const Duration(milliseconds: 900),
              child: Text(
                tr(
                  '당신의 취향을 담아\n다과를 고르고 있어요.',
                  'Choosing a dagwa\nthat matches your taste.',
                ),
                textAlign: TextAlign.center,
                style: Type.section.copyWith(fontSize: 30, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
