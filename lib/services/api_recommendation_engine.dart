import 'dart:convert';

import 'package:http/http.dart' as http;

import 'recommendation_engine.dart';

/// 백엔드 `/recommend`(OpenAI)를 호출하는 엔진.
///
/// 지금은 사용하지 않는다. 온디바이스 알고리즘이 충분히 다듬어지면
/// [RecommendationService]에서 이 엔진으로 갈아끼운다.
class ApiRecommendationEngine implements RecommendationEngine {
  const ApiRecommendationEngine({this.baseUrl = _defaultBaseUrl});

  static const _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final String baseUrl;

  @override
  Future<String> recommend(List<String> answers) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/recommend'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'answers': answers}),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('추천 요청 실패: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final menu = data['menu'] as String?;
    if (menu == null || menu.trim().isEmpty) {
      throw Exception('API가 추천 결과를 주지 않았습니다.');
    }
    return menu;
  }
}
