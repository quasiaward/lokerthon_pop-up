import 'api_recommendation_engine.dart';
import 'local_recommendation_engine.dart';
import 'recommendation_engine.dart';

/// 화면이 쓰는 추천 진입점. 어떤 엔진을 쓸지는 여기서만 결정한다.
///
/// 기본은 온디바이스 알고리즘이라 네트워크도 API 키도 필요 없다.
/// OpenAI 추천으로 전환하려면 빌드할 때 플래그를 켜면 된다.
///
/// ```sh
/// flutter run --dart-define=USE_API=true \
///             --dart-define=API_BASE_URL=https://example.com
/// ```
class RecommendationService {
  RecommendationService({RecommendationEngine? engine})
    : engine = engine ?? _defaultEngine();

  static const useApi = bool.fromEnvironment('USE_API');

  final RecommendationEngine engine;

  static RecommendationEngine _defaultEngine() => useApi
      ? const ApiRecommendationEngine()
      : const LocalRecommendationEngine();

  /// [weights]는 관리자가 정한 추천 비중이다. 온디바이스 엔진에만 적용된다.
  Future<String> getRecommendation(
    List<String> answers, {
    Iterable<String>? availableMenus,
    Map<String, double> weights = const {},
  }) async {
    final available = {
      for (final menu in activeDagwaMenus)
        if (availableMenus == null || availableMenus.contains(menu)) menu,
    };
    if (available.isEmpty) throw StateError('추천 가능한 재고가 없습니다.');

    if (engine is LocalRecommendationEngine) {
      return LocalRecommendationEngine.pick(
        answers,
        availableMenus: available,
        weights: weights,
      );
    }

    final menu = await engine.recommend(answers);
    if (available.contains(menu)) return menu;

    // API나 교체 엔진이 품절·비활성 메뉴를 돌려줘도 관람객에게 노출하지 않는다.
    return LocalRecommendationEngine.pick(
      answers,
      availableMenus: available,
      weights: weights,
    );
  }
}
