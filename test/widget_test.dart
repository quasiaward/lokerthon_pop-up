import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/data/dagwa_results.dart';
import 'package:haenggung_dagwa/services/local_recommendation_engine.dart';
import 'package:haenggung_dagwa/services/recommendation_engine.dart';
import 'package:haenggung_dagwa/services/recommendation_service.dart';

/// 각 질문의 선택지(로직 키). 위젯의 _QuizOption.title과 같아야 한다.
const _quizOptions = [
  ['매화 분홍', '소나무 청록', '유자 노랑', '먹색'],
  ['맑고 활기참', '흐리고 지침', '잔잔하고 평온', '설레고 두근거려요'],
  ['소중한 사람', '혼자', '가족', '친구'],
  ['부드러운', '바삭한', '쫀득한', '촉촉한'],
  ['봄', '여름', '가을', '겨울'],
  ['둥근 모양', '물결 모양', '직선 모양', '별·꽃 모양'],
];

Iterable<List<String>> _allAnswerCombinations() sync* {
  for (final a0 in _quizOptions[0]) {
    for (final a1 in _quizOptions[1]) {
      for (final a2 in _quizOptions[2]) {
        for (final a3 in _quizOptions[3]) {
          for (final a4 in _quizOptions[4]) {
            for (final a5 in _quizOptions[5]) {
              yield [a0, a1, a2, a3, a4, a5];
            }
          }
        }
      }
    }
  }
}

void main() {
  test('결과 데이터가 추천 가능한 12개 메뉴를 모두 담는다', () {
    expect(dagwaResults.keys, containsAll(dagwaMenus));
    for (final menu in dagwaMenus) {
      final result = dagwaResults[menu]!;
      expect(result.menuName, menu);
      expect(result.imagePath, isNotEmpty);
    }
  });

  test('모든 답변 조합이 결과 카드가 있는 메뉴를 돌려준다', () {
    for (final answers in _allAnswerCombinations()) {
      final menu = LocalRecommendationEngine.pick(answers);
      expect(
        dagwaResults.containsKey(menu),
        isTrue,
        reason: '$answers → $menu (결과 카드 없음)',
      );
    }
  });

  test('12개 메뉴가 모두 한 번 이상 추천된다', () {
    final seen = <String>{};
    for (final answers in _allAnswerCombinations()) {
      seen.add(LocalRecommendationEngine.pick(answers));
    }
    expect(seen, hasLength(dagwaMenus.length));
  });

  test('한 메뉴가 전체 조합의 20%를 넘게 차지하지 않는다', () {
    final counts = <String, int>{};
    var total = 0;
    for (final answers in _allAnswerCombinations()) {
      final menu = LocalRecommendationEngine.pick(answers);
      counts[menu] = (counts[menu] ?? 0) + 1;
      total++;
    }
    for (final entry in counts.entries) {
      expect(
        entry.value / total,
        lessThan(0.2),
        reason: '${entry.key}에 추천이 쏠려 있다',
      );
    }
  });

  test('같은 답변에는 같은 결과가 나온다', () {
    const answers = ['매화 분홍', '흐리고 지침', '가족', '촉촉한', '봄', '둥근 모양'];
    final first = LocalRecommendationEngine.pick(answers);
    for (var i = 0; i < 20; i++) {
      expect(LocalRecommendationEngine.pick(answers), first);
    }
  });

  test('질문을 모두 건너뛰어도(빈 답변) 유효한 메뉴를 돌려준다', () {
    final menu = LocalRecommendationEngine.pick(['', '', '', '', '', '']);
    expect(dagwaResults.containsKey(menu), isTrue);
  });

  test('RecommendationService는 기본으로 온디바이스 엔진을 쓴다', () async {
    final service = RecommendationService();
    expect(service.engine, isA<LocalRecommendationEngine>());

    final menu = await service.getRecommendation([
      '먹색',
      '혼자',
      '설레고 두근거려요',
      '바삭한',
      '겨울',
      '직선 모양',
    ]);
    expect(dagwaResults.containsKey(menu), isTrue);
  });
}
