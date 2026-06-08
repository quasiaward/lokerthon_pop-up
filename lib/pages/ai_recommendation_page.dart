import 'package:flutter/material.dart';

import '../widgets/ai_recommendation_section.dart';
import '../widgets/page_shell.dart';

class AiRecommendationPage extends StatelessWidget {
  const AiRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageShell(
      currentRoute: '/ai',
      backgroundColor: Color(0xFFFFFCF7),
      child: AIRecommendationSection(),
    );
  }
}
