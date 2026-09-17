import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dangwa_catalog.dart';

abstract interface class AdminSettingsPersistence {
  Future<String?> loadPin();
  Future<void> savePin(String pin);
  Future<Map<String, double>?> loadWeights();
  Future<void> saveWeights(Map<String, double> weights);
}

class SharedPreferencesAdminSettingsPersistence
    implements AdminSettingsPersistence {
  SharedPreferencesAdminSettingsPersistence({SharedPreferencesAsync? prefs})
    : _prefs = prefs;

  static const _pinKey = 'admin_pin_v1';
  static const _weightsKey = 'recommendation_weights_v1';
  SharedPreferencesAsync? _prefs;

  SharedPreferencesAsync get _client => _prefs ??= SharedPreferencesAsync();

  @override
  Future<String?> loadPin() => _client.getString(_pinKey);

  @override
  Future<void> savePin(String pin) => _client.setString(_pinKey, pin);

  @override
  Future<Map<String, double>?> loadWeights() async {
    final raw = await _client.getString(_weightsKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return {
      for (final entry in decoded.entries)
        if (entry.value is num)
          entry.key.toString(): (entry.value as num).toDouble(),
    };
  }

  @override
  Future<void> saveWeights(Map<String, double> weights) =>
      _client.setString(_weightsKey, jsonEncode(weights));
}

enum PinCheck { ok, wrong, locked }

/// 간단 설정의 세 단계. 고급 설정의 비중 값과 같은 저장소를 쓴다.
///
/// 4096개 조합 기준으로 낮음(×0.85)은 그 다과의 추천 비율을 약 절반으로,
/// 높음(×1.15)은 약 1.5배로 바꾼다. ×0.9/×1.1은 변화가 3분의 1 남짓이라
/// 현장에서 체감하기 어려워 폭을 넓혔다. 고급 설정 끝값(×0.8/×1.2)은
/// 더 세게 조절할 여지로 남긴다.
enum WeightLevel {
  low(0.85, '낮음'),
  normal(1.0, '보통'),
  high(1.15, '높음');

  const WeightLevel(this.weight, this.label);

  final double weight;
  final String label;
}

/// 관리자 암호와 추천 비중.
///
/// 둘 다 기기에 저장되어 앱을 다시 켜도 유지된다.
class AdminSettings extends ChangeNotifier {
  AdminSettings({
    AdminSettingsPersistence? persistence,
    DateTime Function()? clock,
  }) : _persistence =
           persistence ?? SharedPreferencesAdminSettingsPersistence(),
       _clock = clock ?? DateTime.now;

  static const defaultPin = '2003';
  static const pinLength = 4;

  /// 연속으로 틀리면 잠시 입력을 막는다.
  static const maxFailures = 5;
  static const lockDuration = Duration(seconds: 30);

  /// 추천 비중 범위. 1.0이 기본(보정 없음)이다.
  /// 비중은 총점에 곱해지는데 1위·2위 점수 차가 크지 않아 조금만 바꿔도
  /// 비율이 크게 움직인다. ±20%면 한 다과의 비율을 대략 0.4~1.8배로
  /// 조절할 수 있고, 0.01 단위 한 칸은 1%p 안팎이다.
  static const minWeight = 0.8;
  static const maxWeight = 1.2;
  static const weightStep = 0.01;

  final AdminSettingsPersistence _persistence;
  final DateTime Function() _clock;

  String _pin = defaultPin;
  Map<String, double> _weights = const {};
  int _failures = 0;
  DateTime? _lockedUntil;

  /// 비중이 1.0이 아닌 메뉴만 담긴다.
  Map<String, double> get weights => _weights;
  double weightOf(String menu) => _weights[menu] ?? 1.0;
  bool get hasCustomWeights => _weights.isNotEmpty;

  /// 현재 비중이 간단 설정의 한 단계와 정확히 같으면 그 단계, 고급 설정에서
  /// 다른 값으로 바꿨으면 null.
  WeightLevel? levelOf(String menu) {
    final weight = weightOf(menu);
    for (final level in WeightLevel.values) {
      if (level.weight == weight) return level;
    }
    return null;
  }

  Future<void> setLevel(String menu, WeightLevel level) =>
      setWeight(menu, level.weight);

  /// 잠금이 풀리기까지 남은 시간. 잠겨 있지 않으면 null.
  Duration? get lockRemaining {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(_clock());
    return left > Duration.zero ? left : null;
  }

  Future<void> initialize() async {
    try {
      final pin = await _persistence.loadPin();
      if (pin != null && isValidPin(pin)) _pin = pin;
      final saved = await _persistence.loadWeights();
      if (saved != null) _weights = _sanitize(saved);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('관리자 설정을 불러오지 못했습니다: $error\n$stackTrace');
    }
  }

  static bool isValidPin(String pin) =>
      pin.length == pinLength && RegExp(r'^\d+$').hasMatch(pin);

  PinCheck checkPin(String input) {
    if (lockRemaining != null) return PinCheck.locked;
    if (input == _pin) {
      _failures = 0;
      _lockedUntil = null;
      return PinCheck.ok;
    }
    _failures++;
    if (_failures >= maxFailures) {
      _failures = 0;
      _lockedUntil = _clock().add(lockDuration);
      return PinCheck.locked;
    }
    return PinCheck.wrong;
  }

  Future<void> changePin(String next) async {
    if (!isValidPin(next)) {
      throw ArgumentError.value(next, 'next', '숫자 $pinLength자리여야 합니다.');
    }
    final previous = _pin;
    _pin = next;
    try {
      await _persistence.savePin(next);
    } catch (_) {
      _pin = previous;
      rethrow;
    }
  }

  Future<void> setWeight(String menu, double value) async {
    if (!activeDagwaMenuSet.contains(menu)) return;
    final next = Map<String, double>.of(_weights);
    final normalized = normalizeWeight(value);
    if (normalized == 1.0) {
      next.remove(menu);
    } else {
      next[menu] = normalized;
    }
    await _save(next);
  }

  Future<void> resetWeights() => _save(const {});

  Future<void> _save(Map<String, double> next) async {
    if (mapEquals(next, _weights)) return;
    final previous = _weights;
    _weights = Map.unmodifiable(next);
    notifyListeners();
    try {
      await _persistence.saveWeights(_weights);
    } catch (_) {
      _weights = previous;
      notifyListeners();
      rethrow;
    }
  }

  /// 범위 안으로 자르고 [weightStep] 단위로 맞춘다.
  static double normalizeWeight(double value) {
    final clamped = value.clamp(minWeight, maxWeight);
    final steps = (clamped / weightStep).round();
    return double.parse((steps * weightStep).toStringAsFixed(2));
  }

  static Map<String, double> _sanitize(Map<String, double> raw) =>
      Map.unmodifiable({
        for (final entry in raw.entries)
          if (activeDagwaMenuSet.contains(entry.key) &&
              normalizeWeight(entry.value) != 1.0)
            entry.key: normalizeWeight(entry.value),
      });
}

final adminSettings = AdminSettings();
