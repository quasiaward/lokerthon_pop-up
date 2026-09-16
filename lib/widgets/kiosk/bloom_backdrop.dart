import 'package:flutter/material.dart';

/// 화면 모서리에서 밖으로 흘러나가는 수채화 장식.
///
/// 원래 웹사이트 배경에 쓰이던 꽃·나뭇가지 그림을 되살린 것이다. 원본은
/// 분홍·노랑이라 그대로 쓰면 걷어냈던 누런 기운이 돌아오므로, 수채화 질감과
/// 무채색 가지는 남기고 색만 브랜드 팔레트(와인·청자)로 옮겨 구웠다.
///
/// 배치 원칙은 원본 시안과 같다. 화면 안에 얌전히 들어오지 않고 **모서리
/// 밖으로 잘려 나가야** 지면이 이어지는 느낌이 난다.
class BloomBackdrop extends StatelessWidget {
  const BloomBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 우상단 — 청자빛 꽃
          Positioned(
            right: -168,
            top: -186,
            child: Image.asset(
              'assets/figma/deco/deco_bloom_celadon.png',
              width: 620,
              cacheWidth: 1240,
              // 청록은 같은 농도에서도 분홍보다 눈에 띈다. 좌하단과 무게를
              // 맞추려고 한 단계 눌러 둔다. Image의 opacity는 saveLayer 없이
              // 그리기 단계에서 처리돼 Opacity 위젯보다 싸다.
              opacity: const AlwaysStoppedAnimation(0.62),
              excludeFromSemantics: true,
            ),
          ),
          // 좌하단 — 와인빛 꽃과 가지
          Positioned(
            left: -150,
            bottom: -128,
            child: Image.asset(
              'assets/figma/deco/deco_bloom_wine.png',
              width: 560,
              cacheWidth: 1120,
              opacity: const AlwaysStoppedAnimation(0.9),
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }
}
