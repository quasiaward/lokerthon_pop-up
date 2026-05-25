import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme/app_theme.dart';
import 'widgets/home_page.dart';

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
      home: const HomePage(),
    );
  }
}
