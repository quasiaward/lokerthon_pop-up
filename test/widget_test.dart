import 'package:flutter_test/flutter_test.dart';
import 'package:haenggung_dagwa/services/recommendation_service.dart';

void main() {
  testWidgets('placeholder', (tester) async {});

  test('local AI prompt includes every recommendation question axis', () {
    final service = RecommendationService();
    final prompt = service.buildLocalAiPrompt(defaultRecommendationInput);

    expect(prompt, contains('행궁다과'));
    expect(prompt, contains('색감/성향'));
    expect(prompt, contains(defaultRecommendationInput.personality));
    expect(prompt, contains('마음 날씨/방문 순간'));
    expect(prompt, contains(defaultRecommendationInput.moment));
    expect(prompt, contains('동행/차 무드'));
    expect(prompt, contains(defaultRecommendationInput.tea));
    expect(prompt, contains('식감'));
    expect(prompt, contains(defaultRecommendationInput.texture));
    expect(prompt, contains('계절/단맛'));
    expect(prompt, contains(defaultRecommendationInput.sweetness));
    expect(prompt, contains('모양/선택 성향'));
    expect(prompt, contains(defaultRecommendationInput.choiceStyle));
    expect(prompt, contains('추천은 다과상 구성이나 임시 이미지가 아니라'));
    expect(prompt, contains('내부 점수표'));
  });

  test('recommendation summary follows local prompt tone', () {
    final service = RecommendationService();
    final result = service.getRecommendation(defaultRecommendationInput);

    expect(result.aiSummary, contains(result.productName));
    expect(result.aiSummary, isNot(contains('신호가')));
  });
}
