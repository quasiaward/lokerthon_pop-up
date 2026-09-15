import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 한글 본문은 Pretendard sans. 영문 accent에만 Fraunces italic을 보조로 쓴다.
const kSans = 'Pretendard';
const kSerifAccent = 'Fraunces';

/// Pretendard가 커버하지 못하는 글자를 이어받는 순서.
///
/// 가나·한자는 일본어 시스템 폰트(Hiragino)가 먼저 받도록 한글 폰트 앞에 둔다.
/// 같은 한자라도 일본어와 한국어의 자형이 달라서, 순서를 바꾸면 일본어 화면에
/// 한국어용 자형이 섞여 나온다.
const kSansFallback = <String>[
  'Hiragino Sans',
  'Hiragino Kaku Gothic ProN',
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
  static TextStyle get hero => _s(72, weight: FontWeight.w700, height: 1.18);

  /// 결과 화면 다과명. 68px.
  static TextStyle get resultTitle =>
      _s(56, weight: FontWeight.w700, height: 1.15);

  /// 질문. 50px.
  static TextStyle get question =>
      _s(46, weight: FontWeight.w700, height: 1.28);

  /// Intro 헤드라인. 56px.
  static TextStyle get headline => _s(60, weight: FontWeight.w700, height: 1.2);

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
  /// 영문 대문자에는 넓은 자간이 어울리지만, 한글·일본어에 그대로 쓰면 글자가
  /// 흩어져 보인다. [latin]으로 갈라 CJK는 자간을 거의 주지 않는다.
  ///
  /// 번역되는 문구라면 `latin: isEn`을 넘겨야 한다. 고정 영문 문구
  /// (`THE STORY` 같은)는 기본값 그대로 두면 된다.
  ///
  /// 자간을 넓히고 싶을 때는 [tracking]을 쓴다. `copyWith(letterSpacing:)`로
  /// 덮어쓰면 [latin] 분기가 무력화되어 CJK에서도 자간이 벌어진다.
  static TextStyle eyebrow(
    Color color, {
    bool latin = true,
    double size = 15,
    double? tracking,
  }) => TextStyle(
    fontFamily: _sans,
    fontFamilyFallback: kSansFallback,
    fontSize: size,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: latin ? (tracking ?? size * 0.04) : size * -0.01,
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
