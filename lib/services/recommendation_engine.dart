export '../data/dangwa_catalog.dart';

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
