import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 한글 본문은 Pretendard sans. 영문 accent에만 Fraunces italic을 보조로 쓴다.
const kSans = 'Pretendard';
const kSerifAccent = 'Fraunces';

const kSansFallback = <String>[
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'sans-serif',
];

ThemeData buildAppTheme() {
  const textTheme = TextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.ground,
    fontFamily: kSans,
    fontFamilyFallback: kSansFallback,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      surface: AppColors.ground,
      brightness: Brightness.light,
    ),
    textTheme: textTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
  );
}

/// 타이포 스케일. iPad Pro 12.9의 넓은 화면을 전제로 일반 웹보다 크고
/// 자신감 있게 쓴다. Light weight는 쓰지 않는다.
class Type {
  const Type._();

  static const _sans = kSans;

  static TextStyle _s(
    double size, {
    FontWeight weight = FontWeight.w500,
    double height = 1.2,
    double tracking = -0.02,
    Color color = AppColors.ink,
  }) => TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: kSansFallback,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: size * tracking,
    color: color,
  );

  /// Idle 화면 히어로. 84px.
  static TextStyle get hero => _s(84, height: 1.02);

  /// 결과 화면 다과명. 68px.
  static TextStyle get resultTitle => _s(68, height: 1.0);

  /// 질문. 50px.
  static TextStyle get question => _s(50, height: 1.14);

  /// Intro 헤드라인. 56px.
  static TextStyle get headline => _s(56, height: 1.15);

  /// 섹션 제목. 32px.
  static TextStyle get section => _s(32, weight: FontWeight.w600, height: 1.25);

  /// 본문. 22px.
  static TextStyle get body => _s(
    22,
    weight: FontWeight.w400,
    height: 1.6,
    tracking: -0.01,
    color: AppColors.charcoal,
  );

  /// 보조 본문. 21px muted.
  static TextStyle get bodyMuted => _s(
    21,
    weight: FontWeight.w400,
    height: 1.5,
    tracking: -0.01,
    color: AppColors.muted,
  );

  /// CTA 라벨. 22px.
  static TextStyle get cta =>
      _s(22, weight: FontWeight.w700, height: 1.0, tracking: -0.015);

  /// 캡션. 16px.
  static TextStyle get caption => _s(
    16,
    weight: FontWeight.w500,
    height: 1.4,
    tracking: -0.005,
    color: AppColors.faint,
  );

  /// 눈썹 라벨.
  ///
  /// 영문 대문자에는 넓은 자간이 어울리지만 한글에 그대로 쓰면 글자가 흩어져
  /// 보인다. [latin]으로 구분해 한글은 자간을 거의 주지 않는다.
  static TextStyle eyebrow(
    Color color, {
    bool latin = true,
    double size = 15,
  }) => TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: kSansFallback,
    fontSize: size,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: size * (latin ? 0.24 : 0.01),
    color: color,
  );

  /// 영문 serif accent. 장식적으로만, 짧게 쓴다.
  static TextStyle serifAccent(double size, Color color) => TextStyle(
    fontFamily: kSerifAccent,
    fontFamilyFallback: const ['Georgia', 'serif'],
    fontSize: size,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: color,
  );
}
