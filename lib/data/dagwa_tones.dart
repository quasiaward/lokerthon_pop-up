import 'package:flutter/material.dart';

/// 다과별 대표색.
///
/// 결과 화면의 배경 tint·구분선·타이포 accent를 다과마다 미묘하게 달리하기 위한
/// 값이다. 실제 다과 이미지(`assets/figma/result_*.png`)에서 지배색을 뽑은 뒤,
/// quiet-luxury 팔레트에 맞게 명도와 채도를 낮춰 재해석했다.
/// **다과 이미지 자체의 색은 건드리지 않는다.**
class DagwaTone {
  const DagwaTone({required this.deep, required this.soft});

  /// 타이포 accent, 구분선, eyebrow에 쓰는 깊은 톤.
  final Color deep;

  /// 배경 tint에 쓰는 아주 옅은 같은 계열 톤.
  final Color soft;
}

const _fallbackTone = DagwaTone(
  deep: Color(0xFF6D1F2B),
  soft: Color(0xFFEFE3DD),
);

DagwaTone toneFor(String menuName) => dagwaTones[menuName] ?? _fallbackTone;

const dagwaTones = <String, DagwaTone>{
  '흑임자다식': DagwaTone(deep: Color(0xFF782321), soft: Color(0xFFEDDEDE)),
  '도라지정과': DagwaTone(deep: Color(0xFF512315), soft: Color(0xFFEDE1DE)),
  '육포다식': DagwaTone(deep: Color(0xFF734526), soft: Color(0xFFEDE4DE)),
  '콩고물 도라지정과': DagwaTone(deep: Color(0xFF7A5F1F), soft: Color(0xFFEDE9DE)),
  '곶감 호두말이': DagwaTone(deep: Color(0xFF7A511F), soft: Color(0xFFEDE6DE)),
  '구움 견과 강정': DagwaTone(deep: Color(0xFF7A5B1F), soft: Color(0xFFEDE8DE)),
  '금귤정과': DagwaTone(deep: Color(0xFF7A4E1F), soft: Color(0xFFEDE6DE)),
  '깨강정': DagwaTone(deep: Color(0xFF7A5A1F), soft: Color(0xFFEDE8DE)),
  '영양찰떡': DagwaTone(deep: Color(0xFF7A511F), soft: Color(0xFFEDE6DE)),
  '양갱': DagwaTone(deep: Color(0xFF4F2117), soft: Color(0xFFEDE1DE)),
  '매작과': DagwaTone(deep: Color(0xFF7A1F24), soft: Color(0xFFEDDEDF)),
  '수원약과': DagwaTone(deep: Color(0xFF7A431F), soft: Color(0xFFEDE4DE)),
};
