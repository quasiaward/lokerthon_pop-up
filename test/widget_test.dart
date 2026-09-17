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

  test('운영 5종만 추천하고 나머지 7종 데이터는 보존한다', () {
    expect(activeDagwaMenus, ['금귤정과', '매작과', '양갱', '콩고물 도라지정과', '흑임자다식']);
    expect(inactiveDagwaMenus, {
      '도라지정과',
      '육포다식',
      '곶감 호두말이',
      '구움 견과 강정',
      '깨강정',
      '영양찰떡',
      '수원약과',
    });
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

  test('활성화된 5개 메뉴가 모두 한 번 이상 추천된다', () {
    final seen = <String>{};
    for (final answers in _allAnswerCombinations()) {
      seen.add(LocalRecommendationEngine.pick(answers));
    }
    expect(seen, unorderedEquals(activeDagwaMenus));
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

  test('한 메뉴가 전체 조합의 절반을 넘게 차지하지 않는다', () {
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
        lessThan(0.5),
        reason: '${entry.key}에 추천이 쏠려 있다',
      );
    }
  });

  test('활성 다과마다 특성 프로필이 있고, 모든 선택지가 점수표에 있다', () {
    expect(
      LocalRecommendationEngine.profiledMenus,
      containsAll(activeDagwaMenus),
    );
    for (final options in _quizOptions) {
      expect(LocalRecommendationEngine.knownAnswers, containsAll(options));
    }
  });

  test('5종이 전체 조합에 고르게 나뉜다 (각 10~30%)', () {
    final counts = <String, int>{};
    var total = 0;
    for (final answers in _allAnswerCombinations()) {
      final menu = LocalRecommendationEngine.pick(answers);
      counts[menu] = (counts[menu] ?? 0) + 1;
      total++;
    }
    for (final menu in activeDagwaMenus) {
      final share = (counts[menu] ?? 0) / total;
      expect(share, inInclusiveRange(0.10, 0.30), reason: '$menu $share');
    }
  });

  test('어느 질문이든 답을 바꾸면 결과가 달라질 수 있다', () {
    final flips = List.filled(_quizOptions.length, 0);
    var total = 0;
    for (final answers in _allAnswerCombinations()) {
      total++;
      final base = LocalRecommendationEngine.pick(answers);
      for (var q = 0; q < _quizOptions.length; q++) {
        final changes = _quizOptions[q].any((alt) {
          if (alt == answers[q]) return false;
          final next = [...answers]..[q] = alt;
          return LocalRecommendationEngine.pick(next) != base;
        });
        if (changes) flips[q]++;
      }
    }
    for (var q = 0; q < flips.length; q++) {
      // 분위기 질문도 무시되지 않되, 식감처럼 직접적인 질문이 더 크게 움직인다.
      expect(flips[q] / total, greaterThan(0.25), reason: 'Q${q + 1}');
    }
    expect(flips[3], greaterThan(flips[0]));
    expect(flips[3], greaterThan(flips[2]));
  });

  test('식감·계절·문양 답변은 조사한 다과 특징과 맞는 결과로 기운다', () {
    String topFor(int question, String answer) {
      final counts = <String, int>{};
      for (final answers in _allAnswerCombinations()) {
        if (answers[question] != answer) continue;
        final menu = LocalRecommendationEngine.pick(answers);
        counts[menu] = (counts[menu] ?? 0) + 1;
      }
      return (counts.entries.toList()..sort((a, b) => b.value - a.value))
          .first
          .key;
    }

    expect(topFor(3, '부드러운'), '양갱');
    expect(topFor(3, '바삭한'), '매작과');
    expect(topFor(3, '쫀득한'), '콩고물 도라지정과');
    expect(topFor(4, '봄'), '금귤정과');
    expect(topFor(4, '여름'), '양갱');
    expect(topFor(4, '가을'), '콩고물 도라지정과');
    expect(topFor(4, '겨울'), '흑임자다식');
    expect(topFor(5, '둥근 모양'), '금귤정과');
    expect(topFor(5, '물결 모양'), '매작과');
    expect(topFor(5, '별·꽃 모양'), '흑임자다식');
  });

  test('대표 취향 조합은 예상한 다과를 고른다', () {
    const cases = {
      '매작과': ['매화 분홍', '맑고 활기참', '친구', '바삭한', '봄', '물결 모양'],
      '양갱': ['먹색', '잔잔하고 평온', '혼자', '부드러운', '여름', '직선 모양'],
      '콩고물 도라지정과': ['소나무 청록', '흐리고 지침', '가족', '쫀득한', '가을', '직선 모양'],
      '금귤정과': ['유자 노랑', '설레고 두근거려요', '소중한 사람', '촉촉한', '봄', '둥근 모양'],
      '흑임자다식': ['먹색', '잔잔하고 평온', '혼자', '부드러운', '겨울', '별·꽃 모양'],
    };
    cases.forEach((expected, answers) {
      expect(
        LocalRecommendationEngine.pick(answers),
        expected,
        reason: '$answers',
      );
    });
  });

  test('1위와 2위가 완전히 같은 점수인 조합이 없다', () {
    for (final answers in _allAnswerCombinations()) {
      final ranked = LocalRecommendationEngine.rank(answers);
      expect(
        ranked[0].total - ranked[1].total,
        greaterThan(1e-9),
        reason: '$answers',
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
