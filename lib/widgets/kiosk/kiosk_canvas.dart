import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 디자인 기준 캔버스 크기 — iPad Pro 12.9형 가로.
const kCanvasSize = Size(1366, 1024);

/// 기준 높이를 유지하면서 넓은 iPad에서는 캔버스 폭을 늘려 화면을 채운다.
///
/// 내부 요소의 좌표와 크기는 디자인 값을 유지하므로 화면을 가로로 늘이거나
/// 양옆에 빈 공간을 만들지 않는다.
class KioskCanvas extends StatelessWidget {
  const KioskCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = math.max(
          kCanvasSize.width,
          kCanvasSize.height * constraints.maxWidth / constraints.maxHeight,
        );

        return ColoredBox(
          color: AppColors.surround,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: canvasWidth,
                height: kCanvasSize.height,
                child: ColoredBox(color: AppColors.ground, child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
