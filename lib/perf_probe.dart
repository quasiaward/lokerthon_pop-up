import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// 프레임 시간 계측용 임시 도구.
///
/// `--dart-define=PERF_PROBE=true`로 켜면 프레임의 build/raster 시간을 모아
/// 주기적으로 출력한다. 릴리즈 동작에는 영향이 없다.
class PerfProbe {
  static const enabled = bool.fromEnvironment('PERF_PROBE');

  static final _build = <int>[];
  static final _raster = <int>[];
  static Timer? _timer;
  static String label = 'idle';

  static void start() {
    if (!enabled) return;
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        _build.add(t.buildDuration.inMicroseconds);
        _raster.add(t.rasterDuration.inMicroseconds);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _report());
  }

  static void stop() {
    _timer?.cancel();
  }

  static void _report() {
    if (_build.isEmpty) return;
    final b = List<int>.from(_build)..sort();
    final r = List<int>.from(_raster)..sort();
    String p(List<int> v, double q) =>
        (v[(v.length * q).clamp(0, v.length - 1).toInt()] / 1000)
            .toStringAsFixed(1);
    // 16.7ms를 넘는 프레임이 눈에 보이는 끊김이다.
    final janky = r.where((v) => v > 16700).length;
    debugPrint(
      '[PERF][$label] frames=${r.length} '
      'build p50=${p(b, .5)} p90=${p(b, .9)} max=${p(b, 1)} | '
      'raster p50=${p(r, .5)} p90=${p(r, .9)} max=${p(r, 1)} ms | '
      'jank(>16.7ms)=$janky (${(janky / r.length * 100).toStringAsFixed(1)}%)',
    );
    _build.clear();
    _raster.clear();
  }
}
