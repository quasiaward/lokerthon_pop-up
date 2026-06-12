import 'package:flutter/material.dart';

/// Figma 디자인에서 추출한 수채화 장식 조각.
/// 좌표는 디자인 기준(홈 1440px, 서브 페이지 1409px) 픽셀이며,
/// [decoScaleOf]로 구한 배율을 곱해 Positioned로 배치한다.
const decoBlossomPink = 'assets/figma/deco/deco_blossom_pink.png'; // 542x418
const decoBlossomYellow = 'assets/figma/deco/deco_blossom_yellow.png'; // 463x464
const decoBlossomYellowPage = 'assets/figma/deco/deco_blossom_yellow_page.png'; // 582x467
const decoCluster = 'assets/figma/deco/deco_cluster.png'; // 706x484, 체험·케이터링 페이지용 진한 버전
const decoClusterSoft = 'assets/figma/deco/deco_cluster_soft.png'; // 535x484, 홈 섹션용 연한 버전
const decoQuizPink = 'assets/figma/deco/deco_quiz_pink.png'; // 525x393
const decoQuizBlob = 'assets/figma/deco/deco_quiz_blob.png'; // 422x528
const decoCardPink = 'assets/figma/deco/deco_card_pink.png'; // 223x155
const decoCardGreen = 'assets/figma/deco/deco_card_green.png'; // 223x155
const decoCardYellow = 'assets/figma/deco/deco_card_yellow.png'; // 223x155

/// 디자인 폭 대비 현재 화면 폭의 장식 배율.
double decoScaleOf(BuildContext context, {double designWidth = 1440}) {
  final width = MediaQuery.sizeOf(context).width;
  return (width / designWidth).clamp(0.55, 1.0);
}

/// 포인터를 막지 않는 장식 이미지. 불투명도는 에셋에 이미 반영되어 있다.
class WatercolorDeco extends StatelessWidget {
  const WatercolorDeco(this.asset, {super.key, required this.width});

  final String asset;
  final double width;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Image.asset(
        asset,
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
