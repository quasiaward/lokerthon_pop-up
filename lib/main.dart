import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/lang.dart';
import 'perf_probe.dart';
import 'pages/kiosk_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 팝업 부스 거치대용 아이패드. 가로로 고정하고 상태 표시줄을 숨긴다.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  PerfProbe.start();
  runApp(const DagwaRecommendationApp());
}

class DagwaRecommendationApp extends StatelessWidget {
  const DagwaRecommendationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Lang>(
      valueListenable: appLang,
      builder: (context, lang, _) {
        // 언어를 바꾸어도 현재 단계와 선택을 유지한다.
        return MaterialApp(
          title: tr('나만의 다과 추천', 'Find Your Dagwa'),
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: currentLocale,
          supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const KioskPage(),
        );
      },
    );
  }
}
