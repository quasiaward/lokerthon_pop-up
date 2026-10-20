import 'dart:convert';
import 'dart:math' as math;

import '../data/quiz_questions.dart';
import 'recommendation_engine.dart';

/// 기기 안에서 도는 취향 프로필 기반 추천 엔진.
///
/// ## 구조
/// 1. 다과마다 **특성 프로필**([_profiles])을 둔다. 맛·식감·분위기·어울리는
///    자리·계절·모양·색을 0~1로 매긴 값이다. 값은 각 다과의 조리법과 쓰임,
///    결과 이미지의 모양·색을 보고 정했다(아래 "근거" 참고).
/// 2. 답변 하나는 "이런 특성을 원한다"는 **요구 벡터**([_answerTraits])가 된다.
///    예를 들어 '흐리고 지침'은 위로·기력·단맛을 원한다.
/// 3. 답변마다 활성 다과들과의 일치도를 **표준화**(평균 0, 표준편차 1)한다.
///    모든 다과가 비슷하게 맞는 답변은 결과를 흔들지 않고, 다과를 가르는
///    답변일수록 크게 움직인다. 여기에 질문 가중치([_questionWeights])를
///    곱해 더한 값이 **적합도**다.
/// 4. 다과마다 **보정값**을 더한다. 특성이 많은 다과가 늘 이기지 않도록,
///    4096개 조합에서 활성 다과가 고르게 나오게 맞춘 값이다. 앱이 처음
///    추천할 때 한 번 계산한다([_calibration]).
/// 5. 관리자 **추천 비중**은 `온도 × 4.5 × ln(비중)`만큼 적합도를 옮긴다.
///    비중이 w이면 그 다과가 후보일 때 뽑힐 확률이 w^4.5배 쪽으로 움직여,
///    4096개 조합 기준 1.15는 약 1.6배, 0.85는 약 절반이 된다.
/// 6. 적합도 상위 [_candidateCount]개만 후보로 남기고, 적합도가 높을수록
///    확률이 큰 분포(온도 [_temperature])를 만든다. 확률이 [_minOdds]보다
///    낮은 후보는 뺀다. 답변 6개로 만든 고정 난수로 이 분포에서 하나를 뽑는다.
///
/// 같은 답변에는 늘 같은 결과가 나오고, 결과는 언제나 적합도 상위 3종
/// 안에서 나온다. 한 다과가 확실히 앞서는 답변이면 그 다과가 그대로 나오고,
/// 엇비슷한 답변일수록 후보가 갈린다. 답변을 하나만 바꿔도 적합도와 난수가
/// 함께 바뀌므로 결과가 쉽게 달라진다.
///
/// 점수를 더하기만 하면 답변 하나를 바꿨을 때 결과가 바뀌는 비율이 50%
/// 언저리에서 멈춘다(특성을 무작위로 줘도 같다). 상위 후보 안에서 뽑으면
/// 일관성을 거의 잃지 않고 약 64%까지 오른다. 결과는 적합도 1위 약 59%,
/// 2위 26%, 3위 15%로 나온다.
///
/// ## 근거
/// - 흑임자다식: 볶은 검은깨 가루를 꿀로 반죽해 다식판에 박는다. 입에서
///   부드럽게 부서지며 고소하다. 다식판의 꽃·수복(壽福) 문양, 제례에 쓰는
///   무채색 다식. 기력을 채우는 따뜻한 보양 간식이라 늦가을·겨울에 어울린다.
/// - 도라지정과: 도라지를 꿀·조청에 여러 번 달이고 말려 쫀득하다. 짙은
///   적갈색의 곧은 뿌리 모양. 서두르지 않는 클래식한 맛, 목을 달래는 가을·
///   겨울 간식이자 오래 이어 온 명절 선물.
/// - 육포다식: 육포를 다식처럼 둥근 꽃문양 틀에 박고 가운데 잣을 올린다.
///   익숙한 재료를 낯설게 만든 이색 다과라 엉뚱하고 새로운 자리에 어울린다.
///   잣은 소나무 열매라 청록과도 닿는다. 추석 선물로 많이 쓰는 가을 다과.
/// - 콩고물 도라지정과: 도라지를 꿀·조청에 오래 졸여 쫀득하고, 콩고물이
///   고소하다. 길쭉한 뿌리 결. 도라지는 가을에 캐고 목을 달래는 겨울 간식.
///   은은한 단맛이라 세대 구분 없이 편하다.
/// - 곶감 호두말이: 곶감 속에 호두를 넣어 만다. 단맛과 고소함, 쫀득한 곶감.
///   주황빛 둥근 몸에 물결진 테두리. 곶감은 겨울 제철이고 명절 선물로 쓴다.
/// - 구움 견과 강정: 여러 견과를 구워 조청으로 엮는다. 바삭하고 고소하며
///   여럿이 집어 먹는 간식. 수확철인 가을, 휘어진 캐슈·피칸의 곡선.
/// - 금귤정과: 통금귤을 꿀·조청에 졸인다. 새콤달콤하고 말랑·촉촉하다.
///   작고 둥근 노란 열매, 제철은 늦겨울~이른 봄. 선물하기 좋은 고급 정과.
/// - 깨강정: 깨를 조청에 버무려 네모나게 굳힌다. 바삭하고 고소한 금빛 바.
///   설에 많이 만드는 강정이라 겨울, 여럿이 나눠 먹는 밝은 간식.
/// - 영양찰떡: 찹쌀에 견과·곡물을 넣어 찐다. 쫀득하고 든든한 둥근 떡,
///   가족을 챙기는 기력 보충 간식. 잣·콩이 박혀 있다.
/// - 양갱: 팥앙금과 한천을 졸여 굳힌다. 매끈하고 부드러우며 수분이 많다.
///   시원하게 먹는 여름 간식, 네모난 막대형. 팥의 짙은 색과 깊은 단맛.
///   혼자 조용히 즐기는 "취향 확고한" 다과.
/// - 매작과: 반죽을 꼬아 튀기고 조청·잣가루를 입힌다. 바삭하다. 이름이
///   매화 가지에 앉은 참새에서 왔고, 꼬인 물결 모양과 꽃잎 모양. 잔칫상의
///   유밀과라 여럿이 나눠 먹는 즐거운 자리에 어울린다.
/// - 수원약과: 겹겹이 쌓은 네모 약과. 겉은 바삭하고 속은 촉촉하며 꿀 향이
///   깊다. 전통에 새 감각을 더한 메뉴라 설레는 선물 자리에 어울린다.
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
    return _draw(_seed(answers), [
      for (final menu in candidates)
        _total(_baseScore(answers, menu), menu, weights[menu] ?? 1.0),
    ], candidates);
  }

  /// 후보 전체를 적합도 순으로 돌려준다. 결과 검수와 튜닝용.
  static List<RecommendationScore> rank(
    List<String> answers, {
    Iterable<String>? availableMenus,
    Map<String, double> weights = const {},
  }) {
    final candidates = _candidates(availableMenus);
    final totals = [
      for (final menu in candidates)
        _total(_baseScore(answers, menu), menu, weights[menu] ?? 1.0),
    ];
    final odds = _odds(totals);
    final scores = [
      for (var i = 0; i < candidates.length; i++)
        RecommendationScore._(
          menu: candidates[i],
          perQuestion: [
            for (var q = 0; q < _questionWeights.length; q++)
              q < answers.length
                  ? _questionWeights[q] * _fit(answers[q], candidates[i])
                  : 0.0,
          ],
          calibration: _calibration[candidates[i]] ?? 0,
          weight: weights[candidates[i]] ?? 1.0,
          total: totals[i],
          probability: odds[i],
        ),
    ];
    scores.sort((a, b) => b.total.compareTo(a.total));
    return scores;
  }

  /// 모든 답변 조합(4^6 = 4096가지)이 고르게 나온다고 볼 때 각 다과가
  /// 추천되는 비율. 관리자 화면에서 비중을 바꿀 때 미리보기로 쓴다.
  /// 실제 [pick] 결과를 그대로 센 값이다.
  static Map<String, double> expectedShares({
    Iterable<String>? availableMenus,
    Map<String, double> weights = const {},
  }) {
    final candidates = _candidates(availableMenus);
    final columns = [
      for (final menu in candidates) activeDagwaMenus.indexOf(menu),
    ];
    final counts = List.filled(candidates.length, 0);
    final totals = List.filled(candidates.length, 0.0);
    for (final combo in _combos) {
      for (var i = 0; i < candidates.length; i++) {
        totals[i] = _total(
          combo.base[columns[i]],
          candidates[i],
          weights[candidates[i]] ?? 1.0,
        );
      }
      counts[candidates.indexOf(_draw(combo.seed, totals, candidates))]++;
    }
    return {
      for (var i = 0; i < candidates.length; i++)
        candidates[i]: counts[i] / _combos.length,
    };
  }

  /// 후보로 남기는 적합도 상위 다과 수.
  static const _candidateCount = 3;

  /// 후보 사이의 확률 차. 낮을수록 1위만, 높을수록 고르게 뽑는다.
  static const _temperature = 1.8;

  /// 이보다 뽑힐 확률이 낮은 후보는 뺀다. 누가 봐도 한 다과인 답변에서
  /// 엉뚱한 3위가 나오지 않게 한다.
  static const _minOdds = 0.1;

  /// 관리자 비중의 세기. 뽑힐 확률이 비중의 이 거듭제곱만큼 바뀐다.
  static const _weightStrength = 4.5;

  static double _total(double base, String menu, double weight) =>
      base +
      (_calibration[menu] ?? 0) +
      _temperature * _weightStrength * math.log(weight);

  /// 적합도 상위 후보의 뽑힐 확률. 후보 밖은 0이다.
  static List<double> _odds(List<double> totals) {
    final order = List.generate(totals.length, (i) => i)
      ..sort((a, b) {
        final c = totals[b].compareTo(totals[a]);
        return c != 0 ? c : a.compareTo(b);
      });
    final top = order.take(_candidateCount).toList();
    final best = totals[top.first];
    final odds = List.filled(totals.length, 0.0);
    var sum = 0.0;
    for (final i in top) {
      odds[i] = math.exp((totals[i] - best) / _temperature);
      sum += odds[i];
    }
    var kept = 0.0;
    for (final i in top) {
      odds[i] /= sum;
      if (odds[i] < _minOdds) {
        odds[i] = 0;
      } else {
        kept += odds[i];
      }
    }
    for (final i in top) {
      odds[i] /= kept;
    }
    return odds;
  }

  /// [seed](0~1)로 후보 하나를 뽑는다. 확률 구간은 메뉴 목록 순서로 놓는다.
  /// 점수 순으로 놓으면 비중을 올린 다과가 순위만 바뀌어 오히려 빠질 수
  /// 있지만, 순서가 고정되면 그 다과의 구간은 늘 넓어지기만 한다.
  static String _draw(
    double seed,
    List<double> totals,
    List<String> candidates,
  ) {
    final odds = _odds(totals);
    var left = seed;
    var last = 0;
    for (var i = 0; i < candidates.length; i++) {
      if (odds[i] == 0) continue;
      last = i;
      left -= odds[i];
      if (left < 0) return candidates[i];
    }
    return candidates[last];
  }

  /// 답변 6개로 만든 0~1 고정 난수. 같은 답변이면 늘 같고, 하나만 달라도
  /// 전혀 다른 값이 된다(FNV-1a 뒤 비트 섞기).
  static double _seed(List<String> answers) {
    var hash = 0x811c9dc5;
    for (final answer in answers) {
      for (final byte in [...utf8.encode(answer.trim()), 0x7c]) {
        hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
      }
    }
    hash ^= hash >> 16;
    hash = (hash * 0x7feb352d) & 0xffffffff;
    hash ^= hash >> 15;
    hash = (hash * 0x846ca68b) & 0xffffffff;
    hash ^= hash >> 16;
    return hash / 0x100000000;
  }

  static double _baseScore(List<String> answers, String menu) {
    var score = 0.0;
    for (var q = 0; q < _questionWeights.length && q < answers.length; q++) {
      score += _questionWeights[q] * _fit(answers[q].trim(), menu);
    }
    return score;
  }

  /// 답변이 이 다과를 다른 활성 다과보다 얼마나 더 가리키는지(표준 점수).
  /// 건너뛴·알 수 없는 답변은 0이다.
  static double _fit(String answer, String menu) =>
      _standardized[answer]?[menu] ?? 0;

  static double _match(Map<_T, double> wants, Map<_T, double> profile) {
    var match = 0.0;
    var total = 0.0;
    wants.forEach((trait, weight) {
      match += weight * (profile[trait] ?? 0);
      total += weight;
    });
    return total == 0 ? 0 : match / total;
  }

  static final Map<String, Map<String, double>> _standardized = {
    for (final entry in _answerTraits.entries)
      entry.key: () {
        final raw = [
          for (final menu in activeDagwaMenus)
            _match(entry.value, _profiles[menu] ?? const {}),
        ];
        final mean = raw.fold(0.0, (a, b) => a + b) / raw.length;
        final variance =
            raw.fold(0.0, (a, b) => a + (b - mean) * (b - mean)) / raw.length;
        final sd = variance > 0 ? math.sqrt(variance) : 1.0;
        return {
          for (var i = 0; i < raw.length; i++)
            activeDagwaMenus[i]: (raw[i] - mean) / sd,
        };
      }(),
  };

  /// 4096개 답변 조합과 활성 다과별 적합도. 한 번만 계산해 둔다.
  static final List<_Combo> _combos = () {
    var prefixes = <List<String>>[[]];
    for (final question in quizQuestions) {
      prefixes = [
        for (final prefix in prefixes)
          for (final option in question.options) [...prefix, option.title],
      ];
    }
    return [
      for (final answers in prefixes)
        _Combo(_seed(answers), [
          for (final menu in activeDagwaMenus) _baseScore(answers, menu),
        ]),
    ];
  }();

  /// 다과별 보정값. 4096개 조합에서 각 다과가 뽑힐 기대 확률이 같아지도록
  /// 적합도를 옮긴다. 기대 확률은 매끄럽게 변해서 30번 안팎이면 수렴한다.
  static final Map<String, double> _calibration = () {
    final n = activeDagwaMenus.length;
    final bias = List.filled(n, 0.0);
    final totals = List.filled(n, 0.0);
    for (var iteration = 0; iteration < 200; iteration++) {
      final shares = List.filled(n, 0.0);
      for (final combo in _combos) {
        for (var i = 0; i < n; i++) {
          totals[i] = combo.base[i] + bias[i];
        }
        final odds = _odds(totals);
        for (var i = 0; i < n; i++) {
          shares[i] += odds[i] / _combos.length;
        }
      }
      var error = 0.0;
      for (var i = 0; i < n; i++) {
        error = math.max(error, (shares[i] - 1 / n).abs());
        bias[i] -= 4 * (shares[i] - 1 / n);
      }
      if (error < 1e-4) break;
    }
    return {for (var i = 0; i < n; i++) activeDagwaMenus[i]: bias[i]};
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

  /// 첫 추천이 늦지 않도록 조합 표와 보정값을 미리 계산한다.
  static void warmUp() => _calibration.length;

  /// 테스트용: 프로필이 정의된 메뉴.
  static Iterable<String> get profiledMenus => _profiles.keys;

  /// 테스트용: 점수표가 아는 답변 키.
  static Iterable<String> get knownAnswers => _answerTraits.keys;
}

class _Combo {
  const _Combo(this.seed, this.base);

  final double seed;
  final List<double> base;
}

/// 한 다과의 점수 내역.
class RecommendationScore {
  const RecommendationScore._({
    required this.menu,
    required this.perQuestion,
    required this.calibration,
    required this.weight,
    required this.total,
    required this.probability,
  });

  final String menu;

  /// 질문 순서대로의 적합도(표준 점수 × 질문 가중치).
  final List<double> perQuestion;

  /// 다과가 고르게 나오도록 더한 보정값.
  final double calibration;

  /// 관리자가 정한 추천 비중.
  final double weight;

  /// 보정·비중까지 더한 최종 적합도.
  final double total;

  /// 이 답변에서 뽑힐 확률. 상위 후보가 아니면 0이다.
  final double probability;

  /// 보정·비중을 더하기 전 적합도.
  double get baseTotal => perQuestion.fold(0, (sum, v) => sum + v);

  @override
  String toString() =>
      '$menu ${total.toStringAsFixed(3)} '
      '(${(probability * 100).toStringAsFixed(0)}%) '
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
  novel, // 새롭고 엉뚱한 개성
  nourish, // 기력을 채우는 든든함
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

/// 질문 가중치. 표준화한 뒤라 분위기 질문도 다과를 충분히 가르므로
/// 식감·계절에만 조금 더 무게를 둔다.
const _questionWeights = <double>[
  1.0, // Q1 기분의 색
  1.0, // Q2 마음의 날씨
  1.0, // Q3 함께한 사람
  1.2, // Q4 식감
  1.1, // Q5 계절
  1.0, // Q6 문양
];

/// 다과 특성 프로필 (0~1). 적지 않은 특성은 0이다.
/// 비활성 다과도 다시 켤 때를 위해 남겨 둔다. 표준화·보정은 활성 다과만 쓴다.
const _profiles = <String, Map<_T, double>>{
  '흑임자다식': {
    _T.nutty: 1.0,
    _T.deep: 0.9,
    _T.sweet: 0.4,
    _T.soft: 0.8,
    _T.moist: 0.2,
    _T.calm: 1.0,
    _T.comfort: 0.6,
    _T.nourish: 1.0,
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
  '도라지정과': {
    _T.sweet: 0.6,
    _T.deep: 0.9,
    _T.chewy: 1.0,
    _T.moist: 0.4,
    _T.calm: 0.9,
    _T.comfort: 0.5,
    _T.nourish: 0.6,
    _T.solo: 0.7,
    _T.gift: 0.8,
    _T.family: 0.5,
    _T.sharing: 0.2,
    _T.autumn: 0.9,
    _T.winter: 0.8,
    _T.straight: 1.0,
    _T.ink: 0.6,
    _T.pink: 0.5,
  },
  '육포다식': {
    _T.nutty: 0.5,
    _T.deep: 0.7,
    _T.sweet: 0.3,
    _T.chewy: 0.6,
    _T.soft: 0.4,
    _T.novel: 1.0,
    _T.festive: 0.6,
    _T.bright: 0.5,
    _T.sharing: 0.9,
    _T.gift: 0.5,
    _T.family: 0.4,
    _T.solo: 0.3,
    _T.autumn: 0.8,
    _T.winter: 0.5,
    _T.round: 0.8,
    _T.flower: 1.0,
    _T.ink: 0.5,
    _T.yellow: 0.2,
    _T.green: 0.3,
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
    _T.nourish: 0.5,
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
  '곶감 호두말이': {
    _T.sweet: 0.8,
    _T.nutty: 0.7,
    _T.deep: 0.6,
    _T.chewy: 0.8,
    _T.soft: 0.5,
    _T.moist: 0.4,
    _T.calm: 0.8,
    _T.comfort: 0.4,
    _T.novel: 0.3,
    _T.solo: 0.9,
    _T.gift: 0.8,
    _T.family: 0.5,
    _T.sharing: 0.3,
    _T.winter: 1.0,
    _T.autumn: 0.7,
    _T.round: 0.6,
    _T.wave: 0.6,
    _T.yellow: 0.6,
    _T.pink: 0.5,
  },
  '구움 견과 강정': {
    _T.nutty: 1.0,
    _T.sweet: 0.5,
    _T.crisp: 0.9,
    _T.chewy: 0.2,
    _T.bright: 0.8,
    _T.festive: 0.7,
    _T.novel: 0.4,
    _T.sharing: 1.0,
    _T.family: 0.5,
    _T.gift: 0.5,
    _T.solo: 0.2,
    _T.autumn: 1.0,
    _T.summer: 0.4,
    _T.winter: 0.3,
    _T.wave: 0.6,
    _T.round: 0.5,
    _T.yellow: 0.6,
    _T.ink: 0.2,
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
    _T.novel: 0.5,
    _T.gift: 1.0,
    _T.sharing: 0.6,
    _T.family: 0.4,
    _T.solo: 0.2,
    _T.spring: 0.9,
    _T.winter: 0.5,
    _T.summer: 0.4,
    _T.round: 1.0,
    _T.flower: 0.3,
    _T.yellow: 1.0,
    _T.pink: 0.4,
  },
  '깨강정': {
    _T.nutty: 0.9,
    _T.sweet: 0.7,
    _T.crisp: 1.0,
    _T.bright: 1.0,
    _T.festive: 0.8,
    _T.novel: 0.3,
    _T.comfort: 0.2,
    _T.sharing: 1.0,
    _T.family: 0.6,
    _T.gift: 0.3,
    _T.winter: 0.7,
    _T.autumn: 0.5,
    _T.summer: 0.3,
    _T.straight: 1.0,
    _T.yellow: 1.0,
    _T.ink: 0.3,
  },
  '영양찰떡': {
    _T.chewy: 1.0,
    _T.soft: 0.7,
    _T.moist: 0.6,
    _T.nutty: 0.7,
    _T.sweet: 0.5,
    _T.deep: 0.5,
    _T.comfort: 0.9,
    _T.nourish: 1.0,
    _T.calm: 0.5,
    _T.family: 1.0,
    _T.gift: 0.5,
    _T.sharing: 0.5,
    _T.winter: 0.8,
    _T.autumn: 0.6,
    _T.round: 1.0,
    _T.flower: 0.6,
    _T.yellow: 0.7,
    _T.green: 0.4,
    _T.ink: 0.3,
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
    _T.novel: 0.2,
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
  '수원약과': {
    _T.sweet: 0.9,
    _T.deep: 0.8,
    _T.crisp: 0.7,
    _T.moist: 0.7,
    _T.soft: 0.3,
    _T.chewy: 0.4,
    _T.festive: 0.8,
    _T.bright: 0.6,
    _T.novel: 0.7,
    _T.comfort: 0.4,
    _T.gift: 0.9,
    _T.sharing: 0.7,
    _T.family: 0.6,
    _T.solo: 0.3,
    _T.autumn: 0.7,
    _T.winter: 0.6,
    _T.spring: 0.3,
    _T.straight: 0.8,
    _T.wave: 0.4,
    _T.flower: 0.4,
    _T.yellow: 0.7,
    _T.pink: 0.3,
    _T.green: 0.2,
  },
};

/// 답변(로직 키) → 원하는 특성과 그 비중.
///
/// 키는 `quiz_questions.dart`의 `QuizOption.title`과 **정확히** 같아야 한다.
const _answerTraits = <String, Map<_T, double>>{
  // ── Q1. 오늘 당신의 기분은 어떤 색인가요? ──────────────────────────────
  '매화 분홍': {_T.pink: 1.0, _T.festive: 0.5, _T.sweet: 0.3, _T.spring: 0.2},
  '소나무 청록': {_T.green: 1.0, _T.calm: 0.3, _T.bright: 0.3, _T.deep: 0.3},
  '유자 노랑': {_T.yellow: 1.0, _T.bright: 0.7, _T.tangy: 0.6},
  '먹색': {_T.ink: 1.0, _T.deep: 0.7, _T.calm: 0.5},

  // ── Q2. 오늘 마음의 날씨는 어떤가요? ───────────────────────────────────
  '맑고 활기참': {_T.bright: 1.0, _T.crisp: 0.3, _T.tangy: 0.3, _T.novel: 0.3},
  '흐리고 지침': {_T.comfort: 1.0, _T.nourish: 0.6, _T.sweet: 0.5, _T.soft: 0.3},
  // 화면 표시는 '선선하고 평온'
  '잔잔하고 평온': {_T.calm: 1.0, _T.deep: 0.5, _T.autumn: 0.2},
  // 화면 표시는 '따뜻하고 두근거림'
  '설레고 두근거려요': {_T.festive: 1.0, _T.novel: 0.6, _T.bright: 0.4, _T.sweet: 0.3},

  // ── Q3. 오늘 이 자리, 누구와 함께 하셨나요? ────────────────────────────
  '소중한 사람': {_T.gift: 1.0, _T.festive: 0.3},
  '혼자': {_T.solo: 1.0, _T.calm: 0.3},
  '가족': {_T.family: 1.0, _T.comfort: 0.4, _T.nourish: 0.3},
  '친구': {_T.sharing: 1.0, _T.bright: 0.3, _T.novel: 0.3},

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
