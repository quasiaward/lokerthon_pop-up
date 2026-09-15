import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 디자인 기준 캔버스 크기 — iPad Pro 12.9형 가로.
const kCanvasSize = Size(1366, 1024);

/// 1366×1024 고정 캔버스를 화면에 꽉 차게 맞춰 그린다.
///
/// 대상 기기에서는 배율이 정확히 1이라 손실이 없고, 비율이 다른 태블릿에서도
/// 구조가 깨지지 않는다. 모든 좌표와 치수를 디자인 값 그대로 쓸 수 있게
/// 해 주는 것이 이 위젯의 목적이다.
class KioskCanvas extends StatelessWidget {
  const KioskCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surround,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: kCanvasSize.width,
            height: kCanvasSize.height,
            child: ColoredBox(color: AppColors.ground, child: child),
          ),
        ),
      ),
    );
  }
}
