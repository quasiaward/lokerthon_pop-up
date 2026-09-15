import 'package:flutter/material.dart';

/// 퀴즈 질문·선택지 원본 데이터.
///
/// ⚠️ [QuizOption.title]은 **추천 알고리즘의 로직 키**다.
/// `local_recommendation_engine.dart`의 점수표 키와 정확히 같아야 하므로,
/// 표시 문구를 바꿀 때는 `displayTitle`을 쓰고 `title`은 건드리지 않는다.

enum QuizImageStyle { circle, square }

class QuizOption {
  const QuizOption({
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
    this.imageStyle = QuizImageStyle.square,
    this.imageFit = BoxFit.cover,
  });

  final String title; // 로직 키 — 알고리즘이 이 값을 읽는다
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final Color bgColor;
  final String imagePath;
  final String? displayTitle;
  final String? displayTitleEn;
  final String? displaySubtitle;
  final String? displaySubtitleEn;
  final QuizImageStyle imageStyle;
  final BoxFit imageFit;

  /// 화면에 보여줄 제목 (현재 언어 반영은 호출부에서 tr로 처리).
  String get shownTitle => displayTitle ?? title;
  String get shownTitleEn => displayTitleEn ?? titleEn;
  String get shownSubtitle => displaySubtitle ?? subtitle;
  String get shownSubtitleEn => displaySubtitleEn ?? subtitleEn;
}

class QuizQuestion {
  const QuizQuestion({
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
  final List<QuizOption> options;

  String get titleKo => '$before$keyword$after';
  String get titleEn => '$beforeEn$keywordEn$afterEn';
}

const quizPinkBg = Color(0xFFFCE4EC);
const quizTealBg = Color(0xFFE0F2F1);
const quizYellowBg = Color(0xFFFFF8E1);
const quizInkBg = Color(0xFFECEFF1);

const quizQuestions = <QuizQuestion>[
  QuizQuestion(
    before: '오늘 당신의 ',
    beforeEn: 'What color is your ',
    keyword: '기분',
    keywordEn: 'mood',
    after: '은 어떤 색인가요?',
    afterEn: ' today?',
    hint: '지금 가장 이끌리는 색감을 골라주세요.',
    hintEn: 'Pick the color you\'re drawn to right now.',
    options: [
      QuizOption(
        title: '매화 분홍',
        titleEn: 'Plum Blossom Pink',
        subtitle: '설레고 따뜻한 매화의 온기',
        subtitleEn: 'The fluttery warmth of plum blossoms',
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q1_c1.png',
        displaySubtitle: '설레고 따뜻한 매화 분홍',
        displaySubtitleEn: 'A fluttering, warm plum pink',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      QuizOption(
        title: '소나무 청록',
        titleEn: 'Pine Teal',
        subtitle: '차분하고 싱그러운 솔바람',
        subtitleEn: 'A calm, fresh pine breeze',
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q1_c2.png',
        displaySubtitle: '활동적이고 상쾌한 청록색의 솔바람',
        displaySubtitleEn: 'An active, refreshing pine teal breeze',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      QuizOption(
        title: '유자 노랑',
        titleEn: 'Yuzu Yellow',
        subtitle: '생기 있고 달콤한 유자의 향',
        subtitleEn: 'Lively, sweet yuzu scent',
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q1_c3.png',
        displaySubtitle: '생기 있고 발랄한 유자 노랑',
        displaySubtitleEn: 'A bright and lively yuzu yellow',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      QuizOption(
        title: '먹색',
        titleEn: 'Ink Black',
        subtitle: '깊고 단단한 전통의 무게',
        subtitleEn: 'The deep, solid weight of tradition',
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q1_c4.png',
        displaySubtitle: '깊고 단단한 먹색의 무게',
        displaySubtitleEn: 'The deep, steady weight of ink black',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
    ],
  ),
  QuizQuestion(
    before: '오늘 마음의 ',
    beforeEn: 'What\'s the ',
    keyword: '날씨',
    keywordEn: 'weather',
    after: '는 어떤가요?',
    afterEn: ' in your heart today?',
    hint: '지금 가장 이끌리는 날씨를 골라주세요.',
    hintEn: 'Pick the weather you\'re drawn to right now.',
    options: [
      QuizOption(
        title: '맑고 활기참',
        titleEn: 'Sunny & lively',
        subtitle: '설레고 따뜻한 햇빛의 온기',
        subtitleEn: 'The warm glow of bright sunshine',
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q2_c1.png',
        displaySubtitle: '에너지 가득, 생기 가득',
        displaySubtitleEn: 'Full of energy and liveliness',
      ),
      QuizOption(
        title: '흐리고 지침',
        titleEn: 'Cloudy & weary',
        subtitle: '차분하고 조용한 쉬고픈 날',
        subtitleEn: 'A calm, quiet day for rest',
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q2_c2.png',
        displaySubtitle: '잠시 쉬어갈 시간',
        displaySubtitleEn: 'A moment to pause and rest',
      ),
      QuizOption(
        title: '잔잔하고 평온',
        titleEn: 'Calm & peaceful',
        subtitle: '생기 있고 달콤한 유자의 향',
        subtitleEn: 'Gentle and serene',
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q2_c3.png',
        displayTitle: '선선하고 평온',
        displayTitleEn: 'Cool & peaceful',
        displaySubtitle: '마음의 안정과 평화',
        displaySubtitleEn: 'A quiet peace of mind',
      ),
      QuizOption(
        title: '설레고 두근거려요',
        titleEn: 'Fluttery & excited',
        subtitle: '깊고 단단한 전통의 무게',
        subtitleEn: 'Heart racing with anticipation',
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q2_c4.png',
        displayTitle: '따뜻하고 두근거림',
        displayTitleEn: 'Warm & fluttering',
        displaySubtitle: '새로운 시작의 설레임',
        displaySubtitleEn: 'The flutter of a new beginning',
      ),
    ],
  ),
  QuizQuestion(
    before: '오늘 이 자리, ',
    beforeEn: 'Who are you ',
    keyword: '누구',
    keywordEn: 'with',
    after: '와 함께 하셨나요?',
    afterEn: ' here today?',
    hint: '함께하고 싶은 누군가를 선택해주세요.',
    hintEn: 'Choose someone you\'d like to be with.',
    options: [
      QuizOption(
        title: '소중한 사람',
        titleEn: 'A loved one',
        subtitle: '따뜻하고 늘 곁에 있어주는 사람',
        subtitleEn: 'Warm, always by your side',
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q3_c1.png',
      ),
      QuizOption(
        title: '혼자',
        titleEn: 'Alone',
        subtitle: '온전한 나와의 시간',
        subtitleEn: 'Time fully your own',
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q3_c2.png',
      ),
      QuizOption(
        title: '가족',
        titleEn: 'Family',
        subtitle: '평생 함께 있어줄 동반자',
        subtitleEn: 'Lifelong companions',
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q3_c3.png',
        displaySubtitle: '평생 함께 함께할 동반자',
        displaySubtitleEn: 'Lifelong companions by your side',
      ),
      QuizOption(
        title: '친구',
        titleEn: 'Friends',
        subtitle: '깊고 단단한 우정',
        subtitleEn: 'Deep, steady friendship',
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q3_c4.png',
      ),
    ],
  ),
  QuizQuestion(
    before: '오늘 어떤 ',
    beforeEn: 'Which ',
    keyword: '식감',
    keywordEn: 'texture',
    after: '이 지금 당신을 달래줄 것 같나요?',
    afterEn: ' would soothe you right now?',
    hint: '지금 가장 이끌리는 식감을 골라주세요.',
    hintEn: 'Pick the texture you\'re drawn to right now.',
    options: [
      QuizOption(
        title: '부드러운',
        titleEn: 'Soft',
        subtitle: '입안에서 부드럽게 녹아내리는 식감',
        subtitleEn: 'Melts softly in your mouth',
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q4_c1.png',
      ),
      QuizOption(
        title: '바삭한',
        titleEn: 'Crisp',
        subtitle: '가볍게 부서지는 즐거움',
        subtitleEn: 'The joy of a light, crisp bite',
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q4_c2.png',
      ),
      QuizOption(
        title: '쫀득한',
        titleEn: 'Chewy',
        subtitle: '천천히 오래 남는 만족감',
        subtitleEn: 'Slow, lingering satisfaction',
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q4_c3.png',
      ),
      QuizOption(
        title: '촉촉한',
        titleEn: 'Moist',
        subtitle: '촉촉하고 은은한 식감',
        subtitleEn: 'Moist with a gentle finish',
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q4_c4.png',
      ),
    ],
  ),
  QuizQuestion(
    before: '지금 이 순간 어떤 ',
    beforeEn: 'Which ',
    keyword: '계절',
    keywordEn: 'season',
    after: '이 느껴지시나요?',
    afterEn: ' do you feel right now?',
    hint: '지금 가장 이끌리는 계절을 골라주세요.',
    hintEn: 'Pick the season you\'re drawn to right now.',
    options: [
      QuizOption(
        title: '봄',
        titleEn: 'Spring',
        subtitle: '설레고 부드러운 꽃향기의 시작',
        subtitleEn: 'The soft, fluttery start of blossoms',
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q5_c1.png',
      ),
      QuizOption(
        title: '여름',
        titleEn: 'Summer',
        subtitle: '싱그럽고 생기 넘치는 계절의 온기',
        subtitleEn: 'Fresh, vivid summer warmth',
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q5_c2.png',
      ),
      QuizOption(
        title: '가을',
        titleEn: 'Autumn',
        subtitle: '깊어지는 향과 차분한 여운',
        subtitleEn: 'Deepening aromas and a calm afterglow',
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q5_c3.png',
      ),
      QuizOption(
        title: '겨울',
        titleEn: 'Winter',
        subtitle: '고요하고 포근한 휴식의 시간',
        subtitleEn: 'A still, cozy time of rest',
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q5_c4.png',
      ),
    ],
  ),
  QuizQuestion(
    before: '어떤 ',
    beforeEn: 'Which ',
    keyword: '문양',
    keywordEn: 'pattern',
    after: '이 눈길을 끄시나요?',
    afterEn: ' catches your eye?',
    hint: '지금 가장 이끌리는 문양을 골라주세요.',
    hintEn: 'Pick the pattern you\'re drawn to right now.',
    options: [
      QuizOption(
        title: '둥근 모양',
        titleEn: 'Round',
        subtitle: '부드럽고 포근한 안정감',
        subtitleEn: 'Soft, cozy reassurance',
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q6_c1.png',
      ),
      QuizOption(
        title: '물결 모양',
        titleEn: 'Wavy',
        subtitle: '자연스럽고 유연한 움직임',
        subtitleEn: 'Natural, flowing movement',
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q6_c2.png',
        displayTitle: '물결 문양',
        displayTitleEn: 'Wave pattern',
      ),
      QuizOption(
        title: '직선 모양',
        titleEn: 'Linear',
        subtitle: '정돈되고 균형 잡힌 아름다움',
        subtitleEn: 'Tidy, balanced beauty',
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q6_c3.png',
        displayTitle: '곧은 문양',
        displayTitleEn: 'Straight pattern',
      ),
      QuizOption(
        title: '별·꽃 모양',
        titleEn: 'Star or flower',
        subtitle: '개성과 경험이 담긴 모양',
        subtitleEn: 'A shape full of character and story',
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q6_c4.png',
        displayTitle: '별·꽃 문양',
        displayTitleEn: 'Star & flower pattern',
        displaySubtitle: '개성있고 창의적인 새로움',
        displaySubtitleEn: 'A creative, characterful newness',
      ),
    ],
  ),
];
