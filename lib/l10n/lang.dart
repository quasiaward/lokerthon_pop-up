import 'package:flutter/material.dart';

enum Lang { ko, en }

/// 사이트 전역 언어 상태. main.dart의 ValueListenableBuilder가 이 값을 듣고
/// 전체 트리를 다시 그리므로, [tr]은 context 없이도 현재 언어를 따른다.
final ValueNotifier<Lang> appLang = ValueNotifier<Lang>(Lang.ko);

void toggleLang() {
  appLang.value = appLang.value == Lang.ko ? Lang.en : Lang.ko;
}

bool get isEn => appLang.value == Lang.en;

/// 현재 언어에 맞는 문자열을 고른다. 표시용 텍스트에만 사용하고,
/// 로직 키(맵 키·switch case)에는 절대 쓰지 않는다.
String tr(String ko, String en) => appLang.value == Lang.en ? en : ko;

Locale get currentLocale =>
    appLang.value == Lang.en ? const Locale('en', 'US') : const Locale('ko', 'KR');
