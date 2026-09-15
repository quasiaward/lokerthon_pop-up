import 'package:flutter/material.dart';

import '../l10n/lang.dart';

/// 퀴즈 질문·선택지 원본 데이터.
///
/// ⚠️ [QuizOption.title]은 **추천 알고리즘의 로직 키**다.
/// `local_recommendation_engine.dart`의 점수표 키와 정확히 같아야 하므로
/// 절대 번역하지 않는다. 화면에 보이는 문구는 [QuizOption.label]이 따로 갖는다.

enum QuizImageStyle { circle, square }

class QuizOption {
  const QuizOption({
    required this.title,
    required this.label,
    required this.desc,
    required this.bgColor,
    required this.imagePath,
    this.imageStyle = QuizImageStyle.square,
    this.imageFit = BoxFit.cover,
  });

  /// 로직 키 (한국어 고정) — 추천 알고리즘이 이 값을 읽는다.
  final String title;

  /// 화면에 보이는 선택지 이름.
  final L10nText label;

  /// 선택지 아래 한 줄 설명.
  final L10nText desc;

  final Color bgColor;
  final String imagePath;
  final QuizImageStyle imageStyle;
  final BoxFit imageFit;
}

class QuizQuestion {
  const QuizQuestion({
    required this.before,
    required this.keyword,
    required this.after,
    required this.hint,
    required this.options,
  });

  /// 질문은 세 토막으로 나눠 둔다. 가운데 [keyword]만 accent 색으로 들어 올린다.
  final L10nText before;
  final L10nText keyword;
  final L10nText after;

  final L10nText hint;
  final List<QuizOption> options;

  /// 세 토막을 이어 붙인 현재 언어의 질문 한 문장.
  String get title => '${before.t}${keyword.t}${after.t}';
}

const quizPinkBg = Color(0xFFFCE4EC);
const quizTealBg = Color(0xFFE0F2F1);
const quizYellowBg = Color(0xFFFFF8E1);
const quizInkBg = Color(0xFFECEFF1);

const quizQuestions = <QuizQuestion>[
  // ── Q1. 기분의 색 ─────────────────────────────────────────────────────────
  QuizQuestion(
    before: L10nText('오늘 당신의 ', 'What colour is your ', '今日のあなたの'),
    keyword: L10nText('기분', 'mood', '気分'),
    after: L10nText('은 어떤 색인가요?', ' today?', 'は何色ですか？'),
    hint: L10nText(
      '지금 가장 이끌리는 색감을 골라주세요.',
      'Pick the colour you are drawn to right now.',
      'いま、いちばん惹かれる色を選んでください。',
    ),
    options: [
      QuizOption(
        title: '매화 분홍',
        label: L10nText('매화 분홍', 'Plum Blossom Pink', '梅の花のピンク'),
        desc: L10nText(
          '설레고 따뜻한 매화 분홍',
          'A fluttering, warm plum pink',
          'ときめく、あたたかな梅の色',
        ),
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q1_c1.png',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      QuizOption(
        title: '소나무 청록',
        label: L10nText('소나무 청록', 'Pine Teal', '松の青緑'),
        desc: L10nText(
          '활동적이고 상쾌한 청록색의 솔바람',
          'An active, refreshing pine teal breeze',
          '軽やかで爽やかな松風の色',
        ),
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q1_c2.png',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      QuizOption(
        title: '유자 노랑',
        label: L10nText('유자 노랑', 'Yuja Yellow', '柚子の黄'),
        desc: L10nText(
          '생기 있고 발랄한 유자 노랑',
          'A bright and lively yuja yellow',
          '生き生きと弾む柚子の黄色',
        ),
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q1_c3.png',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
      QuizOption(
        title: '먹색',
        label: L10nText('먹색', 'Ink Black', '墨の色'),
        desc: L10nText(
          '깊고 단단한 먹색의 무게',
          'The deep, steady weight of ink black',
          '深く揺るがない墨の重み',
        ),
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q1_c4.png',
        imageStyle: QuizImageStyle.circle,
        imageFit: BoxFit.contain,
      ),
    ],
  ),

  // ── Q2. 마음의 날씨 ───────────────────────────────────────────────────────
  QuizQuestion(
    before: L10nText('오늘 마음의 ', 'What is the ', '今日の心の'),
    keyword: L10nText('날씨', 'weather', '天気'),
    after: L10nText('는 어떤가요?', ' in your heart today?', 'はどうですか？'),
    hint: L10nText(
      '지금 가장 이끌리는 날씨를 골라주세요.',
      'Pick the weather you are drawn to right now.',
      'いま、いちばん惹かれる天気を選んでください。',
    ),
    options: [
      QuizOption(
        title: '맑고 활기참',
        label: L10nText('맑고 활기참', 'Sunny & lively', '晴れて元気'),
        desc: L10nText(
          '에너지 가득, 생기 가득',
          'Full of energy and liveliness',
          'エネルギーと生気に満ちて',
        ),
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q2_c1.png',
      ),
      QuizOption(
        title: '흐리고 지침',
        label: L10nText('흐리고 지침', 'Cloudy & weary', '曇りで疲れ気味'),
        desc: L10nText('잠시 쉬어갈 시간', 'A moment to pause and rest', 'ひと休みする時間'),
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q2_c2.png',
      ),
      QuizOption(
        title: '잔잔하고 평온',
        label: L10nText('선선하고 평온', 'Cool & peaceful', '涼やかで穏やか'),
        desc: L10nText('마음의 안정과 평화', 'A quiet peace of mind', '心の安らぎと平和'),
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q2_c3.png',
      ),
      QuizOption(
        title: '설레고 두근거려요',
        label: L10nText('따뜻하고 두근거림', 'Warm & fluttering', 'あたたかく高鳴る'),
        desc: L10nText(
          '새로운 시작의 설레임',
          'The flutter of a new beginning',
          '新しい始まりのときめき',
        ),
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q2_c4.png',
      ),
    ],
  ),

  // ── Q3. 동행 ──────────────────────────────────────────────────────────────
  QuizQuestion(
    before: L10nText('오늘 이 자리, ', 'Who are you ', '今日この席、'),
    keyword: L10nText('누구', 'with', '誰'),
    after: L10nText('와 함께 하셨나요?', ' here today?', 'と一緒ですか？'),
    hint: L10nText(
      '함께하고 싶은 누군가를 선택해주세요.',
      'Choose someone you would like to be with.',
      '一緒に過ごしたい人を選んでください。',
    ),
    options: [
      QuizOption(
        title: '소중한 사람',
        label: L10nText('소중한 사람', 'A loved one', '大切な人'),
        desc: L10nText(
          '따뜻하고 늘 곁에 있어주는 사람',
          'Warm, always by your side',
          'あたたかく、いつもそばにいる人',
        ),
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q3_c1.png',
      ),
      QuizOption(
        title: '혼자',
        label: L10nText('혼자', 'Alone', 'ひとり'),
        desc: L10nText('온전한 나와의 시간', 'Time fully your own', '自分だけの時間'),
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q3_c2.png',
      ),
      QuizOption(
        title: '가족',
        label: L10nText('가족', 'Family', '家族'),
        desc: L10nText(
          '평생 함께할 동반자',
          'Lifelong companions by your side',
          '生涯をともにする人',
        ),
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q3_c3.png',
      ),
      QuizOption(
        title: '친구',
        label: L10nText('친구', 'Friends', '友人'),
        desc: L10nText('깊고 단단한 우정', 'Deep, steady friendship', '深く確かな友情'),
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q3_c4.png',
      ),
    ],
  ),

  // ── Q4. 식감 ──────────────────────────────────────────────────────────────
  QuizQuestion(
    before: L10nText('오늘 어떤 ', 'Which ', '今日はどんな'),
    keyword: L10nText('식감', 'texture', '食感'),
    after: L10nText(
      '이 지금 당신을 달래줄 것 같나요?',
      ' would soothe you right now?',
      'が、いまのあなたを癒やしてくれそうですか？',
    ),
    hint: L10nText(
      '지금 가장 이끌리는 식감을 골라주세요.',
      'Pick the texture you are drawn to right now.',
      'いま、いちばん惹かれる食感を選んでください。',
    ),
    options: [
      QuizOption(
        title: '부드러운',
        label: L10nText('부드러운', 'Soft', 'やわらか'),
        desc: L10nText(
          '입안에서 부드럽게 녹아내리는 식감',
          'Melts softly in your mouth',
          '口の中でやさしくとろける',
        ),
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q4_c1.png',
      ),
      QuizOption(
        title: '바삭한',
        label: L10nText('바삭한', 'Crisp', 'さくさく'),
        desc: L10nText(
          '가볍게 부서지는 즐거움',
          'The joy of a light, crisp bite',
          '軽やかに砕ける楽しさ',
        ),
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q4_c2.png',
      ),
      QuizOption(
        title: '쫀득한',
        label: L10nText('쫀득한', 'Chewy', 'もちもち'),
        desc: L10nText(
          '천천히 오래 남는 만족감',
          'Slow, lingering satisfaction',
          'ゆっくり長く続く満足感',
        ),
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q4_c3.png',
      ),
      QuizOption(
        title: '촉촉한',
        label: L10nText('촉촉한', 'Moist', 'しっとり'),
        desc: L10nText(
          '촉촉하고 은은한 식감',
          'Moist with a gentle finish',
          'しっとりと穏やかな口あたり',
        ),
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q4_c4.png',
      ),
    ],
  ),

  // ── Q5. 계절 ──────────────────────────────────────────────────────────────
  QuizQuestion(
    before: L10nText('지금 이 순간 어떤 ', 'Which ', 'いまこの瞬間、どの'),
    keyword: L10nText('계절', 'season', '季節'),
    after: L10nText('이 느껴지시나요?', ' do you feel right now?', 'を感じますか？'),
    hint: L10nText(
      '지금 가장 이끌리는 계절을 골라주세요.',
      'Pick the season you are drawn to right now.',
      'いま、いちばん惹かれる季節を選んでください。',
    ),
    options: [
      QuizOption(
        title: '봄',
        label: L10nText('봄', 'Spring', '春'),
        desc: L10nText(
          '설레고 부드러운 꽃향기의 시작',
          'The soft, fluttery start of blossoms',
          'ときめく、やわらかな花の香りのはじまり',
        ),
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q5_c1.png',
      ),
      QuizOption(
        title: '여름',
        label: L10nText('여름', 'Summer', '夏'),
        desc: L10nText(
          '싱그럽고 생기 넘치는 계절의 온기',
          'Fresh, vivid summer warmth',
          'みずみずしく生気あふれる季節のぬくもり',
        ),
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q5_c2.png',
      ),
      QuizOption(
        title: '가을',
        label: L10nText('가을', 'Autumn', '秋'),
        desc: L10nText(
          '깊어지는 향과 차분한 여운',
          'Deepening aromas and a calm afterglow',
          '深まる香りと静かな余韻',
        ),
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q5_c3.png',
      ),
      QuizOption(
        title: '겨울',
        label: L10nText('겨울', 'Winter', '冬'),
        desc: L10nText(
          '고요하고 포근한 휴식의 시간',
          'A still, cosy time of rest',
          '静かであたたかな休息の時間',
        ),
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q5_c4.png',
      ),
    ],
  ),

  // ── Q6. 문양 ──────────────────────────────────────────────────────────────
  QuizQuestion(
    before: L10nText('어떤 ', 'Which ', 'どんな'),
    keyword: L10nText('문양', 'pattern', '文様'),
    after: L10nText('이 눈길을 끄시나요?', ' catches your eye?', 'に目が留まりますか？'),
    hint: L10nText(
      '지금 가장 이끌리는 문양을 골라주세요.',
      'Pick the pattern you are drawn to right now.',
      'いま、いちばん惹かれる文様を選んでください。',
    ),
    options: [
      QuizOption(
        title: '둥근 모양',
        label: L10nText('둥근 문양', 'Round pattern', '丸い文様'),
        desc: L10nText(
          '부드럽고 포근한 안정감',
          'Soft, cosy reassurance',
          'やわらかく包みこむ安心感',
        ),
        bgColor: quizPinkBg,
        imagePath: 'assets/figma/quiz/figma_q6_c1.png',
      ),
      QuizOption(
        title: '물결 모양',
        label: L10nText('물결 문양', 'Wave pattern', '波の文様'),
        desc: L10nText(
          '자연스럽고 유연한 움직임',
          'Natural, flowing movement',
          '自然でしなやかな動き',
        ),
        bgColor: quizTealBg,
        imagePath: 'assets/figma/quiz/figma_q6_c2.png',
      ),
      QuizOption(
        title: '직선 모양',
        label: L10nText('곧은 문양', 'Straight pattern', '直線の文様'),
        desc: L10nText(
          '정돈되고 균형 잡힌 아름다움',
          'Tidy, balanced beauty',
          '整って均衡のとれた美しさ',
        ),
        bgColor: quizYellowBg,
        imagePath: 'assets/figma/quiz/figma_q6_c3.png',
      ),
      QuizOption(
        title: '별·꽃 모양',
        label: L10nText('별·꽃 문양', 'Star & flower pattern', '星と花の文様'),
        desc: L10nText(
          '개성있고 창의적인 새로움',
          'A creative, characterful newness',
          '個性的で創造的な新しさ',
        ),
        bgColor: quizInkBg,
        imagePath: 'assets/figma/quiz/figma_q6_c4.png',
      ),
    ],
  ),
];
