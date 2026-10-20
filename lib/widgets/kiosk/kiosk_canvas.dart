import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 디자인 기준 캔버스 크기 — iPad Pro 12.9형 가로.
const kCanvasSize = Size(1366, 1024);

/// 디자인 최소 크기를 유지하고 가용 화면 비율에 맞춰 캔버스를 확장한다.
///
/// 홈 인디케이터 등 시스템 영역을 먼저 제외한 뒤 균일 배율로 그린다.
/// 폭이 넓으면 가로를, 높이가 길면 세로를 늘려 콘텐츠를 자르지 않고 채운다.
class KioskCanvas extends StatelessWidget {
  const KioskCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ground,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }
            final aspectRatio = constraints.maxWidth / constraints.maxHeight;
            final canvasWidth = math.max(
              kCanvasSize.width,
              kCanvasSize.height * aspectRatio,
            );
            final canvasHeight = math.max(
              kCanvasSize.height,
              kCanvasSize.width / aspectRatio,
            );

            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: ColoredBox(color: AppColors.ground, child: child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
