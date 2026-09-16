import 'package:flutter/material.dart';

/// 행궁다과의 와인빛을 현대적인 유리 표면 위에 다시 정리한 팔레트.
///
/// 방향: **전통의 앵커는 지키되, 팝업을 찾는 젊은 층에게 세련되게 읽히도록.**
///
/// 그래서 세 가지를 바꿨다.
/// 1. 바탕에서 **노란기를 걷어냈다.** 아이보리·한지 톤은 그대로 두면 오래된
///    인상을 준다. 거의 중성에 가까운 본(bone) 톤으로 옮겨, 따뜻한 다과
///    사진이 더 또렷하게 도드라지게 했다.
/// 2. **금빛을 쓰지 않는다.** 금색은 전통을 가장 직접적으로 지시하는 색이라
///    조금만 써도 화면이 예스러워진다. 대신 **청자(celadon)** 를 보조 색으로
///    두었다. 청자는 우리 것이면서도 현대적인 차분함을 낸다.
/// 3. 먹색 계열에서 **갈색기를 뺐다.** 갈색 글자는 소박해 보이고, 중성 차콜은
///    같은 자리에서 훨씬 단정하다.
class AppColors {
  const AppColors._();

  // ── 바탕 ──────────────────────────────────────────────────────────
  /// 화면 바탕. 순백이 아니되 노랗지 않은 본 톤.
  /// 흰 유리 카드가 떠 보이도록 한 단계 낮춰 뒀다. 바탕과 카드가 같은
  /// 밝기면 멀리서 카드가 눌리는 면으로 읽히지 않는다.
  static const ground = Color(0xFFF2EFEB);
  static const surface = Color(0xFFFFFCF9);
  static const cream = Color(0xFFEAE5DF);
  static const mist = Color(0xFFDDD7D0);
  static const line = Color(0xFFD0C8C0);
  static const lineStrong = Color(0xFF968D86);

  // ── 먹 ────────────────────────────────────────────────────────────
  static const ink = Color(0xFF262220);
  static const charcoal = Color(0xFF46403C);
  static const muted = Color(0xFF6A625D);

  /// 캡션용. 부스에서 서서 읽는 화면이라 ground 위에서 4.5:1을 넘긴다.
  static const faint = Color(0xFF736A64);

  // ── 앵커: 와인 ────────────────────────────────────────────────────
  /// 갈색기를 덜고 붉은기를 살린 와인. 브랜드의 중심.
  static const accent = Color(0xFF873D56);
  static const accentDeep = Color(0xFF532536);
  static const accentSoft = Color(0xFFF5E4E8);

  /// 새 워드마크의 열매색. 넓은 면보다 작은 신호와 빛에 사용한다.
  static const blossom = Color(0xFFE9838D);
  static const blossomSoft = Color(0xFFFBEAEC);

  // ── 보조: 청자 ────────────────────────────────────────────────────
  /// 금빛을 대신하는 차분한 청록. 와인의 열기를 식혀 준다.
  static const celadon = Color(0xFF8D9B69);
  static const celadonSoft = Color(0xFFE9ECE0);

  /// 아주 절제된 금속기. 헤어라인과 작은 표시에만 쓴다.
  static const champagne = Color(0xFFC7B59C);
  static const champagneSoft = Color(0xFFEFE8DF);

  /// 캔버스 바깥 여백.
  static const surround = Color(0xFF171416);

  static const glass = Color(0xC8FFFCF9);
  static const glassStrong = Color(0xF0FFFCF9);
}

class Space {
  const Space._();
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const x3 = 48.0;
  static const x4 = 64.0;
  static const x5 = 80.0;
  static const x6 = 96.0;
  static const x7 = 120.0;
}

class Radii {
  const Radii._();
  static const card = 28.0;
  static const button = 24.0;
  static const asset = 44.0;
  static const sheet = 42.0;
}

class Motion {
  const Motion._();
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 480);
  static const reveal = Duration(milliseconds: 560);
  static const exit = Duration(milliseconds: 150);
  static const curve = Cubic(0.16, 1, 0.3, 1);
  static const emphasized = Cubic(0.22, 1, 0.36, 1);
  static const exitCurve = Cubic(0.4, 0, 1, 1);
}
