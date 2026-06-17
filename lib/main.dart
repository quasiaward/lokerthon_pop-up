import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/lang.dart';
import 'pages/ai_recommendation_page.dart';
import 'pages/custom_page.dart';
import 'pages/experience_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HaenggungDagwaApp());
}

/// 현재 표시 중인 라우트를 기억해, 언어 전환으로 앱이 통째로 다시 빌드돼도
/// 같은 페이지를 유지한다.
String _currentRoute = '/';

class _RouteTracker extends NavigatorObserver {
  void _update(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null) _currentRoute = name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _update(newRoute);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update(previousRoute);
}

final _routeTracker = _RouteTracker();

class HaenggungDagwaApp extends StatelessWidget {
  const HaenggungDagwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Lang>(
      valueListenable: appLang,
      builder: (context, lang, _) {
        // lang을 key로 줘서 언어가 바뀌면 라우트 트리까지 새로 빌드한다.
        return MaterialApp(
          key: ValueKey(lang),
          title: tr('행궁다과 | 화성행궁 전통 디저트 카페',
              'Haenggung Dagwa | Hwaseong Palace Tea House'),
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: currentLocale,
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
          navigatorObservers: [_routeTracker],
          initialRoute: _currentRoute,
          routes: {
            '/': (context) => const HomePage(),
            '/menu': (context) => const MenuPage(),
            '/experience': (context) => const ExperiencePage(),
            '/custom': (context) => const CustomPage(),
            '/ai': (context) => const AiRecommendationPage(),
          },
        );
      },
    );
  }
}
