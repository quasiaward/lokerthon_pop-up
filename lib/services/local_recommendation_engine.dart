import '../data/quiz_questions.dart';
import 'recommendation_engine.dart';

/// 기기 안에서 도는 취향 프로필 기반 추천 엔진.
///
/// ## 구조
/// 1. 다과마다 **특성 프로필**([_profiles])을 둔다. 맛·식감·분위기·어울리는
///    자리·계절·모양·색을 0~1로 매긴 값이다. 값은 각 다과의 조리법과 쓰임을
///    조사해 정했다(아래 "근거" 참고).
/// 2. 답변 하나는 "이런 특성을 원한다"는 **요구 벡터**([_answerTraits])가 된다.
///    예를 들어 '흐리고 지침'은 위로·차분함·단맛을 원한다.
/// 3. 질문마다 요구 벡터와 다과 프로필의 **가중 평균 일치도**(0~1)를 구하고,
///    질문 가중치([_questionWeights])를 곱해 더한다.
/// 4. 관리자가 정한 **추천 비중**(기본 1.0)을 총점에 곱한다. 재고가 많은
///    다과는 비중을 올려 더 자주, 적은 다과는 낮춰 덜 나오게 한다.
/// 5. 총점 최고 다과를 고른다. 동점이면 식감 → 계절 → 문양 순으로 더 직접적인
///    신호에서 앞선 다과를, 그래도 같으면 답변 해시로 정한 순서를 쓴다.
///
/// 같은 답변에는 늘 같은 결과가 나온다. 질문 하나의 점수는 그 질문의
/// 가중치를 넘지 않으므로 한 질문이 결과를 혼자 좌우하지 못한다.
///
/// ## 근거
/// - 흑임자다식: 볶은 검은깨 가루를 꿀로 반죽해 다식판에 박는다. 입에서
///   부드럽게 부서지며 고소하다. 다식판의 꽃·수복(壽福) 문양, 제례에 쓰는
///   무채색 다식. 따뜻한 성질의 보양 간식이라 늦가을·겨울에 어울린다.
/// - 콩고물 도라지정과: 도라지를 꿀·조청에 오래 졸여 쫀득하고, 콩고물이
///   고소하다. 길쭉한 뿌리 결. 도라지는 가을에 캐고 목을 달래는 겨울 간식.
///   은은한 단맛이라 세대 구분 없이 편하다.
/// - 금귤정과: 통금귤을 꿀·조청에 졸인다. 새콤달콤하고 말랑·촉촉하다.
///   작고 둥근 노란 열매, 제철은 늦겨울~이른 봄. 선물하기 좋은 고급 정과.
/// - 양갱: 팥앙금과 한천을 졸여 굳힌다. 매끈하고 부드러우며 수분이 많다.
///   시원하게 먹는 여름 간식, 네모난 막대형. 팥의 짙은 색과 깊은 단맛.
///   혼자 조용히 즐기는 "취향 확고한" 다과.
/// - 매작과: 반죽을 꼬아 튀기고 조청·잣가루를 입힌다. 바삭하다. 이름이
///   매화 가지에 앉은 참새에서 왔고, 꼬인 물결 모양과 꽃잎 모양. 잔칫상의
///   유밀과라 여럿이 나눠 먹는 즐거운 자리에 어울린다.
class LocalRecommendationEngine implements RecommendationEngine {
  const LocalRecommendationEngine();

  @override
  Future<String> recommend(List<String> answers) async => pick(answers);

  /// 동기 버전. 테스트와 디버깅에서 쓰기 편하도록 열어 둔다.
  static String pick(
    List<String> answers, {
    Iterable<String>? availableMenus,
    Map<String, double> weights = const {},
  }) {
    final candidates = _candidates(availableMenus);
    final ranked = rank(answers, availableMenus: candidates, weights: weights);
    return ranked.first.menu;
  }

  /// 후보 전체를 점수 순으로 돌려준다. 결과 검수와 튜닝용.
  static List<RecommendationScore> rank(
    List<String> answers, {
    Iterable<String>? availableMenus,
    Map<String, double> weights = const {},
  }) {
    final candidates = _candidates(availableMenus);
    final order = _tieBreakOrder(answers, candidates);
    final scores = [
      for (final menu in candidates)
        RecommendationScore._(
          menu: menu,
          perQuestion: [
            for (var q = 0; q < _questionWeights.length; q++)
              q < answers.length
                  ? _questionScore(q, answers[q].trim(), menu)
                  : 0.0,
          ],
          tieBreak: order.indexOf(menu),
          weight: weights[menu] ?? 1.0,
        ),
    ];
    scores.sort(_compare);
    return scores;
  }

  /// 모든 답변 조합(4^6 = 4096가지)이 고르게 나온다고 볼 때 각 다과가
  /// 추천되는 비율. 관리자 화면에서 비중을 바꿀 때 미리보기로 쓴다.
  static Map<String, double> expectedShares({
    Iterable<String>? availableMenus,
    Map<String, double> weights = const {},
  }) {
    final candidates = _candidates(availableMenus).toSet();
    final counts = {for (final menu in candidates) menu: 0};
    final all = _allScores;
    for (final combo in all) {
      RecommendationScore? best;
      for (final base in combo) {
        if (!candidates.contains(base.menu)) continue;
        final scored = base._withWeight(weights[base.menu] ?? 1.0);
        if (best == null || _compare(scored, best) < 0) best = scored;
      }
      counts[best!.menu] = counts[best.menu]! + 1;
    }
    return {
      for (final entry in counts.entries) entry.key: entry.value / all.length,
    };
  }

  /// 조합별 비중 없는 점수. 한 번만 계산해 둔다.
  /// 마지막 동점 순서는 전체 활성 메뉴 기준이라 후보가 줄면 [pick]과 다를 수
  /// 있지만, 총점이 완전히 같은 경우는 없어(테스트로 확인) 미리보기에는
  /// 영향이 없다.
  static final List<List<RecommendationScore>> _allScores = () {
    final combos = <List<String>>[[]];
    for (final question in quizQuestions) {
      final next = <List<String>>[];
      for (final prefix in combos) {
        for (final option in question.options) {
          next.add([...prefix, option.title]);
        }
      }
      combos
        ..clear()
        ..addAll(next);
    }
    return [for (final answers in combos) rank(answers)];
  }();

  static List<String> _candidates(Iterable<String>? availableMenus) {
    final candidates = [
      for (final menu in activeDagwaMenus)
        if (availableMenus == null || availableMenus.contains(menu)) menu,
    ];
    if (candidates.isEmpty) {
      throw StateError('추천 가능한 재고가 없습니다.');
    }
    return candidates;
  }

  /// 질문 [q]에서 [answer]가 [menu]와 얼마나 맞는지 (0 ~ 질문 가중치).
  static double _questionScore(int q, String answer, String menu) {
    final wants = _answerTraits[answer];
    final profile = _profiles[menu];
    if (wants == null || profile == null) return 0; // 건너뛴·알 수 없는 답변
    var match = 0.0;
    var total = 0.0;
    wants.forEach((trait, weight) {
      match += weight * (profile[trait] ?? 0);
      total += weight;
    });
    return total == 0 ? 0 : _questionWeights[q] * match / total;
  }

  static int _compare(RecommendationScore a, RecommendationScore b) {
    // 부동소수 오차로 순서가 흔들리지 않도록 작은 차이는 동점으로 본다.
    int byValue(double x, double y) =>
        (x - y).abs() < 1e-9 ? 0 : (y > x ? 1 : -1);
    final total = byValue(a.total, b.total);
    if (total != 0) return total;
    for (final q in _tieBreakQuestions) {
      final c = byValue(
        a.perQuestion[q] * a.weight,
        b.perQuestion[q] * b.weight,
      );
      if (c != 0) return c;
    }
    return a.tieBreak.compareTo(b.tieBreak);
  }

  /// 동점일 때 먼저 보는 질문. 메뉴를 직접 가리키는 신호부터 본다.
  static const _tieBreakQuestions = [3, 4, 5, 0, 1, 2];

  /// 마지막 동점 처리. 답변 조합에서 만든 해시로 순서를 돌려, 전부 건너뛴
  /// 경우에도 늘 같은 메뉴만 나오지 않게 한다. 같은 답변에는 같은 순서다.
  static List<String> _tieBreakOrder(
    List<String> answers,
    List<String> candidates,
  ) {
    var hash = 7;
    for (final answer in answers) {
      for (final unit in answer.codeUnits) {
        hash = (hash * 31 + unit) & 0x7fffffff;
      }
      hash = (hash * 31 + 1) & 0x7fffffff;
    }
    final offset = hash % candidates.length;
    return [...candidates.sublist(offset), ...candidates.sublist(0, offset)];
  }

  /// 테스트용: 프로필이 정의된 메뉴.
  static Iterable<String> get profiledMenus => _profiles.keys;

  /// 테스트용: 점수표가 아는 답변 키.
  static Iterable<String> get knownAnswers => _answerTraits.keys;
}

/// 한 다과의 점수 내역.
class RecommendationScore {
  const RecommendationScore._({
    required this.menu,
    required this.perQuestion,
    required this.tieBreak,
    this.weight = 1.0,
  });

  final String menu;

  /// 관리자가 정한 추천 비중. [total]에 곱해진다.
  final double weight;

  /// 질문 순서대로의 점수. 각 값은 0 ~ 그 질문의 가중치.
  final List<double> perQuestion;
  final int tieBreak;

  /// 비중을 곱하기 전 점수.
  double get baseTotal => perQuestion.fold(0, (sum, v) => sum + v);

  /// 비중을 곱한 최종 점수.
  double get total => baseTotal * weight;

  RecommendationScore _withWeight(double weight) => RecommendationScore._(
    menu: menu,
    perQuestion: perQuestion,
    tieBreak: tieBreak,
    weight: weight,
  );

  @override
  String toString() =>
      '$menu ${total.toStringAsFixed(3)} '
      '${perQuestion.map((v) => v.toStringAsFixed(2)).toList()}';
}

/// 다과를 설명하는 특성.
enum _T {
  // 맛
  sweet,
  tangy,
  nutty,
  deep,
  // 식감
  soft,
  crisp,
  chewy,
  moist,
  // 분위기
  bright,
  calm,
  comfort,
  festive,
  // 어울리는 자리
  gift,
  solo,
  family,
  sharing,
  // 계절
  spring,
  summer,
  autumn,
  winter,
  // 모양
  round,
  wave,
  straight,
  flower,
  // 색
  pink,
  green,
  yellow,
  ink,
}

/// 질문 가중치. 식감·계절·문양은 메뉴를 직접 가리키는 신호라 무겁고,
/// 기분·날씨·동행은 분위기 신호라 가볍다.
const _questionWeights = <double>[
  0.9, // Q1 기분의 색
  0.9, // Q2 마음의 날씨
  0.8, // Q3 함께한 사람
  1.4, // Q4 식감
  1.1, // Q5 계절
  1.0, // Q6 문양
];

/// 다과 특성 프로필 (0~1). 적지 않은 특성은 0이다.
const _profiles = <String, Map<_T, double>>{
  '흑임자다식': {
    _T.nutty: 1.0,
    _T.deep: 0.9,
    _T.sweet: 0.4,
    _T.soft: 0.8,
    _T.moist: 0.2,
    _T.calm: 1.0,
    _T.comfort: 0.6,
    _T.festive: 0.2,
    _T.bright: 0.1,
    _T.solo: 0.8,
    _T.family: 0.6,
    _T.gift: 0.5,
    _T.sharing: 0.3,
    _T.winter: 1.0,
    _T.autumn: 0.8,
    _T.flower: 1.0,
    _T.round: 0.6,
    _T.ink: 1.0,
  },
  '콩고물 도라지정과': {
    _T.nutty: 0.8,
    _T.deep: 0.7,
    _T.sweet: 0.5,
    _T.chewy: 1.0,
    _T.soft: 0.4,
    _T.moist: 0.3,
    _T.comfort: 1.0,
    _T.calm: 0.8,
    _T.bright: 0.2,
    _T.family: 1.0,
    _T.sharing: 0.5,
    _T.solo: 0.4,
    _T.gift: 0.4,
    _T.autumn: 1.0,
    _T.winter: 0.5,
    _T.spring: 0.2,
    _T.straight: 1.0,
    _T.wave: 0.3,
    _T.yellow: 0.6,
    _T.green: 0.7,
  },
  '금귤정과': {
    _T.tangy: 1.0,
    _T.sweet: 0.7,
    _T.chewy: 0.7,
    _T.moist: 0.8,
    _T.soft: 0.3,
    _T.bright: 1.0,
    _T.festive: 0.8,
    _T.comfort: 0.3,
    _T.gift: 1.0,
    _T.sharing: 0.6,
    _T.family: 0.4,
    _T.solo: 0.2,
    _T.spring: 0.9,
    _T.winter: 0.5,
    _T.summer: 0.2,
    _T.round: 1.0,
    _T.flower: 0.3,
    _T.yellow: 1.0,
    _T.pink: 0.4,
  },
  '양갱': {
    _T.deep: 0.8,
    _T.sweet: 0.7,
    _T.nutty: 0.2,
    _T.soft: 1.0,
    _T.moist: 0.8,
    _T.calm: 0.9,
    _T.comfort: 0.8,
    _T.festive: 0.1,
    _T.solo: 1.0,
    _T.family: 0.5,
    _T.gift: 0.4,
    _T.sharing: 0.3,
    _T.summer: 1.0,
    _T.autumn: 0.3,
    _T.winter: 0.2,
    _T.straight: 0.9,
    _T.round: 0.2,
    _T.ink: 0.6,
    _T.green: 0.4,
    _T.pink: 0.2,
  },
  '매작과': {
    _T.sweet: 0.7,
    _T.nutty: 0.5,
    _T.crisp: 1.0,
    _T.moist: 0.1,
    _T.festive: 1.0,
    _T.bright: 0.9,
    _T.comfort: 0.3,
    _T.sharing: 1.0,
    _T.family: 0.6,
    _T.gift: 0.6,
    _T.solo: 0.1,
    _T.spring: 1.0,
    _T.summer: 0.3,
    _T.autumn: 0.1,
    _T.wave: 1.0,
    _T.flower: 0.7,
    _T.pink: 1.0,
    _T.yellow: 0.4,
  },
};

/// 답변(로직 키) → 원하는 특성과 그 비중.
///
/// 키는 `quiz_questions.dart`의 `QuizOption.title`과 **정확히** 같아야 한다.
const _answerTraits = <String, Map<_T, double>>{
  // ── Q1. 오늘 당신의 기분은 어떤 색인가요? ──────────────────────────────
  '매화 분홍': {_T.pink: 1.0, _T.festive: 0.5, _T.sweet: 0.3, _T.spring: 0.2},
  '소나무 청록': {_T.green: 1.0, _T.calm: 0.4, _T.bright: 0.3, _T.deep: 0.3},
  '유자 노랑': {_T.yellow: 1.0, _T.bright: 0.7, _T.tangy: 0.6},
  '먹색': {_T.ink: 1.0, _T.deep: 0.7, _T.calm: 0.5},

  // ── Q2. 오늘 마음의 날씨는 어떤가요? ───────────────────────────────────
  '맑고 활기참': {_T.bright: 1.0, _T.crisp: 0.3, _T.tangy: 0.3},
  '흐리고 지침': {_T.comfort: 1.0, _T.sweet: 0.5, _T.calm: 0.4, _T.soft: 0.3},
  // 화면 표시는 '선선하고 평온'
  '잔잔하고 평온': {_T.calm: 1.0, _T.deep: 0.5, _T.autumn: 0.2},
  // 화면 표시는 '따뜻하고 두근거림'
  '설레고 두근거려요': {_T.festive: 1.0, _T.bright: 0.5, _T.sweet: 0.3},

  // ── Q3. 오늘 이 자리, 누구와 함께 하셨나요? ────────────────────────────
  '소중한 사람': {_T.gift: 1.0, _T.festive: 0.3},
  '혼자': {_T.solo: 1.0, _T.calm: 0.3},
  '가족': {_T.family: 1.0, _T.comfort: 0.4},
  '친구': {_T.sharing: 1.0, _T.bright: 0.3},

  // ── Q4. 어떤 식감이 지금 당신을 달래줄 것 같나요? ──────────────────────
  '부드러운': {_T.soft: 1.0, _T.moist: 0.2},
  '바삭한': {_T.crisp: 1.0},
  '쫀득한': {_T.chewy: 1.0},
  '촉촉한': {_T.moist: 1.0, _T.soft: 0.2},

  // ── Q5. 지금 이 순간 어떤 계절이 느껴지시나요? ─────────────────────────
  '봄': {_T.spring: 1.0},
  '여름': {_T.summer: 1.0},
  '가을': {_T.autumn: 1.0},
  '겨울': {_T.winter: 1.0},

  // ── Q6. 어떤 문양이 눈길을 끄시나요? ───────────────────────────────────
  '둥근 모양': {_T.round: 1.0},
  '물결 모양': {_T.wave: 1.0},
  '직선 모양': {_T.straight: 1.0},
  '별·꽃 모양': {_T.flower: 1.0},
};
