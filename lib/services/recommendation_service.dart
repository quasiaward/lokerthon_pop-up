import 'dart:convert';

import 'package:http/http.dart' as http;

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

class RecommendationService {
  Future<String> getRecommendation(List<String> answers) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/recommend'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'answers': answers}),
        )
        .timeout(const Duration(seconds: 4));
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
