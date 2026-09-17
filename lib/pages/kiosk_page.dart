import 'dart:async';

import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dangwa_catalog.dart';
import '../data/dagwa_tones.dart';
import '../perf_probe.dart';
import '../data/quiz_questions.dart';
import '../screens/idle_screen.dart';
import '../screens/intro_screen.dart';
import '../screens/question_screen.dart';
import '../screens/result_screen.dart';
import '../screens/transition_screen.dart';
import '../services/recommendation_service.dart';
import '../services/admin_settings.dart';
import '../services/dangwa_inventory.dart';
import '../theme/app_colors.dart';
import '../l10n/lang.dart';
import '../widgets/kiosk/ambient_field.dart';
import '../widgets/kiosk/bloom_backdrop.dart';
import '../widgets/kiosk/kiosk_canvas.dart';
import '../widgets/kiosk/admin_inventory_sheet.dart';
import '../widgets/kiosk/admin_pin_pad.dart';
import '../widgets/kiosk/store_directions_sheet.dart';
import '../widgets/lang_toggle.dart';

enum _Stage { idle, intro, question, transition, result }

enum _AdminStage { closed, pin, open }

/// 팝업 부스 키오스크의 단일 화면. 단계 전환만 관리한다.
class KioskPage extends StatefulWidget {
  const KioskPage({
    super.key,
    this.service,
    this.inventory,
    this.adminSettings,
  });

  final RecommendationService? service;
  final DagwaInventory? inventory;
  final AdminSettings? adminSettings;

  @override
  State<KioskPage> createState() => _KioskPageState();
}

class _KioskPageState extends State<KioskPage> with TickerProviderStateMixin {
  /// 앞 사용자의 결과가 남아 있지 않도록 무동작이 이어지면 Idle로 돌아간다.
  static const _inactivity = Duration(seconds: 45);

  late final _service = widget.service ?? RecommendationService();
  late final _inventory = widget.inventory ?? dagwaInventory;
  late final _adminSettings = widget.adminSettings ?? adminSettings;
  late final _motion = AnimationController(
    vsync: this,
    value: 1,
    duration: Motion.base,
    reverseDuration: Motion.exit,
  );
  late final _stageMotion = CurvedAnimation(
    parent: _motion,
    curve: Motion.emphasized,
    reverseCurve: Motion.exitCurve,
  );

  /// 질문끼리 넘길 때는 상단 조작·진행 표시를 그대로 두고 질문 블록만
  /// 사라졌다 나타난다. 진행 선이 화면과 함께 깜빡이지 않게 하기 위해서다.
  late final _questionMotion = AnimationController(
    vsync: this,
    value: 1,
    duration: Motion.base,
    reverseDuration: Motion.exit,
  );
  late final _questionBodyMotion = CurvedAnimation(
    parent: _questionMotion,
    curve: Motion.emphasized,
    reverseCurve: Motion.exitCurve,
  );
  bool _busy = false;
  int _session = 0;
  String? _error;

  /// 관리자 진입 단계. 로고를 길게 누르면 암호 패드부터 뜬다.
  _AdminStage _admin = _AdminStage.closed;

  /// 디자인 확인용 진입 단계. `--dart-define=KIOSK_STAGE=result` 처럼 지정하면
  /// 해당 화면에서 바로 시작한다. 지정하지 않으면 늘 idle에서 시작한다.
  static const _debugStage = String.fromEnvironment('KIOSK_STAGE');

  /// 결과 화면을 특정 다과로 띄워 보기 위한 확인용 값.
  /// `--dart-define=KIOSK_MENU=금귤정과` 처럼 지정한다. 목록에 없는 이름이면
  /// 무시하고 첫 번째 다과를 쓴다.
  static const _debugMenu = String.fromEnvironment('KIOSK_MENU');

  late _Stage _stage = _initialStage();
  int _step = 0;
  late List<String?> _answers = List.filled(quizQuestions.length, null);
  late String? _menuName = _debugStage.isEmpty
      ? null
      : (dagwaMenus.contains(_debugMenu) ? _debugMenu : dagwaMenus.first);
  Timer? _idleTimer;

  _Stage _initialStage() => switch (_debugStage) {
    'intro' => _Stage.intro,
    'question' => _Stage.question,
    'transition' => _Stage.transition,
    'result' => _Stage.result,
    _ => _Stage.idle,
  };

  bool _precached = false;

  List<String> get _availableMenus => [
    for (final menu in activeDagwaMenus)
      if (_inventory.value.contains(menu)) menu,
  ];

  @override
  void initState() {
    super.initState();
    _inventory.addListener(_inventoryChanged);
  }

  void _inventoryChanged() {
    if (mounted) setState(() {});
  }

  /// 계측용 자동 주행. 사람이 누르는 것과 같은 경로로 단계를 넘기며
  /// 프레임 시간을 재려고 쓴다. PERF_PROBE가 켜졌을 때만 돈다.
  Future<void> _autoDrive() async {
    Future<void> hold(int ms) =>
        Future<void>.delayed(Duration(milliseconds: ms));

    while (mounted) {
      PerfProbe.label = 'idle';
      await hold(3000);
      if (!mounted) return;
      _go(_Stage.intro);

      PerfProbe.label = 'intro';
      await hold(3000);
      if (!mounted) return;
      _go(_Stage.question);

      for (var i = 0; i < quizQuestions.length; i++) {
        PerfProbe.label = 'question';
        await hold(1400);
        if (!mounted) return;
        await _select(quizQuestions[_step].options.first);
      }

      PerfProbe.label = 'transition';
      await hold(2600);
      PerfProbe.label = 'result';
      await hold(4000);
      if (!mounted) return;
      _reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    if (PerfProbe.enabled) unawaited(_autoDrive());
    // 화면을 넘길 때 처음 디코드하면 그 프레임이 밀린다. Idle에 머무는 동안
    // 미리 올려 둔다. 화면에 쓰는 디코드 크기와 맞춰 캐시를 재사용한다.
    for (final q in quizQuestions) {
      for (final o in q.options) {
        precacheImage(
          ResizeImage(AssetImage(o.imagePath), width: 224),
          context,
        );
      }
    }
    for (final r in dagwaResults.values) {
      precacheImage(AssetImage(r.imagePath), context);
    }
    StoreDirectionsSheet.precache(context);
  }

  @override
  void dispose() {
    _inventory.removeListener(_inventoryChanged);
    _idleTimer?.cancel();
    _stageMotion.dispose();
    _motion.dispose();
    _questionBodyMotion.dispose();
    _questionMotion.dispose();
    super.dispose();
  }

  void _bumpIdleTimer() {
    _idleTimer?.cancel();
    if (_stage == _Stage.idle) return;
    _idleTimer = Timer(_inactivity, _reset);
  }

  /// Fade out completely before replacing the child. Only ONE screen is
  /// mounted/painted at a time, so text and images never bleed through.
  Future<void> _change(VoidCallback update) => _fadeSwap(_motion, update);

  /// 질문 → 질문. 질문 블록만 순차 fade 한다.
  Future<void> _changeQuestion(VoidCallback update) =>
      _fadeSwap(_questionMotion, update);

  Future<void> _fadeSwap(
    AnimationController motion,
    VoidCallback update,
  ) async {
    final session = _session;
    setState(() => _busy = true);
    final reduced = MediaQuery.disableAnimationsOf(context);
    try {
      if (!reduced) await motion.reverse().orCancel;
      if (!mounted || session != _session) return;
      setState(update);
      _bumpIdleTimer();
      if (!reduced) await motion.forward().orCancel;
      if (mounted && session == _session) setState(() => _busy = false);
    } on TickerCanceled {
      // Reset/dispose owns the next screen; an old transition must not resume.
    }
  }

  void _clearAnswers() {
    _step = 0;
    _answers = List.filled(quizQuestions.length, null);
    _menuName = null;
    _error = null;
  }

  void _reset() {
    if (!mounted) return;
    _session++;
    _motion.stop();
    _motion.value = 1;
    _questionMotion.stop();
    _questionMotion.value = 1;
    setState(() {
      _clearAnswers();
      _stage = _Stage.idle;
      _busy = false;
      _admin = _AdminStage.closed;
    });
    _bumpIdleTimer();
  }

  Future<void> _go(_Stage stage) async {
    if (_busy) return;
    await _change(() => _stage = stage);
  }

  void _home() {
    if (_busy) return;
    _session++;
    unawaited(
      _change(() {
        _clearAnswers();
        _stage = _Stage.idle;
      }),
    );
  }

  void _restart() {
    if (_busy) return;
    _session++;
    unawaited(
      _change(() {
        _clearAnswers();
        _stage = _Stage.intro;
      }),
    );
  }

  Future<void> _select(QuizOption option) async {
    if (_busy || _stage != _Stage.question) return;
    final session = _session;
    setState(() {
      _busy = true;
      _error = null;
      _answers[_step] = option.title;
    });
    _bumpIdleTimer();
    // 선택 상태가 보일 만큼만 머물고, 전체 전환은 0.6초 안에 끝낸다.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted || session != _session) return;
    if (_step < quizQuestions.length - 1) {
      await _changeQuestion(() => _step++);
      return;
    }
    try {
      final menu = await _service.getRecommendation(
        _answers.map((a) => a ?? '').toList(),
        availableMenus: _inventory.value,
        weights: _adminSettings.weights,
      );
      if (!mounted || session != _session) return;
      if (!dagwaResults.containsKey(menu) || !_inventory.value.contains(menu)) {
        throw StateError('Unavailable menu');
      }
      await _change(() {
        _menuName = menu;
        _stage = _Stage.transition;
      });
    } catch (_) {
      if (!mounted || session != _session) return;
      setState(() {
        _busy = false;
        _error = tr(
          '추천을 완료하지 못했어요. 선택지를 눌러 다시 시도해주세요.',
          'We couldn’t finish your recommendation. Tap your choice to try again.',
          'おすすめを表示できませんでした。選択肢をタップしてもう一度お試しください。',
        );
      });
    }
  }

  void _back() {
    if (_busy) return;
    if (_step == 0) {
      unawaited(_go(_Stage.intro));
    } else {
      unawaited(
        _changeQuestion(() {
          _step--;
          _error = null;
        }),
      );
    }
  }

  void _openInventory() {
    if (_stage != _Stage.idle || _busy || _admin != _AdminStage.closed) return;
    setState(() => _admin = _AdminStage.pin);
  }

  void _unlockInventory() {
    if (_admin != _AdminStage.pin) return;
    setState(() => _admin = _AdminStage.open);
  }

  void _closeInventory() {
    if (_admin == _AdminStage.closed) return;
    setState(() => _admin = _AdminStage.closed);
  }

  @override
  Widget build(BuildContext context) {
    final stageTint = _stage == _Stage.result && _menuName != null
        ? toneFor(_menuName!).deep
        : AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: KioskCanvas(
        child: Listener(
          onPointerDown: (_) => _bumpIdleTimer(),
          onPointerMove: (_) => _bumpIdleTimer(),
          child: Stack(
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: stageTint),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : Motion.slow,
                  curve: Motion.curve,
                  builder: (context, tint, _) => AmbientField(tint: tint),
                ),
              ),
              // 홈페이지 시안과 같은 두 수채화 조각을 모든 단계에 고정한다.
              // 화면 콘텐츠와 함께 교체하지 않아 전환 중 위치가 흔들리지 않는다.
              const Positioned.fill(child: BloomBackdrop()),
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: _busy,
                  child: AnimatedBuilder(
                    animation: _stageMotion,
                    builder: (context, child) {
                      final value = _stageMotion.value;
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: Transform.scale(
                            scale: 0.988 + (0.012 * value),
                            alignment: Alignment.center,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: RepaintBoundary(
                      child: Stack(
                        children: [
                          Positioned.fill(child: _buildStage()),
                          if (_stage == _Stage.idle || _stage == _Stage.intro)
                            const Positioned(
                              right: 88,
                              top: 52,
                              child: LangToggle(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_admin == _AdminStage.pin)
                Positioned.fill(
                  child: AdminPinPad(
                    settings: _adminSettings,
                    onCancel: _closeInventory,
                    onDone: _unlockInventory,
                  ),
                ),
              if (_admin == _AdminStage.open)
                Positioned.fill(
                  child: AdminInventorySheet(
                    inventory: _inventory,
                    settings: _adminSettings,
                    onClose: _closeInventory,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.idle:
        return IdleScreen(
          key: const ValueKey('idle'),
          onStart: () => _go(_Stage.intro),
          onAdmin: _openInventory,
          availableMenus: _availableMenus,
        );
      case _Stage.intro:
        return IntroScreen(
          key: const ValueKey('intro'),
          onStart: () => _go(_Stage.question),
          onHome: _home,
          availableMenus: _availableMenus,
        );
      case _Stage.question:
        return QuestionScreen(
          // 질문 데이터는 전체 화면이 사라진 뒤 교체한다.
          key: const ValueKey('question'),
          index: _step,
          question: quizQuestions[_step],
          selected: _answers[_step],
          error: _error,
          bodyMotion: _questionBodyMotion,
          onSelect: _select,
          onBack: _back,
          onHome: _home,
        );
      case _Stage.transition:
        return TransitionScreen(
          key: const ValueKey('transition'),
          menuName: _menuName!,
          onDone: () => _go(_Stage.result),
        );
      case _Stage.result:
        return ResultScreen(
          key: const ValueKey('result'),
          menuName: _menuName!,
          onRestart: _restart,
          onHome: _home,
        );
    }
  }
}
