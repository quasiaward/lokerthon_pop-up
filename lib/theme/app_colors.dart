import 'package:flutter/material.dart';

/// 키오스크 디자인 토큰 — Foundations.
///
/// "한국 전통 다과를 현대적인 럭셔리 브랜드 경험으로 재해석한 디지털 테이스팅
/// 인터페이스." 따뜻한 아이보리 바탕, 짙은 먹색 텍스트, 단 하나의 버건디 accent.
/// 깊이는 그림자가 아니라 톤·여백·스케일로 만든다.
class AppColors {
  const AppColors._();

  // ── Ground & surface ──────────────────────────────────────────────
  /// 화면 바탕. 순백을 쓰지 않고 따뜻한 아이보리로 소재감을 낸다.
  static const ground = Color(0xFFF4F0E8);
  static const cream = Color(0xFFEFE9DD);
  static const mist = Color(0xFFE7E0D1);

  /// 경계선은 면이 아니라 실선 한 올로만 존재한다.
  static const line = Color(0xFFDDD4C2);
  static const lineStrong = Color(0xFFCABFA7);

  // ── Ink ───────────────────────────────────────────────────────────
  static const ink = Color(0xFF1C1917);
  static const charcoal = Color(0xFF2F2A26);

  /// ground 위에서 WCAG AA를 만족하는 보조 텍스트 색.
  static const muted = Color(0xFF6B6357);
  static const faint = Color(0xFF8A8172);

  // ── Accent ────────────────────────────────────────────────────────
  /// 한 번에 하나만 쓰는 주 accent. 전통 오방색이 아니라 저채도 딥 버건디.
  static const accent = Color(0xFF6D1F2B);
  static const accentSoft = Color(0xFFEFE3DD);

  /// 키오스크 바깥 여백(기기 화면보다 캔버스가 작을 때).
  static const surround = Color(0xFF211D1A);
}

/// 여백 스케일. 임의 값 대신 이 안에서만 고른다.
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

/// 모서리 반경. pill 느낌이 나지 않도록 상한을 둔다.
class Radii {
  const Radii._();
  static const card = 22.0;
  static const button = 18.0;
  static const asset = 28.0;
  static const sheet = 36.0;
}

/// 모션. 조용하고 느긋하되 사용성을 방해하지 않을 만큼 빠르게.
class Motion {
  const Motion._();
  static const fast = Duration(milliseconds: 260);
  static const base = Duration(milliseconds: 340);
  static const slow = Duration(milliseconds: 500);
  static const reveal = Duration(milliseconds: 900);

  /// ease-out 계열. 화면 전환의 기본 곡선.
  static const curve = Cubic(0.22, 0.61, 0.36, 1);
}
