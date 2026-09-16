import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';
import 'package:haenggung_dagwa/l10n/lang.dart';
import 'package:haenggung_dagwa/theme/app_theme.dart';

/// 위젯 테스트는 기본적으로 Ahem(모든 글자가 정사각형) 폰트로 그린다.
/// 그대로 재면 폭이 과장되어 측정이 무의미하므로 실제 본문 폰트를 올린다.
Future<void> _loadRealFont() async {
  final loader = FontLoader(kSans)
    ..addFont(rootBundle.load('assets/fonts/PretendardVariable.ttf'));
  await loader.load();
}

/// 결과 화면 우측 타이포 칼럼의 실제 폭.
///
/// 캔버스 1366 − 좌우 여백 88×2 = 1190, 이미지와의 간격 64를 빼고 5:6으로 나눈 값.
const _textColumnWidth = (1366 - 88 * 2 - 64) * 6 / 11;

int _lineCount(String text, TextStyle style, double maxWidth) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  return painter.computeLineMetrics().length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadRealFont);
  tearDown(() => appLang.value = Lang.ko);

  test('한국어·일본어 다과명은 한 줄에 들어간다', () {
    final wrapped = <String>[];
    for (final lang in [Lang.ko, Lang.ja]) {
      appLang.value = lang;
      for (final r in dagwaResults.values) {
        final lines = _lineCount(r.name.t, Type.resultTitle, _textColumnWidth);
        if (lines > 1) wrapped.add('${lang.label} · ${r.name.t} ($lines줄)');
      }
    }
    expect(wrapped, isEmpty, reason: '다과명이 두 줄이 된다:\n${wrapped.join('\n')}');
  });

  test('영어 다과명이 두 줄을 넘지 않는다', () {
    // 영어 이름은 한국어보다 길어 두 줄까지는 허용한다. 세 줄이 되면
    // 68px 제목이 칼럼을 지배해 구성이 무너진다.
    appLang.value = Lang.en;
    final tooLong = <String>[];
    for (final r in dagwaResults.values) {
      final lines = _lineCount(r.name.t, Type.resultTitle, _textColumnWidth);
      if (lines > 2) tooLong.add('${r.name.t} ($lines줄)');
    }
    expect(tooLong, isEmpty, reason: '영어 이름이 너무 길다:\n${tooLong.join('\n')}');
  });

  test('결과 화면 한 줄 리드가 세 줄을 넘지 않는다', () {
    final style = Type.body.copyWith(fontSize: 22, height: 1.5);
    final tooLong = <String>[];
    for (final lang in Lang.values) {
      appLang.value = lang;
      for (final r in dagwaResults.values) {
        final lines = _lineCount(r.title.t, style, _textColumnWidth);
        if (lines > 3) {
          tooLong.add('${lang.label} · ${r.menuName} ($lines줄): ${r.title.t}');
        }
      }
    }
    expect(tooLong, isEmpty, reason: '리드 문구가 너무 길다:\n${tooLong.join('\n')}');
  });
}
