import 'package:flutter/material.dart';

import '../../data/dagwa_tones.dart';
import '../../theme/app_colors.dart';

/// 다과 이미지 컨테이너.
///
/// 이미지는 기존 브랜드 자산을 그대로 쓴다. 이 위젯이 하는 일은 이미지가
/// 가장 아름답게 보이도록 바탕을 깔아 주는 것뿐이다. 이미지 자체의 색은
/// 건드리지 않는다.
class DangwaImage extends StatelessWidget {
  const DangwaImage({
    super.key,
    required this.assetPath,
    required this.tone,
    this.aspectRatio = 1,
    this.padding = 0.12,
  });

  final String assetPath;
  final DagwaTone tone;
  final double aspectRatio;

  /// 이미지 주변 여백 비율. 작품처럼 보이도록 충분히 둔다.
  final double padding;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, box) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.asset),
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.5),
              radius: 1.2,
              colors: [tone.soft, AppColors.cream],
            ),
            border: Border.all(color: AppColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.all(box.maxWidth * padding),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              // 유리 위를 스치는 아주 옅은 반사.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.42),
                          Colors.white.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.24, 0.46],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
