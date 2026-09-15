import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/dagwa_results.dart';
import '../l10n/lang.dart';
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
    this.displayTitle,
    this.displayTitleEn,
    this.displaySubtitle,
    this.displaySubtitleEn,
    this.imageStyle = _QuizImageStyle.square,
    this.imageFit = BoxFit.cover,
  });
  final String title; // 로직 키(영어 표시는 titleEn 사용)
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final Color bgColor;
  final String imagePath;
  final String? displayTitle;
  final String? displayTitleEn;
  final String? displaySubtitle;
  final String? displaySubtitleEn;
  final _QuizImageStyle imageStyle;
  final BoxFit imageFit;
}

enum _QuizImageStyle { circle, square }

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
        imagePath: 'assets/figma/quiz/figma_q1_c1.png',
        displaySubtitle: '설레고 따뜻한 매화 분홍',
        displaySubtitleEn: 'A fluttering, warm plum pink',
        imageStyle: _QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      _QuizOption(
        title: '소나무 청록',
        titleEn: 'Pine Teal',
        subtitle: '차분하고 싱그러운 솔바람',
        subtitleEn: 'A calm, fresh pine breeze',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/figma_q1_c2.png',
        displaySubtitle: '활동적이고 상쾌한 청록색의 솔바람',
        displaySubtitleEn: 'An active, refreshing pine teal breeze',
        imageStyle: _QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      _QuizOption(
        title: '유자 노랑',
        titleEn: 'Yuzu Yellow',
        subtitle: '생기 있고 달콤한 유자의 향',
        subtitleEn: 'Lively, sweet yuzu scent',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/figma_q1_c3.png',
        displaySubtitle: '생기 있고 발랄한 유자 노랑',
        displaySubtitleEn: 'A bright and lively yuzu yellow',
        imageStyle: _QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      _QuizOption(
        title: '먹색',
        titleEn: 'Ink Black',
        subtitle: '깊고 단단한 전통의 무게',
        subtitleEn: 'The deep, solid weight of tradition',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/figma_q1_c4.png',
        displaySubtitle: '깊고 단단한 먹색의 무게',
        displaySubtitleEn: 'The deep, steady weight of ink black',
        imageStyle: _QuizImageStyle.circle,
        imageFit: BoxFit.contain,
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
        imagePath: 'assets/figma/quiz/figma_q2_c1.png',
        displaySubtitle: '에너지 가득, 생기 가득',
        displaySubtitleEn: 'Full of energy and liveliness',
      ),
      _QuizOption(
        title: '흐리고 지침',
        titleEn: 'Cloudy & weary',
        subtitle: '차분하고 조용한 쉬고픈 날',
        subtitleEn: 'A calm, quiet day for rest',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/figma_q2_c2.png',
        displaySubtitle: '잠시 쉬어갈 시간',
        displaySubtitleEn: 'A moment to pause and rest',
      ),
      _QuizOption(
        title: '잔잔하고 평온',
        titleEn: 'Calm & peaceful',
        subtitle: '생기 있고 달콤한 유자의 향',
        subtitleEn: 'Gentle and serene',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/figma_q2_c3.png',
        displayTitle: '선선하고 평온',
        displayTitleEn: 'Cool & peaceful',
        displaySubtitle: '마음의 안정과 평화',
        displaySubtitleEn: 'A quiet peace of mind',
      ),
      _QuizOption(
        title: '설레고 두근거려요',
        titleEn: 'Fluttery & excited',
        subtitle: '깊고 단단한 전통의 무게',
        subtitleEn: 'Heart racing with anticipation',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/figma_q2_c4.png',
        displayTitle: '따뜻하고 두근거림',
        displayTitleEn: 'Warm & fluttering',
        displaySubtitle: '새로운 시작의 설레임',
        displaySubtitleEn: 'The flutter of a new beginning',
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
        imagePath: 'assets/figma/quiz/figma_q3_c1.png',
      ),
      _QuizOption(
        title: '혼자',
        titleEn: 'Alone',
        subtitle: '온전한 나와의 시간',
        subtitleEn: 'Time fully your own',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/figma_q3_c2.png',
      ),
      _QuizOption(
        title: '가족',
        titleEn: 'Family',
        subtitle: '평생 함께 있어줄 동반자',
        subtitleEn: 'Lifelong companions',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/figma_q3_c3.png',
        displaySubtitle: '평생 함께 함께할 동반자',
        displaySubtitleEn: 'Lifelong companions by your side',
      ),
      _QuizOption(
        title: '친구',
        titleEn: 'Friends',
        subtitle: '깊고 단단한 우정',
        subtitleEn: 'Deep, steady friendship',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/figma_q3_c4.png',
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
        imagePath: 'assets/figma/quiz/figma_q4_c1.png',
      ),
      _QuizOption(
        title: '바삭한',
        titleEn: 'Crisp',
        subtitle: '가볍게 부서지는 즐거움',
        subtitleEn: 'The joy of a light, crisp bite',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/figma_q4_c2.png',
      ),
      _QuizOption(
        title: '쫀득한',
        titleEn: 'Chewy',
        subtitle: '천천히 오래 남는 만족감',
        subtitleEn: 'Slow, lingering satisfaction',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/figma_q4_c3.png',
      ),
      _QuizOption(
        title: '촉촉한',
        titleEn: 'Moist',
        subtitle: '촉촉하고 은은한 식감',
        subtitleEn: 'Moist with a gentle finish',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/figma_q4_c4.png',
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
        imagePath: 'assets/figma/quiz/figma_q5_c1.png',
      ),
      _QuizOption(
        title: '여름',
        titleEn: 'Summer',
        subtitle: '싱그럽고 생기 넘치는 계절의 온기',
        subtitleEn: 'Fresh, vivid summer warmth',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/figma_q5_c2.png',
      ),
      _QuizOption(
        title: '가을',
        titleEn: 'Autumn',
        subtitle: '깊어지는 향과 차분한 여운',
        subtitleEn: 'Deepening aromas and a calm afterglow',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/figma_q5_c3.png',
      ),
      _QuizOption(
        title: '겨울',
        titleEn: 'Winter',
        subtitle: '고요하고 포근한 휴식의 시간',
        subtitleEn: 'A still, cozy time of rest',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/figma_q5_c4.png',
      ),
    ],
  ),
  _QuizQ(
    before: '어떤 ',
    beforeEn: 'Which ',
    keyword: '문양',
    keywordEn: 'pattern',
    after: '이 눈길을 끄시나요?',
    afterEn: ' catches your eye?',
    hint: '지금 가장 이끌리는 문양을 골라주세요.',
    hintEn: 'Pick the pattern you\'re drawn to right now.',
    options: [
      _QuizOption(
        title: '둥근 모양',
        titleEn: 'Round',
        subtitle: '부드럽고 포근한 안정감',
        subtitleEn: 'Soft, cozy reassurance',
        bgColor: _pinkBg,
        imagePath: 'assets/figma/quiz/figma_q6_c1.png',
      ),
      _QuizOption(
        title: '물결 모양',
        titleEn: 'Wavy',
        subtitle: '자연스럽고 유연한 움직임',
        subtitleEn: 'Natural, flowing movement',
        bgColor: _tealBg,
        imagePath: 'assets/figma/quiz/figma_q6_c2.png',
        displayTitle: '물결 문양',
        displayTitleEn: 'Wave pattern',
      ),
      _QuizOption(
        title: '직선 모양',
        titleEn: 'Linear',
        subtitle: '정돈되고 균형 잡힌 아름다움',
        subtitleEn: 'Tidy, balanced beauty',
        bgColor: _yellowBg,
        imagePath: 'assets/figma/quiz/figma_q6_c3.png',
        displayTitle: '곧은 문양',
        displayTitleEn: 'Straight pattern',
      ),
      _QuizOption(
        title: '별·꽃 모양',
        titleEn: 'Star or flower',
        subtitle: '개성과 경험이 담긴 모양',
        subtitleEn: 'A shape full of character and story',
        bgColor: _inkBg,
        imagePath: 'assets/figma/quiz/figma_q6_c4.png',
        displayTitle: '별·꽃 문양',
        displayTitleEn: 'Star & flower pattern',
        displaySubtitle: '개성있고 창의적인 새로움',
        displaySubtitleEn: 'A creative, characterful newness',
      ),
    ],
  ),
];

enum _Phase { landing, quiz, loading, result, error }

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
  String? _menuName;
  String? _errorMessage;

  void _start() => setState(() {
    _phase = _Phase.quiz;
    _step = 0;
    for (var i = 0; i < _answers.length; i++) {
      _answers[i] = null;
    }
    _menuName = null;
    _errorMessage = null;
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
        _fetchRecommendation();
      });
    }
  }

  void _back() => setState(() => _step--);

  void _skip() {
    if (_step < _questions.length - 1) {
      setState(() => _step++);
    } else {
      _fetchRecommendation();
    }
  }

  /// 온디바이스 추천은 즉시 끝나서 "분석 중" 화면이 깜빡이고 사라진다.
  /// 최소 노출 시간을 줘서 분석하는 느낌을 유지한다.
  static const _minLoadingDuration = Duration(milliseconds: 1400);

  Future<void> _fetchRecommendation() async {
    setState(() => _phase = _Phase.loading);
    try {
      final answers = _answers.map((a) => a ?? '').toList();
      final results = await Future.wait([
        _service.getRecommendation(answers),
        Future<void>.delayed(_minLoadingDuration),
      ]);
      final menu = results.first as String;
      if (!mounted) return;
      setState(() {
        _menuName = menu;
        _errorMessage = null;
        _phase = _Phase.result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = tr(
          'API가 추천 결과를 주지 않았습니다.',
          'The API did not return a recommendation.',
        );
        _phase = _Phase.error;
      });
    }
  }

  void _restart() => setState(() {
    _phase = _Phase.landing;
    for (var i = 0; i < _answers.length; i++) {
      _answers[i] = null;
    }
    _menuName = null;
    _errorMessage = null;
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
        _Phase.loading => const _LoadingView(key: ValueKey('loading')),
        _Phase.result => _ResultView(
          key: const ValueKey('result'),
          menuName: _menuName!,
          onHome: _restart,
        ),
        _Phase.error => _RecommendationErrorView(
          key: const ValueKey('error'),
          message:
              _errorMessage ??
              tr(
                'API가 추천 결과를 주지 않았습니다.',
                'The API did not return a recommendation.',
              ),
          onRetry: _fetchRecommendation,
          onHome: _restart,
        ),
      },
    );
  }
}

// ── Landing ────────────────────────────────────────────────────────────────────

const _previewCards = [
  (
    subtitle: '언제나 든든해',
    subtitleEn: 'Always reliable',
    title: '영양찰떡',
    titleEn: 'Nutritious Rice Cake',
    image: 'assets/figma/recommend/nutrition_rice_cake.png',
  ),
  (
    subtitle: '은근한 반전 매력',
    subtitleEn: 'Subtle bittersweet charm',
    title: '도라지정과',
    titleEn: 'Bellflower Jeonggwa',
    image: 'assets/figma/recommend/bellflower_jeonggwa.png',
  ),
  (
    subtitle: '겉바속촉 MZ',
    subtitleEn: 'Modern crisp-soft',
    title: '수원약과',
    titleEn: 'Suwon Yakgwa',
    image: 'assets/figma/recommend/suwon_yakgwa.png',
  ),
  (
    subtitle: '고소함의 정석',
    subtitleEn: 'Nutty classic',
    title: '흑임자다식',
    titleEn: 'Black Sesame Dasik',
    image: 'assets/figma/recommend/black_sesame_dasik.png',
  ),
  (
    subtitle: '다과계의 브레인',
    subtitleEn: 'The thoughtful one',
    title: '곶감 호두말이',
    titleEn: 'Persimmon Walnut Roll',
    image: 'assets/figma/recommend/persimmon_walnut_roll.png',
  ),
  (
    subtitle: '단단한 내공',
    subtitleEn: 'Quiet strength',
    title: '육포다식',
    titleEn: 'Yukpo Dasik',
    image: 'assets/figma/recommend/yukpo_jeonggwa.png',
  ),
  (
    subtitle: '구수한 다정함',
    subtitleEn: 'Warm and nutty',
    title: '콩고물 도라지정과',
    titleEn: 'Soybean Bellflower Jeonggwa',
    image: 'assets/figma/recommend/soybean_bellflower_jeonggwa.png',
  ),
  (
    subtitle: '상큼 발랄',
    subtitleEn: 'Bright and zesty',
    title: '금귤정과',
    titleEn: 'Kumquat Jeonggwa',
    image: 'assets/figma/recommend/kumquat_jeonggwa.png',
  ),
  (
    subtitle: '할매입맛',
    subtitleEn: 'Old soul palate',
    title: '양갱',
    titleEn: 'Yanggaeng',
    image: 'assets/figma/recommend/yanggaeng.png',
  ),
  (
    subtitle: '바삭한 부지런쟁이',
    subtitleEn: 'Crunchy go-getter',
    title: '견과류',
    titleEn: 'Mixed Nuts',
    image: 'assets/figma/recommend/roasted_nuts.png',
  ),
  (
    subtitle: '귀염둥이',
    subtitleEn: 'Little charmer',
    title: '매작과',
    titleEn: 'Maejakgwa',
    image: 'assets/figma/recommend/maejakgwa.png',
  ),
  (
    subtitle: '달콤 바삭 매력',
    subtitleEn: 'Sweet & crunchy',
    title: '깨강정',
    titleEn: 'Sesame Gangjeong',
    image: 'assets/figma/recommend/sesame_crunch.png',
  ),
];

class _LandingView extends StatelessWidget {
  const _LandingView({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final deco = decoScaleOf(context, designWidth: 1409);

    return Container(
      color: const Color(0xFFFCF7F5),
      constraints: const BoxConstraints(minHeight: 944),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -420 * deco,
            bottom: -210 * deco,
            child: WatercolorDeco(decoQuizPink, width: 980 * deco),
          ),
          Positioned(
            right: -34 * deco,
            top: -270 * deco,
            child: WatercolorDeco(decoQuizBlob, width: 690 * deco),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 108, 24, 88),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  children: [
                    Text(
                      tr('퍼스널 다과 추천', 'Personal Dagwa Recommendation'),
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
                    const SizedBox(height: 28),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Text(
                        tr(
                          '6가지 간단한 질문으로 이루어진 취향 테스트를 통해\n오늘의 당신에게 어울리는 다과를 만나보세요!',
                          'Take a simple 6-question taste test and meet the dagwa that suits you today.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF786A6A),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 20,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 58),
                    const _PreviewMarquee(cards: _previewCards),
                    const SizedBox(height: 58),
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
        ],
      ),
    );
  }
}

class _PreviewMarquee extends StatefulWidget {
  const _PreviewMarquee({required this.cards});

  final List<
    ({
      String subtitle,
      String subtitleEn,
      String title,
      String titleEn,
      String image,
    })
  >
  cards;

  @override
  State<_PreviewMarquee> createState() => _PreviewMarqueeState();
}

class _PreviewMarqueeState extends State<_PreviewMarquee>
    with SingleTickerProviderStateMixin {
  static const double _itemWidth = 205;
  static const double _gap = 22;

  late final AnimationController _controller;

  double get _setWidth => widget.cards.length * (_itemWidth + _gap);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.cards.length * 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loop = [...widget.cards, ...widget.cards, ...widget.cards];

    return SizedBox(
      height: 318,
      width: double.infinity,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.translate(
            offset: Offset(-_controller.value * _setWidth, 0),
            child: child,
          ),
          // 카드 줄은 화면보다 훨씬 넓다. OverflowBox로 가로 제약을 풀어 줘야
          // 디버그 빌드에서 overflow 경고가 뜨지 않는다. 실제로 삐져나온 부분은
          // 바깥 ClipRect가 잘라낸다.
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: double.infinity,
            child: SizedBox(
              width: _setWidth * 3,
              child: Row(
                children: [
                  for (final card in loop)
                    Padding(
                      padding: const EdgeInsets.only(right: _gap),
                      child: SizedBox(
                        width: _itemWidth,
                        child: _PreviewCard(card: card),
                      ),
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
    return SizedBox(
      height: 318,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 205,
            height: 205,
            child: Image.asset(card.image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            tr(card.subtitle, card.subtitleEn),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 20,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tr(card.title, card.titleEn),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 24,
              height: 1.25,
            ),
          ),
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
    final pct = totalSteps <= 1 ? 100 : (step / (totalSteps - 1) * 100).round();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 1100;
    final topPadding = screenWidth >= 900 ? 78.0 : 44.0;
    final deco = decoScaleOf(context, designWidth: 1409);

    return Container(
      color: const Color(0xFFFCF7F5),
      constraints: const BoxConstraints(minHeight: 944),
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
            padding: EdgeInsets.only(top: topPadding, bottom: 48),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _QuizEyebrow(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 672),
                        child: _ProgressBar(
                          step: step,
                          totalSteps: totalSteps,
                          pct: pct,
                        ),
                      ),
                      const SizedBox(height: 48),

                      _QuestionHeader(question: question),
                      const SizedBox(height: 48),

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

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1024),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _QuizNavButton(
                              label: tr('이전 질문', 'Previous'),
                              onPressed: onBack ?? () {},
                              primary: false,
                            ),
                            _QuizNavButton(
                              label: isLast
                                  ? tr('취향 분석하기', 'Analyze my taste')
                                  : tr('다음 단계', 'Next'),
                              onPressed: selected != null
                                  ? () => onPick(selected!)
                                  : onSkip,
                              primary: true,
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

class _QuizEyebrow extends StatelessWidget {
  const _QuizEyebrow();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'ATMOSPHERIC SELECTION',
      style: TextStyle(
        color: Color(0xFFBECCA3),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        height: 20 / 14,
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
              tr(
                '$totalSteps개 중 ${step + 1}번째 질문',
                'Question ${step + 1} of $totalSteps',
              ),
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
            value: totalSteps <= 0 ? 1 : (step + 1) / totalSteps,
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

class _QuizNavButton extends StatelessWidget {
  const _QuizNavButton({
    required this.label,
    required this.onPressed,
    required this.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF934753).withValues(alpha: 0.30),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: primary ? const Color(0xFF934753) : Colors.white,
          foregroundColor: primary ? Colors.white : const Color(0xFF934753),
          minimumSize: Size(primary && label.length > 5 ? 178 : 153, 44),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.14,
            height: 20 / 14,
          ),
        ),
        child: Text(label, maxLines: 1),
      ),
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

  Color get _borderColor => widget.selected
      ? const Color(0xFF934753)
      : _hovered
      ? const Color(0xFF934753).withValues(alpha: 0.28)
      : Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final title = tr(
      widget.option.displayTitle ?? widget.option.title,
      widget.option.displayTitleEn ?? widget.option.titleEn,
    );
    final subtitle = tr(
      widget.option.displaySubtitle ?? widget.option.subtitle,
      widget.option.displaySubtitleEn ?? widget.option.subtitleEn,
    );

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor,
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.selected
                    ? const Color(0xFF934753).withValues(alpha: 0.16)
                    : _hovered
                    ? const Color(0xFF934753).withValues(alpha: 0.10)
                    : const Color(0xFF934753).withValues(alpha: 0.05),
                blurRadius: widget.selected ? 18 : (_hovered ? 12 : 1),
                offset: Offset(0, widget.selected || _hovered ? 4 : 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: widget.option.imageStyle == _QuizImageStyle.circle
                    ? 38
                    : 24,
                child: Center(child: _OptionCardImage(option: widget.option)),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: widget.option.imageStyle == _QuizImageStyle.circle
                    ? 242
                    : 239,
                child: SizedBox(
                  height: 34,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        color: widget.selected
                            ? const Color(0xFF934753)
                            : const Color(0xFF1C1C18),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 24,
                        fontWeight: widget.selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        height: 32 / 24,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: widget.option.imageStyle == _QuizImageStyle.circle
                    ? 280
                    : 278,
                child: SizedBox(
                  height: 34,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 12,
                      height: 16 / 12,
                    ),
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

class _OptionCardImage extends StatelessWidget {
  const _OptionCardImage({required this.option});

  final _QuizOption option;

  @override
  Widget build(BuildContext context) {
    final isCircle = option.imageStyle == _QuizImageStyle.circle;
    final size = isCircle ? 178.0 : 194.0;
    final image = _QuizAssetImage(
      path: option.imagePath,
      fit: option.imageFit,
      size: size,
      fallbackColor: option.bgColor,
    );

    if (isCircle) {
      return SizedBox(width: size, height: size, child: image);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: option.bgColor,
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD9808C).withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: option.imageFit == BoxFit.contain
            ? const EdgeInsets.all(18)
            : EdgeInsets.zero,
        child: image,
      ),
    );
  }
}

class _QuizAssetImage extends StatelessWidget {
  const _QuizAssetImage({
    required this.path,
    required this.fit,
    required this.size,
    required this.fallbackColor,
  });

  final String path;
  final BoxFit fit;
  final double size;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stack) =>
          _QuizImageFallback(size: size, color: fallbackColor),
    );
  }
}

class _QuizImageFallback extends StatelessWidget {
  const _QuizImageFallback({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: color.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFCBB8B4),
        size: 36,
      ),
    );
  }
}

// ── Loading ────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF7F5),
      padding: const EdgeInsets.symmetric(vertical: 120),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF934753)),
            const SizedBox(height: 32),
            Text(
              tr('취향을 분석하는 중이에요...', 'Analysing your taste…'),
              style: const TextStyle(
                color: Color(0xFF8F7E7B),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error / Result ─────────────────────────────────────────────────────────────

class _RecommendationErrorView extends StatelessWidget {
  const _RecommendationErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onHome,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;

    return Container(
      color: const Color(0xFFFFFCF7),
      constraints: const BoxConstraints(minHeight: 720),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                compact ? 24 : 42,
                compact ? 34 : 46,
                compact ? 24 : 42,
                compact ? 34 : 44,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9D7D2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr('추천 결과를 받을 수 없습니다.', 'No recommendation received.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: compact ? 30 : 40,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8C7E7B),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 34),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton(
                        onPressed: onHome,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF934753),
                          side: const BorderSide(color: Color(0xFF934753)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 17,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          tr('처음으로', 'Start over'),
                          style: const TextStyle(
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF934753),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          tr('다시 시도하기', 'Try again'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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

class _ResultView extends StatelessWidget {
  const _ResultView({super.key, required this.menuName, required this.onHome});
  final String menuName;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final data = dagwaResults[menuName];
    final isWide = MediaQuery.sizeOf(context).width >= 780;
    final paragraphs = data == null
        ? <String>[]
        : data.description
              .split(RegExp(r'\n\s*\n'))
              .where((paragraph) => paragraph.trim().isNotEmpty)
              .toList();

    return Container(
      color: const Color(0xFFDDDAD9),
      padding: const EdgeInsets.symmetric(vertical: 46),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1116),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isWide ? 34 : 22,
                isWide ? 32 : 24,
                isWide ? 34 : 22,
                isWide ? 34 : 26,
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
                    width: isWide ? 312 : 232,
                    height: isWide ? 300 : 224,
                    child: data != null
                        ? Image.asset(data.imagePath, fit: BoxFit.contain)
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 26),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Text(
                      data?.title ?? '오늘의 추천 다과는 $menuName 입니다!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF633B3A),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (data != null)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 930),
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < paragraphs.length;
                            index++
                          ) ...[
                            Text(
                              paragraphs[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF8C7E7B),
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 20,
                                height: 1.6,
                              ),
                            ),
                            if (index != paragraphs.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  if (data != null) const SizedBox(height: 38),
                  if (data != null)
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _PairingBox(
                              label: tr('함께 어울리는 메뉴/차', 'Pairs well with'),
                              value: data.pairing,
                              desc: data.pairingDesc,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _PairingBox(
                              label: tr('차선 추천', 'Runner-up'),
                              value: data.runnerUp,
                              desc: data.runnerUpDesc,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _PairingBox(
                            label: tr('함께 어울리는 메뉴/차', 'Pairs well with'),
                            value: data.pairing,
                            desc: data.pairingDesc,
                          ),
                          const SizedBox(height: 12),
                          _PairingBox(
                            label: tr('차선 추천', 'Runner-up'),
                            value: data.runnerUp,
                            desc: data.runnerUpDesc,
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
                            '행궁다과 추천 결과: ${data?.title ?? menuName}',
                            'Haenggung Dagwa result: ${data?.title ?? menuName}',
                          ),
                        ),
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              tr(
                                '추천 결과를 복사했어요.',
                                'Result copied to clipboard.',
                              ),
                            ),
                          ),
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
        tr('메뉴 보러가기', 'See menu'),
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
  const _PairingBox({
    required this.label,
    required this.value,
    required this.desc,
  });
  final String label;
  final String value;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 176),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 14),
          Center(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC85F65),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            desc,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF8C7E7B),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
