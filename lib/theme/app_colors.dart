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
  static const ground = Color(0xFFEEEDE9);
  static const surface = Color(0xFFFBFAF8);
  static const cream = Color(0xFFE9E7E2);
  static const mist = Color(0xFFDDDAD4);
  static const line = Color(0xFFD4D0CA);
  static const lineStrong = Color(0xFFA9A49D);

  // ── 먹 ────────────────────────────────────────────────────────────
  static const ink = Color(0xFF1B1A19);
  static const charcoal = Color(0xFF383634);
  static const muted = Color(0xFF6B6763);

  /// 캡션용. 부스에서 서서 읽는 화면이라 ground 위에서 4.5:1을 넘긴다.
  static const faint = Color(0xFF706C67);

  // ── 앵커: 와인 ────────────────────────────────────────────────────
  /// 갈색기를 덜고 붉은기를 살린 와인. 브랜드의 중심.
  static const accent = Color(0xFF7D2742);
  static const accentDeep = Color(0xFF4E162A);
  static const accentSoft = Color(0xFFF3E5E8);

  // ── 보조: 청자 ────────────────────────────────────────────────────
  /// 금빛을 대신하는 차분한 청록. 와인의 열기를 식혀 준다.
  static const celadon = Color(0xFF7E9A90);
  static const celadonSoft = Color(0xFFE7EDEA);

  /// 아주 절제된 금속기. 헤어라인과 작은 표시에만 쓴다.
  static const champagne = Color(0xFFC3B49B);
  static const champagneSoft = Color(0xFFEDE8DF);

  /// 캔버스 바깥 여백.
  static const surround = Color(0xFF151518);

  static const glass = Color(0xB8FBFAF8);
  static const glassStrong = Color(0xE8FBFAF8);
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
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const reveal = Duration(milliseconds: 520);
  static const exit = Duration(milliseconds: 140);
  static const curve = Curves.easeOutQuart;
}
