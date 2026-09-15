import 'package:flutter/material.dart';

/// 행궁다과의 버건디와 금빛을 현대적인 유리 표면에 맞게 정리한 팔레트.
class AppColors {
  const AppColors._();
  static const ground = Color(0xFFF5F0E8);
  static const surface = Color(0xFFFFFCF7);
  static const cream = Color(0xFFEDE4D8);
  static const mist = Color(0xFFE3D8CB);
  static const line = Color(0xFFD8CABC);
  static const lineStrong = Color(0xFFB8A493);
  static const ink = Color(0xFF241B1B);
  static const charcoal = Color(0xFF443838);
  static const muted = Color(0xFF746663);
  static const faint = Color(0xFF988A84);
  static const accent = Color(0xFF773243);
  static const accentDeep = Color(0xFF55202D);
  static const accentSoft = Color(0xFFF0DFE1);
  static const gold = Color(0xFFD5B36C);
  static const goldSoft = Color(0xFFF4E7C7);
  static const moss = Color(0xFF5D664F);
  static const surround = Color(0xFF211719);
  static const glass = Color(0xB8FFFCF7);
  static const glassStrong = Color(0xE8FFFCF7);
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
