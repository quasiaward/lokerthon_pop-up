import 'dart:async';

import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../perf_probe.dart';
import '../data/quiz_questions.dart';
import '../screens/idle_screen.dart';
import '../screens/intro_screen.dart';
import '../screens/question_screen.dart';
import '../screens/result_screen.dart';
import '../screens/transition_screen.dart';
import '../services/recommendation_engine.dart';
import '../services/recommendation_service.dart';
import '../theme/app_colors.dart';
import '../widgets/kiosk/ambient_field.dart';
import '../widgets/kiosk/kiosk_canvas.dart';
import '../widgets/lang_toggle.dart';

enum _Stage { idle, intro, question, transition, result }

/// 팝업 부스 키오스크의 단일 화면. 단계 전환만 관리한다.
class KioskPage extends StatefulWidget {
  const KioskPage({super.key});

  @override
  State<KioskPage> createState() => _KioskPageState();
}

class _KioskPageState extends State<KioskPage> {
  /// 앞 사용자의 결과가 남아 있지 않도록 무동작이 이어지면 Idle로 돌아간다.
  static const _inactivity = Duration(seconds: 45);

  final _service = RecommendationService();

  /// 디자인 확인용 진입 단계. `--dart-define=KIOSK_STAGE=result` 처럼 지정하면
  /// 해당 화면에서 바로 시작한다. 지정하지 않으면 늘 idle에서 시작한다.
  static const _debugStage = String.fromEnvironment('KIOSK_STAGE');

  late _Stage _stage = _initialStage();
  int _step = 0;
  late List<String?> _answers = List.filled(quizQuestions.length, null);
  late String? _menuName = _debugStage.isEmpty ? null : dagwaMenus.first;
  Timer? _idleTimer;

  _Stage _initialStage() => switch (_debugStage) {
    'intro' => _Stage.intro,
    'question' => _Stage.question,
    'transition' => _Stage.transition,
    'result' => _Stage.result,
    _ => _Stage.idle,
  };

  bool _precached = false;

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
    // 미리 올려 둔다. 에셋이 모두 작아서 전부 합쳐도 몇 MB 수준이다.
    for (final q in quizQuestions) {
      for (final o in q.options) {
        precacheImage(AssetImage(o.imagePath), context);
      }
    }
    for (final r in dagwaResults.values) {
      precacheImage(AssetImage(r.imagePath), context);
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _bumpIdleTimer() {
    _idleTimer?.cancel();
    if (_stage == _Stage.idle) return;
    _idleTimer = Timer(_inactivity, _reset);
  }

  void _reset() {
    if (!mounted) return;
    setState(() {
      _stage = _Stage.idle;
      _step = 0;
      _answers = List.filled(quizQuestions.length, null);
      _menuName = null;
    });
    _bumpIdleTimer();
  }

  void _go(_Stage stage) {
    setState(() => _stage = stage);
    _bumpIdleTimer();
  }

  void _restart() {
    setState(() {
      _step = 0;
      _answers = List.filled(quizQuestions.length, null);
      _menuName = null;
      _stage = _Stage.intro;
    });
    _bumpIdleTimer();
  }

  Future<void> _select(QuizOption option) async {
    setState(() => _answers[_step] = option.title);
    _bumpIdleTimer();

    // 선택이 눈에 보이도록 잠깐 머문 뒤 넘어간다.
    await Future<void>.delayed(const Duration(milliseconds: 340));
    if (!mounted) return;

    if (_step < quizQuestions.length - 1) {
      setState(() => _step++);
      _bumpIdleTimer();
      return;
    }

    final answers = _answers.map((a) => a ?? '').toList();
    final menu = await _service.getRecommendation(answers);
    if (!mounted) return;
    setState(() {
      _menuName = menu;
      _stage = _Stage.transition;
    });
    _bumpIdleTimer();
  }

  void _back() {
    if (_step == 0) {
      _go(_Stage.intro);
    } else {
      setState(() => _step--);
      _bumpIdleTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surround,
      body: KioskCanvas(
        child: Listener(
          onPointerDown: (_) => _bumpIdleTimer(),
          child: Stack(
            children: [
              Positioned.fill(
                child: AmbientField(key: ValueKey(_stage == _Stage.result)),
              ),
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: Motion.slow,
                  switchInCurve: Motion.curve,
                  switchOutCurve: Motion.curve,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _buildStage(),
                ),
              ),
              // 언어 전환은 체험을 시작하기 전에만 보여준다. 질문·결과 화면에서는
              // 진행 표시·상단 컨트롤과 자리를 다투고 흐름도 끊는다.
              if (_stage == _Stage.idle || _stage == _Stage.intro)
                const Positioned(
                  right: 88,
                  top: 56,
                  child: Opacity(opacity: 0.75, child: LangToggle()),
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
        );
      case _Stage.intro:
        return IntroScreen(
          key: const ValueKey('intro'),
          onStart: () => _go(_Stage.question),
          onHome: _reset,
        );
      case _Stage.question:
        return QuestionScreen(
          // 단계마다 화면을 갈아끼우면 두 벌이 동시에 그려져 프레임이 밀린다.
          // 화면은 그대로 두고 QuestionScreen 안에서 내용만 전환한다.
          key: const ValueKey('question'),
          index: _step,
          question: quizQuestions[_step],
          selected: _answers[_step],
          onSelect: _select,
          onBack: _back,
          onHome: _reset,
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
          onHome: _reset,
        );
    }
  }
}
