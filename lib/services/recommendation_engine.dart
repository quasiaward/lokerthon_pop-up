/// 6개 퀴즈 답변을 받아 다과 메뉴 이름 하나를 돌려주는 추천 엔진.
///
/// 구현체는 두 가지다.
/// - [LocalRecommendationEngine] : 기기 안에서 규칙 기반으로 계산 (현재 기본값)
/// - [ApiRecommendationEngine]   : 백엔드 `/recommend`(OpenAI) 호출 (추후 전환용)
///
/// 엔진 교체는 [RecommendationService] 한 곳만 건드리면 되도록 분리해 뒀다.
abstract class RecommendationEngine {
  /// [answers]는 항상 6개이며, 각 원소는 퀴즈 옵션의 **로직 키**(한국어 title)다.
  /// 표시용 번역 문자열을 넘기면 안 된다.
  Future<String> recommend(List<String> answers);
}

/// 추천에 사용할 수 있는 12개 다과. 결과 카드(dagwaResults)의 키와 1:1로 맞춘다.
const dagwaMenus = <String>[
  '흑임자다식',
  '도라지정과',
  '육포다식',
  '콩고물 도라지정과',
  '곶감 호두말이',
  '구움 견과 강정',
  '금귤정과',
  '깨강정',
  '영양찰떡',
  '양갱',
  '매작과',
  '수원약과',
];
