import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/lang.dart';
import '../models/recommendation.dart';
import '../services/recommendation_service.dart';
import 'watercolor_deco.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

// ── Quiz data ──────────────────────────────────────────────────────────────────

class _QuizOption {
  const _QuizOption({
    required this.title,
    required this.titleEn,
    required this.subtitle,
    required this.subtitleEn,
    required this.bgColor,
    required this.imagePath,
  });
  final String title; // 로직 키(영어 표시는 titleEn 사용)
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final Color bgColor;
  final String imagePath;
}

class _QuizQ {
  const _QuizQ({
    required this.before,
    required this.beforeEn,
    required this.keyword,
    required this.keywordEn,
    required this.after,
    required this.afterEn,
    required this.hint,
    required this.hintEn,
    required this.options,
  });
  final String before;
  final String beforeEn;
  final String keyword;
  final String keywordEn;
  final String after;
  final String afterEn;
  final String hint;
  final String hintEn;
  final List<_QuizOption> options;
}

const _pinkBg = Color(0xFFFCE4EC);
const _tealBg = Color(0xFFE0F2F1);
const _yellowBg = Color(0xFFFFF8E1);
const _inkBg = Color(0xFFECEFF1);

const _questions = [
  _QuizQ(
    before: '오늘 당신의 ',
    beforeEn: 'What color is your ',
    keyword: '기분',
    keywordEn: 'mood',
    after: '은 어떤 색인가요?',
    afterEn: ' today?',
    hint: '지금 가장 이끌리는 색감을 골라주세요.',
    hintEn: 'Pick the color you\'re drawn to right now.',
    options: [
      _QuizOption(
        title: '매화 분홍',
        titleEn: 'Plum Blossom Pink',
        subtitle: '설레고 따뜻한 매화의 온기',
        subtitleEn: 'The fluttery warmth of plum blossoms',
        bgColor: _pinkBg,
        imagePath: 'assets/figma/quiz/q1_c1_pink.jpg',
      ),
      _QuizOption(
        title: '소나무 청록',
        titleEn: 'Pine Teal',
        subtitle: '차분하고 싱그러운 솔바람',
        subtitleEn: 'A calm, fresh pine breeze',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/q1_c2_teal.jpg',
      ),
      _QuizOption(
        title: '유자 노랑',
        titleEn: 'Yuzu Yellow',
        subtitle: '생기 있고 달콤한 유자의 향',
        subtitleEn: 'Lively, sweet yuzu scent',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/q1_c3_yellow.jpg',
      ),
      _QuizOption(
        title: '먹색',
        titleEn: 'Ink Black',
        subtitle: '깊고 단단한 전통의 무게',
        subtitleEn: 'The deep, solid weight of tradition',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/q1_c4_ink.jpg',
      ),
    ],
  ),
  _QuizQ(
    before: '오늘 마음의 ',
    beforeEn: 'What\'s the ',
    keyword: '날씨',
    keywordEn: 'weather',
    after: '는 어떤가요?',
    afterEn: ' in your heart today?',
    hint: '지금 가장 이끌리는 날씨를 골라주세요.',
    hintEn: 'Pick the weather you\'re drawn to right now.',
    options: [
      _QuizOption(
        title: '맑고 활기참',
        titleEn: 'Sunny & lively',
        subtitle: '설레고 따뜻한 햇빛의 온기',
        subtitleEn: 'The warm glow of bright sunshine',
        bgColor: _pinkBg,
        imagePath: 'assets/figma/quiz/q2_c1_sunny.jpg',
      ),
      _QuizOption(
        title: '흐리고 지침',
        titleEn: 'Cloudy & weary',
        subtitle: '차분하고 조용한 쉬고픈 날',
        subtitleEn: 'A calm, quiet day for rest',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/q2_c2_rainy.jpg',
      ),
      _QuizOption(
        title: '잔잔하고 평온',
        titleEn: 'Calm & peaceful',
        subtitle: '생기 있고 달콤한 유자의 향',
        subtitleEn: 'Gentle and serene',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/q2_c3_calm.jpg',
      ),
      _QuizOption(
        title: '설레고 두근거려요',
        titleEn: 'Fluttery & excited',
        subtitle: '깊고 단단한 전통의 무게',
        subtitleEn: 'Heart racing with anticipation',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/q2_c4_excited.jpg',
      ),
    ],
  ),
  _QuizQ(
    before: '오늘 이 자리, ',
    beforeEn: 'Who are you ',
    keyword: '누구',
    keywordEn: 'with',
    after: '와 함께 하셨나요?',
    afterEn: ' here today?',
    hint: '함께하고 싶은 누군가를 선택해주세요.',
    hintEn: 'Choose someone you\'d like to be with.',
    options: [
      _QuizOption(
        title: '소중한 사람',
        titleEn: 'A loved one',
        subtitle: '따뜻하고 늘 곁에 있어주는 사람',
        subtitleEn: 'Warm, always by your side',
        bgColor: _pinkBg,
        imagePath: 'assets/figma/quiz/q3_c1_loved.jpg',
      ),
      _QuizOption(
        title: '혼자',
        titleEn: 'Alone',
        subtitle: '온전한 나와의 시간',
        subtitleEn: 'Time fully your own',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/q3_c2_alone.jpg',
      ),
      _QuizOption(
        title: '가족',
        titleEn: 'Family',
        subtitle: '평생 함께 있어줄 동반자',
        subtitleEn: 'Lifelong companions',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/q3_c3_family.jpg',
      ),
      _QuizOption(
        title: '친구',
        titleEn: 'Friends',
        subtitle: '깊고 단단한 우정',
        subtitleEn: 'Deep, steady friendship',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/q3_c4_friend.jpg',
      ),
    ],
  ),
  _QuizQ(
    before: '오늘 어떤 ',
    beforeEn: 'Which ',
    keyword: '식감',
    keywordEn: 'texture',
    after: '이 지금 당신을 달래줄 것 같나요?',
    afterEn: ' would soothe you right now?',
    hint: '지금 가장 이끌리는 식감을 골라주세요.',
    hintEn: 'Pick the texture you\'re drawn to right now.',
    options: [
      _QuizOption(
        title: '부드러운',
        titleEn: 'Soft',
        subtitle: '입안에서 부드럽게 녹아내리는 식감',
        subtitleEn: 'Melts softly in your mouth',
        bgColor: _pinkBg,
        imagePath: 'assets/figma/quiz/q4_c1_soft.jpg',
      ),
      _QuizOption(
        title: '바삭한',
        titleEn: 'Crisp',
        subtitle: '가볍게 부서지는 즐거움',
        subtitleEn: 'The joy of a light, crisp bite',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/q4_c2_crispy.jpg',
      ),
      _QuizOption(
        title: '쫀득한',
        titleEn: 'Chewy',
        subtitle: '천천히 오래 남는 만족감',
        subtitleEn: 'Slow, lingering satisfaction',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/q4_c3_chewy.jpg',
      ),
      _QuizOption(
        title: '촉촉한',
        titleEn: 'Moist',
        subtitle: '촉촉하고 은은한 식감',
        subtitleEn: 'Moist with a gentle finish',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/q4_c4_moist.jpg',
      ),
    ],
  ),
  _QuizQ(
    before: '지금 이 순간 어떤 ',
    beforeEn: 'Which ',
    keyword: '계절',
    keywordEn: 'season',
    after: '이 느껴지시나요?',
    afterEn: ' do you feel right now?',
    hint: '지금 가장 이끌리는 계절을 골라주세요.',
    hintEn: 'Pick the season you\'re drawn to right now.',
    options: [
      _QuizOption(
        title: '봄',
        titleEn: 'Spring',
        subtitle: '설레고 부드러운 꽃향기의 시작',
        subtitleEn: 'The soft, fluttery start of blossoms',
        bgColor: _pinkBg,
        imagePath: 'assets/figma/quiz/q5_c1_spring.jpg',
      ),
      _QuizOption(
        title: '여름',
        titleEn: 'Summer',
        subtitle: '싱그럽고 생기 넘치는 계절의 온기',
        subtitleEn: 'Fresh, vivid summer warmth',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/q5_c2_summer.jpg',
      ),
      _QuizOption(
        title: '가을',
        titleEn: 'Autumn',
        subtitle: '깊어지는 향과 차분한 여운',
        subtitleEn: 'Deepening aromas and a calm afterglow',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/q5_c3_autumn.jpg',
      ),
      _QuizOption(
        title: '겨울',
        titleEn: 'Winter',
        subtitle: '고요하고 포근한 휴식의 시간',
        subtitleEn: 'A still, cozy time of rest',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/q5_c4_winter.jpg',
      ),
    ],
  ),
  _QuizQ(
    before: '어떤 ',
    beforeEn: 'Which ',
    keyword: '모양',
    keywordEn: 'shape',
    after: '이 눈길을 끄시나요?',
    afterEn: ' catches your eye?',
    hint: '지금 가장 이끌리는 모양을 골라주세요.',
    hintEn: 'Pick the shape you\'re drawn to right now.',
    options: [
      _QuizOption(
        title: '둥근 모양',
        titleEn: 'Round',
        subtitle: '부드럽고 포근한 안정감',
        subtitleEn: 'Soft, cozy reassurance',
        bgColor: _pinkBg,
        imagePath: 'assets/figma/quiz/q6_c1_round.jpg',
      ),
      _QuizOption(
        title: '물결 모양',
        titleEn: 'Wavy',
        subtitle: '자연스럽고 유연한 움직임',
        subtitleEn: 'Natural, flowing movement',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/q6_c2_wave.jpg',
      ),
      _QuizOption(
        title: '직선 모양',
        titleEn: 'Linear',
        subtitle: '정돈되고 균형 잡힌 아름다움',
        subtitleEn: 'Tidy, balanced beauty',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/q6_c3_linear.jpg',
      ),
      _QuizOption(
        title: '별·꽃 모양',
        titleEn: 'Star or flower',
        subtitle: '개성과 경험이 담긴 모양',
        subtitleEn: 'A shape full of character and story',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/q6_c4_star.jpg',
      ),
    ],
  ),
];

RecommendationInput _buildInput(List<String?> answers) {
  final personality = switch (answers[0]) {
    '매화 분홍' => '차분히 음미하는 감각형',
    '소나무 청록' => '조용히 머무는 I형',
    '유자 노랑' => '같이 나누는 E형',
    '먹색' => '이야기와 의미를 좋아하는 직관형',
    _ => personalityTypes[0],
  };
  final moment = switch (answers[1]) {
    '맑고 활기참' => '친구와 디저트를 먹어요',
    '흐리고 지침' => '혼자 쉬고 싶어요',
    '잔잔하고 평온' => '부모님과 함께해요',
    '설레고 두근거려요' => '수원 여행 기념이에요',
    _ => visitMoments[0],
  };
  final tea = switch (answers[2]) {
    '소중한 사람' => '따뜻한 차와 함께',
    '혼자' => '한방차처럼 깊게',
    '가족' => '따뜻한 차와 함께',
    '친구' => '상큼하고 산뜻하게',
    _ => teaPreferences[0],
  };
  final texture = switch (answers[3]) {
    '부드러운' => '부드럽고 촉촉한 식감',
    '바삭한' => '바삭하고 결 있는 식감',
    '쫀득한' => '쫀득한 떡 식감',
    '촉촉한' => '부드럽고 촉촉한 식감',
    _ => texturePreferences[0],
  };
  final sweetness = switch (answers[4]) {
    '봄' => '은은하고 담백한 단맛',
    '여름' => '확실히 달콤한 맛',
    '가을' => '적당히 달콤한 맛',
    '겨울' => '쌉싸름하고 깊은 맛',
    _ => sweetnessPreferences[0],
  };
  final choiceStyle = switch (answers[5]) {
    '둥근 모양' => '익숙하고 안정적인 메뉴',
    '물결 모양' => '새로운 메뉴도 좋아함',
    '직선 모양' => '대표 메뉴를 고르는 편',
    '별·꽃 모양' => '보기 좋은 메뉴가 좋음',
    _ => choiceStyles[0],
  };
  return RecommendationInput(
    personality: personality,
    moment: moment,
    sweetness: sweetness,
    texture: texture,
    tea: tea,
    choiceStyle: choiceStyle,
    situation: '',
  );
}

enum _Phase { landing, quiz, result }

// ── Main widget ────────────────────────────────────────────────────────────────

class AIRecommendationSection extends StatefulWidget {
  const AIRecommendationSection({super.key});

  @override
  State<AIRecommendationSection> createState() =>
      _AIRecommendationSectionState();
}

class _AIRecommendationSectionState extends State<AIRecommendationSection> {
  final _service = RecommendationService();
  _Phase _phase = _Phase.landing;
  int _step = 0;
  final _answers = <String?>[null, null, null, null, null, null];
  RecommendationResult? _result;

  void _start() => setState(() {
    _phase = _Phase.quiz;
    _step = 0;
    for (var i = 0; i < _answers.length; i++) {
      _answers[i] = null;
    }
    _result = null;
  });

  void _pick(String title) {
    _answers[_step] = title;
    if (_step < _questions.length - 1) {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => mounted ? setState(() => _step++) : null,
      );
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() {
          _result = _service.getRecommendation(_buildInput(_answers));
          _phase = _Phase.result;
        });
      });
    }
  }

  void _back() => setState(() => _step--);

  void _skip() {
    if (_step < _questions.length - 1) {
      setState(() => _step++);
    } else {
      setState(() {
        _result = _service.getRecommendation(_buildInput(_answers));
        _phase = _Phase.result;
      });
    }
  }

  void _restart() => setState(() {
    _phase = _Phase.landing;
    for (var i = 0; i < _answers.length; i++) {
      _answers[i] = null;
    }
    _result = null;
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: switch (_phase) {
        _Phase.landing => _LandingView(
          key: const ValueKey('landing'),
          onStart: _start,
        ),
        _Phase.quiz => _QuizView(
          key: ValueKey('quiz-$_step'),
          step: _step,
          question: _questions[_step],
          selected: _answers[_step],
          onPick: _pick,
          onBack: _step > 0 ? _back : null,
          onSkip: _skip,
          isLast: _step == _questions.length - 1,
        ),
        _Phase.result => _ResultView(
          key: const ValueKey('result'),
          result: _result!,
          onHome: _restart,
        ),
      },
    );
  }
}

// ── Landing ────────────────────────────────────────────────────────────────────

const _previewCards = [
  (
    subtitle: '겉바속촉 MZ',
    subtitleEn: 'Crisp-outside, soft-inside',
    title: '행궁약과',
    titleEn: 'Haenggung Yakgwa',
    image: 'assets/figma/recommend_yakgwa.png',
  ),
  (
    subtitle: '다섯잎 매력둥이',
    subtitleEn: 'Five-petal charmer',
    title: '진달래 화전',
    titleEn: 'Azalea Hwajeon',
    image: 'assets/figma/recommend_hwajeon.png',
  ),
  (
    subtitle: '말랑콩떡 사랑둥이',
    subtitleEn: 'Soft & sweet sweetheart',
    title: '송편',
    titleEn: 'Songpyeon',
    image: 'assets/figma/recommend_songpyeon.png',
  ),
];

class _LandingView extends StatelessWidget {
  const _LandingView({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    return Container(
      color: const Color(0xFFFCF7F5),
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  tr('나만의 다과 추천', 'Find Your Dagwa'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF534344),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 64),
                if (isWide)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _previewCards.length; i++) ...[
                        Expanded(child: _PreviewCard(card: _previewCards[i])),
                        if (i != _previewCards.length - 1)
                          const SizedBox(width: 32),
                      ],
                    ],
                  )
                else
                  Column(
                    children: [
                      for (final card in _previewCards) ...[
                        _PreviewCard(card: card),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                const SizedBox(height: 54),
                FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF934753),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 60),
                    padding: const EdgeInsets.symmetric(horizontal: 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 4,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tr('오늘의 다과 추천 받으러 가기', 'Get today\'s dagwa pick'),
                      style: const TextStyle(
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 60 / 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.card});
  final ({
    String subtitle,
    String subtitleEn,
    String title,
    String titleEn,
    String image,
  })
  card;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 314),
      height: 458,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE7A9A0).withValues(alpha: 0.55),
            blurRadius: 31,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            tr(card.subtitle, card.subtitleEn),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9A9285),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr(card.title, card.titleEn),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 258,
            height: 258,
            child: Image.asset(card.image, fit: BoxFit.contain),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Quiz ───────────────────────────────────────────────────────────────────────

class _QuizView extends StatelessWidget {
  const _QuizView({
    super.key,
    required this.step,
    required this.question,
    required this.selected,
    required this.onPick,
    this.onBack,
    required this.onSkip,
    required this.isLast,
  });

  final int step;
  final _QuizQ question;
  final String? selected;
  final ValueChanged<String> onPick;
  final VoidCallback? onBack;
  final VoidCallback onSkip;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final totalSteps = _questions.length;
    final pct = (step / totalSteps * 100).round();
    final isWide = MediaQuery.sizeOf(context).width >= 1100;
    final deco = decoScaleOf(context, designWidth: 1409);

    return Container(
      color: const Color(0xFFFCF7F5),
      constraints: const BoxConstraints(minHeight: 700),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 45 * deco,
            bottom: 0,
            child: WatercolorDeco(decoQuizPink, width: 525 * deco),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: WatercolorDeco(decoQuizBlob, width: 422 * deco),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Progress indicator
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 672),
                        child: _ProgressBar(
                          step: step,
                          totalSteps: totalSteps,
                          pct: pct,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Question header
                      _QuestionHeader(question: question),
                      const SizedBox(height: 48),

                      // Card grid
                      if (isWide)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (
                              var i = 0;
                              i < question.options.length;
                              i++
                            ) ...[
                              SizedBox(
                                width: 244,
                                child: _OptionCard(
                                  option: question.options[i],
                                  selected:
                                      selected == question.options[i].title,
                                  onTap: () =>
                                      onPick(question.options[i].title),
                                ),
                              ),
                              if (i < question.options.length - 1)
                                const SizedBox(width: 16),
                            ],
                          ],
                        )
                      else
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final opt in question.options)
                              SizedBox(
                                width: 200,
                                child: _OptionCard(
                                  option: opt,
                                  selected: selected == opt.title,
                                  onTap: () => onPick(opt.title),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 48),

                      // Navigation
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1024),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (onBack != null)
                              TextButton.icon(
                                onPressed: onBack,
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 14,
                                ),
                                label: Text(tr('이전 질문', 'Previous')),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF534344),
                                  textStyle: const TextStyle(
                                    fontFamily: 'Gowun Batang',
                                    fontFamilyFallback: _serifFallback,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 100),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: onSkip,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF566341),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: 'Gowun Batang',
                                      fontFamilyFallback: _serifFallback,
                                      fontSize: 14,
                                    ),
                                  ),
                                  child: Text(tr('건너뛰기', 'Skip')),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: selected != null
                                      ? () => onPick(selected!)
                                      : onSkip,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF934753),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 1,
                                  ),
                                  child: Text(
                                    isLast
                                        ? tr('취향 분석하기', 'Analyze my taste')
                                        : tr('다음 단계', 'Next'),
                                    style: const TextStyle(
                                      fontFamily: 'Gowun Batang',
                                      fontFamilyFallback: _serifFallback,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.step,
    required this.totalSteps,
    required this.pct,
  });
  final int step;
  final int totalSteps;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('$totalSteps개 중 ${step + 1}번째 질문',
                  'Question ${step + 1} of $totalSteps'),
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 14,
                letterSpacing: 0.14,
              ),
            ),
            Text(
              tr('$pct% 완료', '$pct% done'),
              style: const TextStyle(
                color: Color(0xFF934753),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: step / totalSteps,
            backgroundColor: const Color(0xFFE5E2DC),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFD9808C)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({required this.question});
  final _QuizQ question;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'ATMOSPHERIC SELECTION',
          style: TextStyle(
            color: Color(0xFFBECCA3),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              tr(question.before, question.beforeEn),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1C1C18),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 48,
                height: 1.17,
              ),
            ),
            _KeywordText(keyword: tr(question.keyword, question.keywordEn)),
            Text(
              tr(question.after, question.afterEn),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1C1C18),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 48,
                height: 1.17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          tr(question.hint, question.hintEn),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF534344),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 18,
            height: 1.56,
          ),
        ),
      ],
    );
  }
}

class _KeywordText extends StatelessWidget {
  const _KeywordText({required this.keyword});
  final String keyword;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 2,
          left: 4,
          right: 0,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFD9808C).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Text(
          keyword,
          style: const TextStyle(
            color: Color(0xFF934753),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 48,
            height: 1.17,
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatefulWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });
  final _QuizOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _hovered = false;

  Color get _gradientStart {
    if (widget.option.bgColor == _pinkBg) return const Color(0xFFD9808C);
    if (widget.option.bgColor == _tealBg) return const Color(0xFFD7E5BA);
    if (widget.option.bgColor == _yellowBg) return const Color(0xFFBF923A);
    return const Color(0xFF867274);
  }

  Color get _cardBg {
    if (widget.selected) return widget.option.bgColor.withValues(alpha: 0.28);
    if (_hovered) return widget.option.bgColor.withValues(alpha: 0.13);
    return Colors.white;
  }

  Color get _borderColor {
    if (widget.selected) return const Color(0xFF934753);
    if (_hovered) return const Color(0xFF934753).withValues(alpha: 0.45);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 320,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.selected
                    ? const Color(0xFF934753).withValues(alpha: 0.18)
                    : _hovered
                    ? const Color(0xFF934753).withValues(alpha: 0.10)
                    : const Color(0xFF934753).withValues(alpha: 0.05),
                blurRadius: widget.selected ? 14 : (_hovered ? 8 : 2),
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: widget.option.bgColor,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  _gradientStart.withValues(alpha: 0.2),
                                  _gradientStart.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          Image.asset(
                            widget.option.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 2),
                child: Text(
                  tr(widget.option.title, widget.option.titleEn),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.selected
                        ? const Color(0xFF934753)
                        : const Color(0xFF1C1C18),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 20,
                    fontWeight: widget.selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  tr(widget.option.subtitle, widget.option.subtitleEn),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF534344),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Result ─────────────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({super.key, required this.result, required this.onHome});
  final RecommendationResult result;
  final VoidCallback onHome;

  String get _imagePath {
    if (result.productName.contains('화전')) {
      return 'assets/figma/recommend_hwajeon.png';
    }
    if (result.productName.contains('송편')) {
      return 'assets/figma/recommend_songpyeon.png';
    }
    if (result.productName.contains('빙수')) {
      return 'assets/figma/menu_green_bingsu.png';
    }
    return 'assets/figma/recommend_yakgwa.png';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 780;

    return Container(
      color: const Color(0xFFDDDAD9),
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1030),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isWide ? 34 : 22,
                isWide ? 30 : 24,
                isWide ? 34 : 22,
                isWide ? 28 : 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEFAF9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.11),
                    blurRadius: 26,
                    spreadRadius: -4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      tr('취향 분석 결과', 'Your taste result'),
                      style: const TextStyle(
                        color: Color(0xFF8F7E7B),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: isWide ? 250 : 210,
                    height: isWide ? 250 : 210,
                    child: Image.asset(_imagePath, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    tr('당신은 ${result.profileTitle}의 매력을 가진 ${result.productName}!',
                        'You\'re ${result.productNameEn} with the charm of ${result.profileTitleEn}!'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF633B3A),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      tr(result.aiSummary, result.aiSummaryEn),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8C7E7B),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 17,
                        height: 1.78,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  if (isWide)
                    Row(
                      children: [
                        Expanded(
                          child: _PairingBox(
                            label: tr('함께 어울리는 메뉴/차', 'Pairs well with'),
                            value: tr(result.teaPairing, result.teaPairingEn),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _PairingBox(
                            label: tr('차선 추천', 'Runner-up'),
                            value: tr(result.secondaryMenuName,
                                result.secondaryMenuNameEn),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _PairingBox(
                          label: tr('함께 어울리는 메뉴/차', 'Pairs well with'),
                          value: tr(result.teaPairing, result.teaPairingEn),
                        ),
                        const SizedBox(height: 12),
                        _PairingBox(
                          label: tr('차선 추천', 'Runner-up'),
                          value: tr(result.secondaryMenuName,
                              result.secondaryMenuNameEn),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  _ResultActions(
                    onRetry: onHome,
                    onBuy: () =>
                        Navigator.pushReplacementNamed(context, '/menu'),
                    onShare: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: tr(
                              '행궁다과 추천 결과: ${result.profileTitle} - ${result.productName}',
                              'Haenggung Dagwa result: ${result.profileTitleEn} - ${result.productNameEn}'),
                        ),
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                              content: Text(tr('추천 결과를 복사했어요.',
                                  'Result copied to clipboard.'))),
                        );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.onRetry,
    required this.onBuy,
    required this.onShare,
  });

  final VoidCallback onRetry;
  final VoidCallback onBuy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    final retry = TextButton(
      onPressed: onRetry,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF8C7E7B),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: 'Gowun Batang',
          fontFamilyFallback: _serifFallback,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(tr('다시 분석하기', 'Try again')),
    );

    final buy = FilledButton(
      onPressed: onBuy,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF9B4A59),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        tr('구매하러 가기', 'Shop now'),
        style: const TextStyle(
          fontFamily: 'Gowun Batang',
          fontFamilyFallback: _serifFallback,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final share = FilledButton(
      onPressed: onShare,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFDEDDC9),
        foregroundColor: const Color(0xFF534344),
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        tr('친구한테 공유하기', 'Share with a friend'),
        style: const TextStyle(
          fontFamily: 'Gowun Batang',
          fontFamilyFallback: _serifFallback,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          retry,
          const SizedBox(height: 10),
          buy,
          const SizedBox(height: 10),
          share,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: retry),
        const SizedBox(width: 24),
        buy,
        const SizedBox(width: 12),
        share,
      ],
    );
  }
}

class _PairingBox extends StatelessWidget {
  const _PairingBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECEC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5F5552),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC85F65),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
