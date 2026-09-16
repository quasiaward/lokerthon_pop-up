import 'package:flutter/material.dart';

/// 다과별 대표색.
///
/// 결과 화면의 배경 tint·구분선·타이포 accent를 다과마다 미묘하게 달리하기 위한
/// 값이다. 실제 다과 이미지(`assets/figma/result_*.png`)에서 지배색을 뽑은 뒤,
/// 새 팔레트에 맞게 다듬었다.
///
/// - [soft]는 채도를 크게 낮춰 거의 중성으로 뒀다. 그대로 쓰면 카드 배경이
///   베이지로 깔려 화면이 예스러워진다.
/// - [deep]은 브랜드 와인 쪽으로 절반쯤 섞었다. 다과마다 다르되 한 계열 안에
///   머물러, 갈색이 따로 노는 일이 없다.
/// **다과 이미지 자체의 색은 건드리지 않는다.**
class DagwaTone {
  const DagwaTone({required this.deep, required this.soft});

  /// 타이포 accent, 구분선, eyebrow에 쓰는 깊은 톤.
  final Color deep;

  /// 배경 tint에 쓰는 아주 옅은 같은 계열 톤.
  final Color soft;
}

const _fallbackTone = DagwaTone(
  deep: Color(0xFF7D2742),
  soft: Color(0xFFF1ECEE),
);

DagwaTone toneFor(String menuName) => dagwaTones[menuName] ?? _fallbackTone;

const dagwaTones = <String, DagwaTone>{
  '흑임자다식': DagwaTone(deep: Color(0xFF742530), soft: Color(0xFFF1ECEC)),
  '도라지정과': DagwaTone(deep: Color(0xFF67282D), soft: Color(0xFFF1EDEC)),
  '육포다식': DagwaTone(deep: Color(0xFF743530), soft: Color(0xFFF1EEEC)),
  '콩고물 도라지정과': DagwaTone(deep: Color(0xFF744130), soft: Color(0xFFF1EFEC)),
  '곶감 호두말이': DagwaTone(deep: Color(0xFF743B30), soft: Color(0xFFF1EFEC)),
  '구움 견과 강정': DagwaTone(deep: Color(0xFF743F30), soft: Color(0xFFF1EFEC)),
  '금귤정과': DagwaTone(deep: Color(0xFF743930), soft: Color(0xFFF1EEEC)),
  '깨강정': DagwaTone(deep: Color(0xFF743F30), soft: Color(0xFFF1EFEC)),
  '영양찰떡': DagwaTone(deep: Color(0xFF743B30), soft: Color(0xFFF1EFEC)),
  '양갱': DagwaTone(deep: Color(0xFF67262D), soft: Color(0xFFF1EDEC)),
  '매작과': DagwaTone(deep: Color(0xFF742433), soft: Color(0xFFF1ECED)),
  '수원약과': DagwaTone(deep: Color(0xFF743530), soft: Color(0xFFF1EEEC)),
};
