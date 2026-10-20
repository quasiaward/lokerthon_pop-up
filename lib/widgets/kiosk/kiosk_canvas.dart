import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 디자인 기준 캔버스 크기 — iPad Pro 12.9형 가로.
const kCanvasSize = Size(1366, 1024);

/// 디자인 최소 크기를 유지하고 가용 화면 비율에 맞춰 캔버스를 확장한다.
///
/// 배경은 화면 끝까지 그리고 조작 요소에만 시스템 안전 영역을 적용한다.
/// 폭이 넓으면 가로를, 높이가 길면 세로를 늘려 콘텐츠를 자르지 않고 채운다.
class KioskCanvas extends StatelessWidget {
  const KioskCanvas({super.key, required this.child, this.background});

  final Widget child;

  /// 안전 영역 뒤까지 이어지는 장식. [child]와 같은 디자인 좌표를 쓴다.
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (background != null)
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      _fitCanvas(constraints, background!),
                ),
              ),
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => _fitCanvas(constraints, child),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fitCanvas(BoxConstraints constraints, Widget content) {
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

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: canvasWidth,
          height: canvasHeight,
          child: content,
        ),
      ),
    );
  }
}
