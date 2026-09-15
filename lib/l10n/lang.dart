import 'package:flutter/material.dart';

enum Lang {
  ko('KO', Locale('ko', 'KR')),
  en('EN', Locale('en', 'US')),
  ja('JA', Locale('ja', 'JP'));

  const Lang(this.label, this.locale);

  /// 토글 버튼에 찍히는 두 글자.
  final String label;
  final Locale locale;
}

/// 앱 전역 언어 상태. main.dart의 ValueListenableBuilder가 이 값을 듣고
/// 전체 트리를 다시 그리므로, [tr]은 context 없이도 현재 언어를 따른다.
final ValueNotifier<Lang> appLang = ValueNotifier<Lang>(Lang.ko);

bool get isEn => appLang.value == Lang.en;
bool get isJa => appLang.value == Lang.ja;

/// 한글이 아닌 언어에서는 문장이 길어져 줄바꿈과 자간을 다르게 잡아야 한다.
bool get isLatin => appLang.value == Lang.en;

/// 현재 언어에 맞는 문자열을 고른다.
///
/// 표시용 텍스트에만 쓴다. 로직 키(맵 키·switch case·추천 알고리즘의 답변 키)에는
/// 절대 쓰지 않는다. 일본어가 아직 준비되지 않은 UI 문구는 한국어를 안전한
/// fallback으로 사용해 기존 화면을 깨뜨리지 않는다.
String tr(String ko, String en, [String? ja]) => switch (appLang.value) {
  Lang.ko => ko,
  Lang.en => en,
  Lang.ja => ja ?? ko,
};

/// 데이터 파일에 그대로 넣어 두는 다국어 문자열.
///
/// 로직 키와 표시 문구를 분리하기 위한 장치다. 예를 들어 다과의 `menuName`은
/// 한국어 그대로 맵 키로 쓰이고, 화면에 보이는 이름은 [L10nText]가 따로 갖는다.
class L10nText {
  const L10nText(this.ko, this.en, this.ja);

  final String ko;
  final String en;
  final String ja;

  /// 현재 언어의 문자열.
  String get t => switch (appLang.value) {
    Lang.ko => ko,
    Lang.en => en,
    Lang.ja => ja,
  };

  @override
  String toString() => t;
}

Locale get currentLocale => appLang.value.locale;
