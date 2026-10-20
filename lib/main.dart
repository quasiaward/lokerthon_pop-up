import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/lang.dart';
import 'perf_probe.dart';
import 'pages/kiosk_page.dart';
import 'services/admin_settings.dart';
import 'services/dangwa_inventory.dart';
import 'services/local_recommendation_engine.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 팝업 부스 거치대용 아이패드. 가로로 고정하고 상태 표시줄을 숨긴다.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 확인용 시작 언어. `--dart-define=KIOSK_LANG=ja` 처럼 지정한다.
  // 지정하지 않으면 늘 한국어로 시작한다.
  const startLang = String.fromEnvironment('KIOSK_LANG');
  if (startLang.isNotEmpty) {
    appLang.value = Lang.values.firstWhere(
      (l) => l.name == startLang,
      orElse: () => Lang.ko,
    );
  }

  await dagwaInventory.initialize();
  await adminSettings.initialize();
  // 4096개 조합의 적합도와 다과별 보정값을 미리 계산해 첫 추천이 밀리지 않게 한다.
  LocalRecommendationEngine.warmUp();

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
          title: tr('나만의 다과 추천', 'Find Your Dagwa', '私だけの茶菓選び'),
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
          home: const KioskPage(),
        );
      },
    );
  }
}
