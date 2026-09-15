import 'dart:async';

import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
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
import '../l10n/lang.dart';
import '../widgets/kiosk/ambient_field.dart';
import '../widgets/kiosk/kiosk_canvas.dart';
import '../widgets/lang_toggle.dart';

enum _Stage { idle, intro, question, transition, result }

/// 팝업 부스 키오스크의 단일 화면. 단계 전환만 관리한다.
class KioskPage extends StatefulWidget {
  const KioskPage({super.key, this.service});

  final RecommendationService? service;

  @override
  State<KioskPage> createState() => _KioskPageState();
}

class _KioskPageState extends State<KioskPage>
    with SingleTickerProviderStateMixin {
  /// 앞 사용자의 결과가 남아 있지 않도록 무동작이 이어지면 Idle로 돌아간다.
  static const _inactivity = Duration(seconds: 45);

  late final _service = widget.service ?? RecommendationService();
  late final _motion = AnimationController(
    vsync: this,
    value: 1,
    duration: Motion.base,
    reverseDuration: Motion.exit,
  );
  late final _opacity = CurvedAnimation(parent: _motion, curve: Motion.curve);
  bool _busy = false;
  int _session = 0;
  String? _error;

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
        precacheImage(
          ResizeImage(AssetImage(o.imagePath), width: 216),
          context,
        );
      }
    }
    for (final r in dagwaResults.values) {
      precacheImage(AssetImage(r.imagePath), context);
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _opacity.dispose();
    _motion.dispose();
    super.dispose();
  }

  void _bumpIdleTimer() {
    _idleTimer?.cancel();
    if (_stage == _Stage.idle) return;
    _idleTimer = Timer(_inactivity, _reset);
  }

  /// Fade out completely before replacing the child. Only ONE screen is
  /// mounted/painted at a time, so text and images never bleed through.
  Future<void> _change(VoidCallback update) async {
    final session = _session;
    setState(() => _busy = true);
    final reduced = MediaQuery.disableAnimationsOf(context);
    try {
      if (!reduced) await _motion.reverse().orCancel;
      if (!mounted || session != _session) return;
      setState(update);
      _bumpIdleTimer();
      if (!reduced) await _motion.forward().orCancel;
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
    setState(() {
      _clearAnswers();
      _stage = _Stage.idle;
      _busy = false;
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
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (!mounted || session != _session) return;
    if (_step < quizQuestions.length - 1) {
      await _change(() => _step++);
      return;
    }
    try {
      final menu = await _service.getRecommendation(
        _answers.map((a) => a ?? '').toList(),
      );
      if (!mounted || session != _session) return;
      if (!dagwaResults.containsKey(menu)) throw StateError('Unknown menu');
      await _change(() {
        _menuName = menu;
        _stage = _Stage.transition;
      });
    } catch (_) {
      if (!mounted || session != _session) return;
      setState(() {
        _busy = false;
        _error = tr(
          '연결이 원활하지 않아요. 선택지를 눌러 다시 시도해주세요.',
          'Could not connect. Tap your choice to try again.',
          '接続がうまくいきません。選択肢をタップしてもう一度お試しください。',
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
        _change(() {
          _step--;
          _error = null;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.ground,
    body: KioskCanvas(
      child: Listener(
        onPointerDown: (_) => _bumpIdleTimer(),
        onPointerMove: (_) => _bumpIdleTimer(),
        child: Stack(
          children: [
            Positioned.fill(
              child: AmbientField(
                tint: _stage == _Stage.result && _menuName != null
                    ? toneFor(_menuName!).deep
                    : AppColors.accent,
              ),
            ),
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: _busy,
                child: FadeTransition(
                  opacity: _opacity,
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
          ],
        ),
      ),
    ),
  );

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
          onHome: _home,
        );
      case _Stage.question:
        return QuestionScreen(
          // 질문 데이터는 전체 화면이 사라진 뒤 교체한다.
          key: const ValueKey('question'),
          index: _step,
          question: quizQuestions[_step],
          selected: _answers[_step],
          error: _error,
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
