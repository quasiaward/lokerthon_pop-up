import 'package:flutter/material.dart';

/// 평소에는 세로 가운데를 유지하고, 확대된 글자가 공간을 넘으면 스크롤한다.
/// 이미지·상단 조작·하단 안내의 영역을 침범하지 않고 문구와 버튼을 읽을 수 있다.
class KioskReadingPanel extends StatelessWidget {
  const KioskReadingPanel({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      primary: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    ),
  );
}
