import 'package:flutter/material.dart';

import '../widgets/ai_recommendation_section.dart';
import '../widgets/lang_toggle.dart';

/// 앱의 단일 화면. 다과 추천 퀴즈 하나만 담는다.
class AiRecommendationPage extends StatelessWidget {
  const AiRecommendationPage({super.key});

  static const _background = Color(0xFFFFFCF7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: SingleChildScrollView(child: AIRecommendationSection()),
            ),
            Positioned(
              top: 12,
              right: 20,
              child: Material(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: LangToggle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
