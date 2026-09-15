import 'dart:async';

import 'package:flutter/material.dart';

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
          key: ValueKey('question-$_step'),
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
