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
  test('전체 12개 다과 데이터는 비활성 메뉴까지 모두 보존한다', () {
    expect(dagwaResults.keys, containsAll(dagwaMenus));
    for (final menu in dagwaMenus) {
      final result = dagwaResults[menu]!;
      expect(result.menuName, menu);
      expect(result.imagePath, isNotEmpty);
    }
  });

  test('운영 8종만 추천하고 나머지 4종 데이터는 보존한다', () {
    expect(activeDagwaMenus, [
      '금귤정과',
      '매작과',
      '양갱',
      '콩고물 도라지정과',
      '흑임자다식',
      '구움 견과 강정',
      '도라지정과',
      '육포다식',
    ]);
    expect(activeDagwaMenuSet, activeDagwaMenus.toSet());
    expect(inactiveDagwaMenus, {'곶감 호두말이', '깨강정', '영양찰떡', '수원약과'});
    expect(activeDagwaMenus, isNot(contains(anyOf(inactiveDagwaMenus))));
    expect({
      ...activeDagwaMenus,
      ...inactiveDagwaMenus,
    }, unorderedEquals(dagwaMenus));
    for (final menu in inactiveDagwaMenus) {
      expect(dagwaResults[menu], isNotNull, reason: '$menu 정보가 삭제되면 안 된다');
    }
  });

  test('모든 답변 조합이 결과 카드가 있는 메뉴를 돌려준다', () {
    for (final answers in _allAnswerCombinations()) {
      final menu = LocalRecommendationEngine.pick(answers);
      expect(
        dagwaResults.containsKey(menu) && isDagwaActive(menu),
        isTrue,
        reason: '$answers → $menu (활성 결과 카드가 아님)',
      );
    }
  });

  test('비활성 메뉴는 4096개 답변 조합에서 한 번도 추천되지 않는다', () {
    for (final answers in _allAnswerCombinations()) {
      expect(
        inactiveDagwaMenus,
        isNot(contains(LocalRecommendationEngine.pick(answers))),
        reason: '$answers',
      );
    }
  });

  test('다과마다 특성 프로필이 있고, 모든 선택지가 점수표에 있다', () {
    // 비활성 다과도 다시 켤 때를 위해 프로필을 남겨 둔다.
    expect(LocalRecommendationEngine.profiledMenus, containsAll(dagwaMenus));
    for (final options in _quizOptions) {
      expect(LocalRecommendationEngine.knownAnswers, containsAll(options));
    }
  });

  test('8종이 전체 조합에 고르게 나뉜다 (각 10.5~14.5%)', () {
    final shares = LocalRecommendationEngine.expectedShares();
    expect(shares.keys, unorderedEquals(activeDagwaMenus));
    for (final menu in activeDagwaMenus) {
      expect(shares[menu], inInclusiveRange(0.105, 0.145), reason: menu);
    }
  });

  test('답변 하나만 바꿔도 결과가 자주 바뀌고, 모든 질문이 고르게 영향을 준다', () {
    final results = {
      for (final answers in _allAnswerCombinations())
        answers.join('|'): LocalRecommendationEngine.pick(answers),
    };
    final flips = List.filled(_quizOptions.length, 0);
    var changes = 0;
    for (final answers in _allAnswerCombinations()) {
      final base = results[answers.join('|')];
      for (var q = 0; q < _quizOptions.length; q++) {
        for (final alt in _quizOptions[q]) {
          if (alt == answers[q]) continue;
          changes++;
          final next = [...answers]..[q] = alt;
          if (results[next.join('|')] != base) flips[q]++;
        }
      }
    }
    final perQuestion = changes ~/ _quizOptions.length;
    // 점수를 더하기만 하는 방식은 50% 언저리에서 멈춘다(현재 약 64%).
    expect(flips.fold(0, (a, b) => a + b) / changes, greaterThan(0.6));
    for (var q = 0; q < flips.length; q++) {
      // 분위기 질문도 식감·계절만큼 결과를 움직인다(현재 61~68%).
      expect(flips[q] / perQuestion, greaterThan(0.55), reason: 'Q${q + 1}');
    }
  });

  test('결과는 늘 적합도 상위 3종 안에서 나오고, 1위가 가장 많이 나온다', () {
    final ranks = List.filled(3, 0);
    for (final answers in _allAnswerCombinations()) {
      final ranked = LocalRecommendationEngine.rank(answers);
      final picked = LocalRecommendationEngine.pick(answers);
      final index = ranked.indexWhere((s) => s.menu == picked);
      expect(index, lessThan(3), reason: '$answers');
      expect(ranked[index].probability, greaterThan(0), reason: '$answers');
      expect(
        ranked.fold<double>(0, (sum, s) => sum + s.probability),
        closeTo(1, 1e-9),
      );
      expect(
        ranked.where((s) => s.probability > 0).length,
        lessThanOrEqualTo(3),
      );
      ranks[index]++;
    }
    // 현재 1위 약 59%, 2위 26%, 3위 15%.
    expect(ranks[0], greaterThan(ranks[1]));
    expect(ranks[1], greaterThan(ranks[2]));
    expect(ranks[0] / 4096, greaterThan(0.5));
  });

  test('한 다과가 확실히 앞서는 답변에서는 그 다과가 그대로 나온다', () {
    for (final answers in _allAnswerCombinations()) {
      final ranked = LocalRecommendationEngine.rank(answers);
      for (final score in ranked.skip(1)) {
        if (score.probability == 0) continue;
        // 확률 10% 미만 후보는 아예 빠진다.
        expect(
          score.probability,
          greaterThanOrEqualTo(0.1),
          reason: '$answers',
        );
      }
    }
  });

  test('답변은 조사한 다과 특징과 맞는 결과로 기운다', () {
    List<String> topFor(int question, String answer, [int n = 1]) {
      final counts = <String, int>{};
      for (final answers in _allAnswerCombinations()) {
        if (answers[question] != answer) continue;
        final menu = LocalRecommendationEngine.pick(answers);
        counts[menu] = (counts[menu] ?? 0) + 1;
      }
      final sorted = counts.entries.toList()..sort((a, b) => b.value - a.value);
      return [for (final e in sorted.take(n)) e.key];
    }

    expect(topFor(0, '매화 분홍'), ['매작과']);
    expect(topFor(0, '유자 노랑'), ['금귤정과']);
    expect(topFor(0, '소나무 청록'), ['콩고물 도라지정과']);
    expect(topFor(2, '혼자'), ['양갱']);
    expect(topFor(2, '가족'), ['콩고물 도라지정과']);
    expect(topFor(2, '친구', 2), unorderedEquals(['육포다식', '구움 견과 강정']));
    expect(topFor(3, '바삭한', 2), unorderedEquals(['구움 견과 강정', '매작과']));
    expect(topFor(3, '쫀득한'), ['도라지정과']);
    expect(topFor(4, '봄', 2), unorderedEquals(['매작과', '금귤정과']));
    expect(topFor(4, '여름'), ['양갱']);
    expect(topFor(4, '겨울'), ['흑임자다식']);
    expect(topFor(5, '둥근 모양'), ['금귤정과']);
    expect(topFor(5, '물결 모양'), ['매작과']);
    expect(topFor(5, '직선 모양'), ['도라지정과']);
    expect(topFor(5, '별·꽃 모양', 2), unorderedEquals(['육포다식', '흑임자다식']));
  });

  test('대표 취향 조합은 예상한 다과를 고른다', () {
    const cases = {
      '매작과': ['매화 분홍', '맑고 활기참', '친구', '바삭한', '봄', '물결 모양'],
      '양갱': ['먹색', '잔잔하고 평온', '혼자', '부드러운', '여름', '직선 모양'],
      '콩고물 도라지정과': ['소나무 청록', '흐리고 지침', '가족', '쫀득한', '가을', '직선 모양'],
      '금귤정과': ['유자 노랑', '설레고 두근거려요', '소중한 사람', '촉촉한', '봄', '둥근 모양'],
      '흑임자다식': ['먹색', '흐리고 지침', '혼자', '부드러운', '겨울', '별·꽃 모양'],
      '구움 견과 강정': ['유자 노랑', '맑고 활기참', '친구', '바삭한', '가을', '물결 모양'],
      '도라지정과': ['먹색', '잔잔하고 평온', '소중한 사람', '쫀득한', '겨울', '직선 모양'],
      '육포다식': ['소나무 청록', '설레고 두근거려요', '친구', '쫀득한', '가을', '별·꽃 모양'],
    };
    cases.forEach((expected, answers) {
      expect(
        LocalRecommendationEngine.rank(answers).first.menu,
        expected,
        reason: '$answers',
      );
      expect(
        LocalRecommendationEngine.pick(answers),
        expected,
        reason: '$answers',
      );
    });
  });

  test('비중을 올린 다과는 원래 나오던 조합에서 빠지지 않는다', () {
    for (final menu in activeDagwaMenus) {
      for (final answers in _allAnswerCombinations()) {
        if (LocalRecommendationEngine.pick(answers) != menu) continue;
        expect(
          LocalRecommendationEngine.pick(answers, weights: {menu: 1.1}),
          menu,
          reason: '$menu $answers',
        );
      }
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

  test('교체 엔진이 비활성 메뉴를 반환해도 활성 메뉴로 대체한다', () async {
    final service = RecommendationService(engine: _FixedEngine('수원약과'));
    final menu = await service.getRecommendation([
      '매화 분홍',
      '흐리고 지침',
      '가족',
      '촉촉한',
      '봄',
      '둥근 모양',
    ]);
    expect(isDagwaActive(menu), isTrue);
  });

  test('관리자가 재고 있음으로 두어둔 메뉴 안에서만 추천한다', () async {
    const available = {'양갱', '흑임자다식'};
    for (final answers in _allAnswerCombinations()) {
      expect(
        available,
        contains(
          LocalRecommendationEngine.pick(answers, availableMenus: available),
        ),
      );
    }

    final service = RecommendationService(engine: _FixedEngine('금귤정과'));
    final menu = await service.getRecommendation(
      _quizOptions.map((options) => options.first).toList(),
      availableMenus: available,
    );
    expect(available, contains(menu));
  });

  test('재고가 한 종만 남으면 답변과 무관하게 그 메뉴를 추천한다', () {
    for (final menu in activeDagwaMenus) {
      expect(
        LocalRecommendationEngine.pick(
          _quizOptions.map((options) => options.last).toList(),
          availableMenus: {menu},
        ),
        menu,
      );
    }
  });
}

class _FixedEngine implements RecommendationEngine {
  const _FixedEngine(this.menu);

  final String menu;

  @override
  Future<String> recommend(List<String> answers) async => menu;
}
