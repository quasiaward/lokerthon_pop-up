import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/ai_recommendation_page.dart';
import 'pages/catering_page.dart';
import 'pages/experience_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HaenggungDagwaApp());
}

class HaenggungDagwaApp extends StatelessWidget {
  const HaenggungDagwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '행궁다과 | 화성행궁 전통 디저트 카페',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/menu': (context) => const MenuPage(),
        '/experience': (context) => const ExperiencePage(),
        '/catering': (context) => const CateringPage(),
        '/ai': (context) => const AiRecommendationPage(),
      },
    );
  }
}
