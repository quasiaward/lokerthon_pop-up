import 'package:flutter/material.dart';

/// 홈페이지의 다과 추천 화면과 같은 수채화 배경 장식.
///
/// 첨부된 투명 PNG에는 최종 회전 각도가 이미 포함되어 있다. 1409×1024 웹
/// 시안을 1366×1024 iPad 캔버스에 맞추면서, 수채화의 불투명 영역이 놓이는
/// 좌표는 그대로 유지하고 PNG 원본의 색과 투명도를 그대로 표시한다.
class BloomBackdrop extends StatelessWidget {
  const BloomBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 우상단 — 노란 수채화의 실제 색 영역은 PNG 내부 x≈260부터 시작한다.
          // 오른쪽을 50px 넘기면 웹 시안과 같은 x≈993 지점부터 보인다.
          Positioned(
            right: -50,
            top: 0,
            child: Image.asset(
              'assets/figma/deco/deco_watercolor_yellow.png',
              width: 683,
              cacheWidth: 683,
              excludeFromSemantics: true,
            ),
          ),
          // 좌하단 — PNG의 832×513 투명 캔버스를 좌하단에 그대로 맞추면
          // 꽃은 아래로, 붓 자국은 안쪽으로 흐르는 원본 구도가 유지된다.
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              'assets/figma/deco/deco_watercolor_pink_branch.png',
              width: 832,
              cacheWidth: 832,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }
}
