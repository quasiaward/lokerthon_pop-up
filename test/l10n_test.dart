import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';
import 'package:haenggung_dagwa/data/quiz_questions.dart';
import 'package:haenggung_dagwa/l10n/lang.dart';
import 'package:haenggung_dagwa/theme/app_colors.dart';
import 'package:haenggung_dagwa/widgets/lang_toggle.dart';

/// 한글 음절(가–힣)이 하나라도 들어 있는지.
final _hangul = RegExp(r'[가-힣]');

/// 결과 화면과 상세 시트에 실제로 노출되는 모든 문구.
Iterable<({String where, L10nText text})> _resultTexts() sync* {
  for (final entry in dagwaResults.entries) {
    final k = entry.key;
    final r = entry.value;
    yield (where: '$k.name', text: r.name);
    yield (where: '$k.title', text: r.title);
    yield (where: '$k.description', text: r.description);
    yield (where: '$k.pairing', text: r.pairing);
    yield (where: '$k.pairingDesc', text: r.pairingDesc);
    yield (where: '$k.runnerUpDesc', text: r.runnerUpDesc);
  }
}

Iterable<({String where, L10nText text})> _quizTexts() sync* {
  for (var i = 0; i < quizQuestions.length; i++) {
    final q = quizQuestions[i];
    yield (where: 'Q${i + 1}.before', text: q.before);
    yield (where: 'Q${i + 1}.keyword', text: q.keyword);
    yield (where: 'Q${i + 1}.after', text: q.after);
    yield (where: 'Q${i + 1}.hint', text: q.hint);
    for (final o in q.options) {
      yield (where: 'Q${i + 1}/${o.title}.label', text: o.label);
      yield (where: 'Q${i + 1}/${o.title}.desc', text: o.desc);
    }
  }
}

void main() {
  tearDown(() => appLang.value = Lang.ko);

  testWidgets('언어 토글의 선택 배경이 KO에서 EN으로 이동한다', (tester) async {
    appLang.value = Lang.ko;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: LangToggle())),
      ),
    );

    Color? background(String label) {
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, label),
      );
      return button.style?.backgroundColor?.resolve(<WidgetState>{});
    }

    expect(background('KO'), AppColors.accent);
    expect(background('EN'), Colors.transparent);

    await tester.tap(find.text('EN'));
    await tester.pump();

    expect(appLang.value, Lang.en);
    expect(background('KO'), Colors.transparent);
    expect(background('EN'), AppColors.accent);
  });

  test('세 언어가 모두 채워져 있다', () {
    for (final item in [..._resultTexts(), ..._quizTexts()]) {
      expect(item.text.ko.trim(), isNotEmpty, reason: '${item.where} (ko)');
      expect(item.text.en.trim(), isNotEmpty, reason: '${item.where} (en)');
      expect(item.text.ja.trim(), isNotEmpty, reason: '${item.where} (ja)');
    }
  });

  test('영어 문구에 한글이 섞여 있지 않다', () {
    for (final item in [..._resultTexts(), ..._quizTexts()]) {
      expect(
        _hangul.hasMatch(item.text.en),
        isFalse,
        reason: '${item.where} (en)에 한글이 남아 있다: ${item.text.en}',
      );
    }
  });

  test('일본어 문구에 한글이 섞여 있지 않다', () {
    for (final item in [..._resultTexts(), ..._quizTexts()]) {
      expect(
        _hangul.hasMatch(item.text.ja),
        isFalse,
        reason: '${item.where} (ja)에 한글이 남아 있다: ${item.text.ja}',
      );
    }
  });

  test('영어·일본어가 한국어를 그대로 복사해 두지 않았다', () {
    for (final item in [..._resultTexts(), ..._quizTexts()]) {
      // 고유명사나 기호처럼 같을 수밖에 없는 짧은 문자열은 넘어간다.
      if (item.text.ko.trim().length < 3) continue;
      expect(item.text.en, isNot(item.text.ko), reason: '${item.where} (en)');
      expect(item.text.ja, isNot(item.text.ko), reason: '${item.where} (ja)');
    }
  });

  test('언어를 바꾸면 L10nText가 해당 언어를 돌려준다', () {
    final sample = dagwaResults['흑임자다식']!.name;

    appLang.value = Lang.ko;
    expect(sample.t, sample.ko);
    appLang.value = Lang.en;
    expect(sample.t, sample.en);
    appLang.value = Lang.ja;
    expect(sample.t, sample.ja);
  });

  test('추천 알고리즘의 로직 키는 언어와 무관하게 한국어로 고정된다', () {
    for (final lang in Lang.values) {
      appLang.value = lang;
      for (final q in quizQuestions) {
        for (final o in q.options) {
          expect(
            _hangul.hasMatch(o.title),
            isTrue,
            reason: '$lang에서 선택지 로직 키가 바뀌었다: ${o.title}',
          );
        }
      }
      for (final entry in dagwaResults.entries) {
        expect(entry.value.menuName, entry.key, reason: '$lang');
        expect(
          _hangul.hasMatch(entry.value.runnerUp),
          isTrue,
          reason: '$lang에서 runnerUp 키가 바뀌었다',
        );
      }
    }
  });

  test('모든 언어에 대해 toggle 라벨이 두 글자다', () {
    for (final lang in Lang.values) {
      expect(lang.label.length, 2, reason: '$lang');
    }
  });
}
