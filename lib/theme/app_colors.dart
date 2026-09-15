import 'package:flutter/material.dart';

/// Clear, solid surfaces and a single action color across the tasting flow.
class AppColors {
  const AppColors._();
  static const ground = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const cream = Color(0xFFF2F4F6);
  static const mist = Color(0xFFE5E8EB);
  static const line = Color(0xFFE5E8EB);
  static const lineStrong = Color(0xFFB0B8C1);
  static const ink = Color(0xFF191F28);
  static const charcoal = Color(0xFF333D4B);
  static const muted = Color(0xFF6B7684);
  static const faint = Color(0xFF8B95A1);
  static const accent = Color(0xFF3182F6);
  static const accentSoft = Color(0xFFEAF3FF);
  static const surround = ground;
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
  static const card = 24.0;
  static const button = 20.0;
  static const asset = 40.0;
  static const sheet = 36.0;
}

class Motion {
  const Motion._();
  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 320);
  static const reveal = Duration(milliseconds: 400);
  static const exit = Duration(milliseconds: 120);
  static const curve = Curves.easeOutCubic;
}
