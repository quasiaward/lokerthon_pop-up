import 'dart:math' as math;

import '../models/recommendation.dart';

const defaultRecommendationInput = RecommendationInput(
  personality: '조용히 머무는 I형',
  moment: '부모님과 함께해요',
  sweetness: '적당히 달콤한 맛',
  texture: '쫀득한 떡 식감',
  tea: '따뜻한 차와 함께',
  choiceStyle: '대표 메뉴를 고르는 편',
  situation: '부모님과 차분히 나눌 다과를 찾고 있어요',
);

class RecommendationService {
  static const Map<String, Map<String, int>> _answerFeatures = {
    '조용히 머무는 I형': {'calm': 3, 'solo': 1},
    '같이 나누는 E형': {'share': 3, 'bright': 1},
    '차분히 음미하는 감각형': {'detail': 3, 'balanced': 1},
    '이야기와 의미를 좋아하는 직관형': {'story': 3, 'local': 1},
    '혼자 쉬고 싶어요': {'solo': 3, 'calm': 2, 'warm': 1},
    '부모님과 함께해요': {'elder': 3, 'warm': 1, 'safe': 1},
    '친구와 디저트를 먹어요': {'share': 3, 'photo': 1, 'cool': 1, 'bright': 1},
    '작은 선물도 고려해요': {'gift': 3, 'package': 2, 'local': 1},
    '수원 여행 기념이에요': {'local': 3, 'story': 2, 'package': 1},
    '은은하고 담백한 단맛': {'subtle': 3, 'tea': 1},
    '적당히 달콤한 맛': {'balanced': 3, 'sweet': 1},
    '확실히 달콤한 맛': {'sweet': 4, 'bright': 1},
    '쌉싸름하고 깊은 맛': {'bitter': 3, 'herbal': 2, 'deep': 2},
    '쫀득한 떡 식감': {'chewy': 4},
    '바삭하고 결 있는 식감': {'crisp': 4},
    '부드럽고 촉촉한 식감': {'soft': 4},
    '시원하게 녹는 식감': {'icy': 4, 'cool': 2},
    '따뜻한 차와 함께': {'warm': 4, 'tea': 2},
    '상큼하고 산뜻하게': {'fresh': 4, 'tea': 1},
    '한방차처럼 깊게': {'herbal': 3, 'deep': 3, 'bitter': 1},
    '차보다 시원한 메뉴': {'cool': 4, 'icy': 2},
    '대표 메뉴를 고르는 편': {'signature': 2, 'safe': 1},
    '익숙하고 안정적인 메뉴': {'safe': 3, 'balanced': 1},
    '새로운 메뉴도 좋아함': {'novelty': 3, 'story': 1},
    '보기 좋은 메뉴가 좋음': {'photo': 4, 'bright': 1},
  };

  static const Map<String, String> _featureLabels = {
    'balanced': '균형감',
    'bitter': '쌉싸름함',
    'bright': '밝은 분위기',
    'calm': '차분함',
    'chewy': '쫀득함',
    'cool': '시원함',
    'crisp': '바삭함',
    'deep': '깊은 향',
    'detail': '섬세함',
    'elder': '어른 동행',
    'fresh': '산뜻함',
    'gift': '선물성',
    'herbal': '한방 향',
    'icy': '빙수감',
    'local': '수원 기념성',
    'novelty': '새로움',
    'package': '포장성',
    'photo': '사진성',
    'safe': '안정감',
    'share': '나눔',
    'signature': '대표성',
    'solo': '혼자 쉬기',
    'soft': '부드러움',
    'story': '이야기성',
    'subtle': '은은한 단맛',
    'sweet': '달콤함',
    'tea': '차 페어링',
    'warm': '따뜻함',
  };

  static const _specificFeatures = [
    'gift',
    'package',
    'local',
    'story',
    'crisp',
    'photo',
    'fresh',
    'herbal',
    'deep',
    'bitter',
    'icy',
    'cool',
    'sweet',
    'bright',
    'soft',
    'novelty',
  ];

  static const _profiles = [
    _MenuProfile(
      id: 'flower-pancake',
      name: '진달래화전',
      dagwaType: '화전',
      typeDescription: '꽃을 올려 부치는 전통 떡류로 계절감, 색감, 은은한 단맛이 강합니다.',
      profileTitle: '섬세한 계절파',
      summary: '꽃과 색감, 은은한 단맛처럼 작은 디테일을 즐기는 취향입니다.',
      pairing: '생강차',
      message: '사진으로 남기기 좋은 색감과 담백한 단맛을 함께 골랐습니다.',
      tags: ['화전', '사진 좋은 메뉴', '담백함'],
      reasons: [
        '진달래화전은 식용꽃을 올린 전통 화전이라 보기 좋은 메뉴를 선호할 때 만족감이 큽니다.',
        '단맛이 과하지 않고 향과 식감이 섬세해 가볍게 먹기 좋습니다.',
        '맑은 생강차와 함께하면 달콤함 뒤의 여운이 깔끔하게 정리됩니다.',
      ],
      features: {
        'photo': 5,
        'fresh': 4,
        'novelty': 3,
        'subtle': 3,
        'detail': 3,
        'chewy': 2,
        'soft': 2,
        'story': 2,
        'local': 1,
        'tea': 1,
        'bright': 1,
      },
    ),
    _MenuProfile(
      id: 'mango-bingsu',
      name: '망고빙수',
      dagwaType: '빙수',
      typeDescription: '우유 얼음과 과일 단맛이 또렷해 여럿이 나누기 좋은 시원한 디저트입니다.',
      profileTitle: '밝은 디저트파',
      summary: '함께 나누는 즐거움과 확실한 달콤함, 시원함을 원하는 취향입니다.',
      pairing: '가벼운 차 또는 물',
      message: '산책 끝에 나누기 좋은 달콤하고 시원한 쉼을 골랐습니다.',
      tags: ['달콤함', '시원함', '함께 나누기'],
      reasons: [
        '망고빙수는 우유 얼음과 망고의 달콤함이 분명해 친구와 나누기 좋은 메뉴입니다.',
        '차보다 시원한 메뉴를 원하거나 더운 날 산책 후라면 만족도가 높습니다.',
        '전통차가 낯선 방문자도 쉽게 고를 수 있어 밝고 편안한 선택입니다.',
      ],
      features: {
        'icy': 5,
        'cool': 5,
        'sweet': 4,
        'share': 4,
        'bright': 3,
        'photo': 2,
        'fresh': 1,
        'novelty': 1,
      },
    ),
    _MenuProfile(
      id: 'green-tea-bingsu',
      name: '녹차빙수',
      dagwaType: '빙수',
      typeDescription: '빙수의 시원함에 녹차의 쌉싸름함을 더한 절제된 단맛의 디저트입니다.',
      profileTitle: '쌉싸름한 산뜻파',
      summary: '시원한 디저트는 좋지만 단맛은 조금 절제하고 싶은 취향입니다.',
      pairing: '생강차',
      message: '녹차의 쌉싸름함과 우유 얼음의 부드러움을 함께 맞췄습니다.',
      tags: ['녹차', '시원함', '담백한 단맛'],
      reasons: [
        '녹차빙수는 빙수의 시원함을 유지하면서도 단맛이 과하게 느껴지지 않는 선택입니다.',
        '쌉싸름하고 깊은 맛을 좋아하지만 차보다 디저트가 끌리는 날에 잘 맞습니다.',
        '친구와 나눠 먹어도 맛의 균형이 좋아 과하게 달지 않은 디저트를 찾을 때 좋습니다.',
      ],
      features: {
        'icy': 5,
        'cool': 4,
        'bitter': 4,
        'subtle': 3,
        'fresh': 2,
        'share': 2,
        'soft': 2,
        'novelty': 1,
      },
    ),
    _MenuProfile(
      id: 'yakgwa-story',
      name: '행궁약과',
      dagwaType: '유밀과·모약과',
      typeDescription: '네모난 약과 계열로 달콤함, 결 있는 식감, 포장성이 강합니다.',
      profileTitle: '로컬 스토리파',
      summary: '화성행궁 방문의 기억과 지역 이야기를 작은 다과로 남기고 싶은 취향입니다.',
      pairing: '쌍화차 또는 대추차',
      message: '오늘 추천할 약과 종류는 행궁약과입니다. 작게 나누기 좋고 선물로도 설명이 쉬워요.',
      tags: ['약과 추천', '수원 이야기', '포장 문의', '전통 간식'],
      reasons: [
        '행궁약과는 차와 함께 먹기 좋고, 화성행궁 방문 뒤 작은 기념 다과로 설명하기 쉽습니다.',
        '선물이나 포장을 고려한다면 개별 다과로 부담 없이 고를 수 있습니다.',
        '지역성과 전통 간식의 이야기를 함께 전하고 싶을 때 잘 맞습니다.',
      ],
      features: {
        'gift': 5,
        'package': 5,
        'local': 4,
        'story': 4,
        'crisp': 4,
        'sweet': 4,
        'herbal': 2,
        'deep': 2,
        'tea': 2,
        'signature': 2,
        'safe': 1,
        'warm': 1,
        'photo': 1,
      },
    ),
  ];

  RecommendationResult getRecommendation(
    RecommendationInput input, {
    int variant = 0,
  }) {
    final situation = input.situation.trim();
    final activeFeatures = _featuresFor(input, situation);
    final ranked = [
      for (final profile in _profiles)
        _scoreProfile(profile, activeFeatures, situation),
    ]..sort(_compareScores);

    final selectedScore = ranked.first;
    final selected = selectedScore.profile;
    final secondary = ranked
        .firstWhere((score) => score.profile.id != selected.id)
        .profile;
    final seed = _hash(
      '${input.personality}-${input.moment}-${input.sweetness}-${input.texture}-${input.tea}-${input.choiceStyle}-$variant',
    ).abs();

    return RecommendationResult(
      productId: selected.id,
      productName: selected.name,
      dagwaType: selected.dagwaType,
      typeDescription: selected.typeDescription,
      profileTitle: selected.profileTitle,
      headline: '${selected.profileTitle}에게 어울리는 오늘의 다과',
      aiSummary: _summaryFor(input, selected, activeFeatures),
      confidence: _confidenceFor(ranked, selected.id, situation),
      signals: _buildSignals(input, selected, situation, activeFeatures),
      analysisSteps: [
        '전통 한과 분류와 행궁다과의 개별 메뉴를 다과 유형 프로필로 나눴습니다.',
        '맛, 식감, 동행, 선물성, 사진성, 차 페어링 신호를 가중치로 계산했습니다.',
        '다과상 같은 구성 상품이 아니라 실제 개별 다과 한 가지를 최종 추천합니다.',
      ],
      reasons: [
        _typeReason(selected, activeFeatures),
        _tasteReason(input, selected),
        selected.reasons[seed % selected.reasons.length],
      ],
      teaPairing: selected.pairing,
      secondaryMenuName: secondary.name,
      packagingMessage: selected.message,
      tags: _dedupe([
        selected.dagwaType,
        ..._topFeatureLabels(selected, activeFeatures),
        ...selected.tags,
        if (situation.isNotEmpty) '상황 문장 반영',
      ]),
    );
  }

  String formatResult(RecommendationResult result) {
    return [
      '[행궁다과 AI 추천 결과]',
      '취향 프로필: ${result.profileTitle}',
      '추천 메뉴: ${result.productName}',
      '다과 유형: ${result.dagwaType}',
      '유형 설명: ${result.typeDescription}',
      'AI 요약: ${result.aiSummary}',
      '추천 매칭도: ${result.confidence}%',
      '추천 제목: ${result.headline}',
      '추천 이유:',
      for (var index = 0; index < result.reasons.length; index++)
        '${index + 1}. ${result.reasons[index]}',
      '함께 어울리는 메뉴/차: ${result.teaPairing}',
      '차선 추천: ${result.secondaryMenuName}',
      '추천 한 줄: ${result.packagingMessage}',
      '추천 근거: ${result.tags.join(', ')}',
    ].join('\n');
  }

  String buildLocalAiPrompt(RecommendationInput input) {
    final situation = input.situation.trim();
    final features = _featuresFor(input, situation);
    final featureLines = _promptFeatureLines(features);
    final situationText = situation.isEmpty ? '없음' : situation;

    return [
      '[행궁다과 나만의 다과 추천 로컬 AI 프롬프트]',
      '',
      '역할:',
      '너는 화성행궁 근처 전통 다과 브랜드 행궁다과의 취향 추천 AI다.',
      '고객이 고른 감각적 질문 답변을 해석해 실제 메뉴 한 가지를 따뜻하고 단정한 문장으로 추천한다.',
      '',
      '입력 축:',
      '- 색감/성향: ${input.personality}',
      '- 마음 날씨/방문 순간: ${input.moment}',
      '- 동행/차 무드: ${input.tea}',
      '- 식감: ${input.texture}',
      '- 계절/단맛: ${input.sweetness}',
      '- 모양/선택 성향: ${input.choiceStyle}',
      '- 자유 상황: $situationText',
      '',
      '해석된 핵심 취향:',
      if (featureLines.isEmpty)
        '- 균형 잡힌 취향'
      else
        ...featureLines.map((line) => '- $line'),
      '',
      '추천 후보 메뉴:',
      ..._profiles.map(
        (profile) =>
            '- ${profile.name} / ${profile.dagwaType}: ${profile.typeDescription} 어울리는 차는 ${profile.pairing}.',
      ),
      '',
      '판단 기준:',
      '- 추천은 다과상 구성이나 임시 이미지가 아니라 행궁다과의 실제 개별 메뉴 한 가지로 제한한다.',
      '- 감정, 동행, 맛, 식감, 계절감, 모양 선호, 자유 상황을 함께 읽되 한 가지 답변만 과하게 반영하지 않는다.',
      '- 결과 화면에는 내부 점수표나 "AI가 읽은 신호" 같은 분석 패널을 노출하지 않는다.',
      '- 설명은 피그마 결과 카드처럼 조용하고 고급스럽게 쓴다. 기술적인 말투, 과장된 마케팅 문구, 긴 목록은 피한다.',
      '',
      '출력 규칙:',
      '- profileTitle: 고객 취향을 6~10자 안팎의 부드러운 별칭으로 쓴다.',
      '- headline: "{profileTitle}에게 어울리는 오늘의 다과" 형식을 유지한다.',
      '- aiSummary: 2문장 이내로, 선택한 질문 흐름과 추천 메뉴가 자연스럽게 이어지도록 쓴다.',
      '- reasons: 추천 이유 3개를 짧게 쓴다. 메뉴 유형, 맛/식감, 방문 상황 또는 차 페어링을 각각 다룬다.',
      '- teaPairing: 함께 마시기 좋은 차 또는 곁들임 메뉴를 한 가지 제안한다.',
      '- secondaryMenuName: 차선 추천 메뉴명을 한 가지 제안한다.',
      '- packagingMessage: 구매나 공유로 이어질 수 있는 따뜻한 한 줄 문장을 쓴다.',
      '- tags: 화면 보조용 태그 3~5개만 남긴다.',
    ].join('\n');
  }

  static Map<String, int> _featuresFor(
    RecommendationInput input,
    String situation,
  ) {
    final features = <String, int>{};
    for (final answer in [
      input.personality,
      input.moment,
      input.sweetness,
      input.texture,
      input.tea,
      input.choiceStyle,
    ]) {
      _mergeFeatures(features, _answerFeatures[answer]);
    }
    _mergeFeatures(features, _situationFeatures(situation));
    return features;
  }

  static Map<String, int> _situationFeatures(String situation) {
    final normalized = situation.toLowerCase();
    final features = <String, int>{};
    if (normalized.isEmpty) return features;

    void add(String feature, int weight) =>
        _addFeature(features, feature, weight);

    if (_containsAny(normalized, ['교수', '격식', '상사', '어른'])) {
      add('elder', 2);
      add('gift', 2);
      add('safe', 2);
      add('package', 1);
      add('signature', 1);
    }
    if (_containsAny(normalized, ['부모', '가족'])) {
      add('elder', 3);
      add('warm', 1);
      add('safe', 1);
    }
    if (_containsAny(normalized, ['친구', '동료', '같이', '함께'])) {
      add('share', 3);
      add('photo', 1);
      add('cool', 1);
      add('bright', 1);
    }
    if (_containsAny(normalized, ['여행', '수원', '행궁', '기념'])) {
      add('local', 3);
      add('story', 2);
      add('package', 1);
    }
    if (_containsAny(normalized, ['빙수', '시원', '여름', '더운', '차가운'])) {
      add('icy', 4);
      add('cool', 3);
      add('fresh', 1);
    }
    if (_containsAny(normalized, ['한방', '쌍화', '깊은', '진한'])) {
      add('herbal', 4);
      add('deep', 3);
      add('bitter', 2);
    }
    if (_containsAny(normalized, ['차', '따뜻', '조용', '휴식'])) {
      add('tea', 3);
      add('warm', 3);
      add('calm', 1);
    }
    if (_containsAny(normalized, ['꽃', '화전', '사진', '예쁜', '색감'])) {
      add('photo', 4);
      add('fresh', 2);
      add('novelty', 1);
    }
    if (_containsAny(normalized, ['포장', '선물', '답례', '기념품'])) {
      add('gift', 4);
      add('package', 3);
      add('local', 1);
    }
    if (_containsAny(normalized, ['약과', '유밀과'])) {
      add('crisp', 4);
      add('sweet', 3);
      add('gift', 2);
      add('local', 2);
    }
    if (_containsAny(normalized, ['대추'])) {
      add('warm', 3);
      add('soft', 2);
      add('subtle', 2);
    }
    if (_containsAny(normalized, ['생강', '깔끔', '알싸'])) {
      add('fresh', 3);
      add('tea', 2);
      add('warm', 1);
    }
    if (_containsAny(normalized, ['녹차', '말차'])) {
      add('bitter', 4);
      add('cool', 2);
      add('subtle', 1);
    }
    if (_containsAny(normalized, ['망고'])) {
      add('sweet', 3);
      add('cool', 2);
      add('bright', 2);
    }

    return features;
  }

  static _MenuScore _scoreProfile(
    _MenuProfile profile,
    Map<String, int> features,
    String situation,
  ) {
    var score = 0;
    for (final entry in features.entries) {
      score += (profile.features[entry.key] ?? 0) * entry.value;
    }

    if (situation.contains(profile.name)) {
      score += 80;
    }

    return _MenuScore(
      profile: profile,
      score: score,
      specificScore: _specificScore(profile, features),
    );
  }

  static int _compareScores(_MenuScore a, _MenuScore b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final bySpecific = b.specificScore.compareTo(a.specificScore);
    if (bySpecific != 0) return bySpecific;
    return a.profile.name.compareTo(b.profile.name);
  }

  static int _specificScore(_MenuProfile profile, Map<String, int> features) {
    var total = 0;
    for (final feature in _specificFeatures) {
      final activeWeight = features[feature] ?? 0;
      final menuWeight = profile.features[feature] ?? 0;
      total += math.min(activeWeight, menuWeight) * 2;
    }
    return total;
  }

  static int _confidenceFor(
    List<_MenuScore> ranked,
    String productId,
    String situation,
  ) {
    final selected = ranked.firstWhere(
      (score) => score.profile.id == productId,
      orElse: () => ranked.first,
    );
    final otherTop = ranked
        .where((score) => score.profile.id != productId)
        .map((score) => score.score)
        .fold<int>(0, math.max);
    final gap = math.max(0, selected.score - otherTop);
    final contextBonus = situation.isEmpty ? 0 : 3;
    final confidence = 80 + contextBonus + math.min(10, (gap / 5).round());
    return confidence.clamp(82, 96).toInt();
  }

  static List<AiSignal> _buildSignals(
    RecommendationInput input,
    _MenuProfile selected,
    String situation,
    Map<String, int> features,
  ) {
    final featureLabels = _topFeatureLabels(selected, features);
    final signals = [
      AiSignal(label: '성향', value: input.personality, weight: 15),
      AiSignal(label: '상황', value: input.moment, weight: 15),
      AiSignal(
        label: '맛·식감',
        value: '${input.sweetness} / ${input.texture}',
        weight: 18,
      ),
      AiSignal(label: '차 취향', value: input.tea, weight: 14),
      AiSignal(label: '다과 유형', value: selected.dagwaType, weight: 88),
      if (featureLabels.isNotEmpty)
        AiSignal(label: '핵심 특징', value: featureLabels.join(' · '), weight: 92),
    ];

    if (situation.isNotEmpty) {
      signals.add(
        AiSignal(
          label: '문장 보정',
          value: _situationSignal(situation),
          weight: 24,
        ),
      );
    }

    signals.add(AiSignal(label: '최종 매칭', value: selected.name, weight: 100));
    return signals;
  }

  static String _summaryFor(
    RecommendationInput input,
    _MenuProfile selected,
    Map<String, int> features,
  ) {
    final prefix = input.situation.trim().isEmpty ? '' : '남겨주신 상황까지 함께 보면 ';
    final featureSummary = _featureSummary(selected, features);
    final arc = _preferenceArc(input);
    return '$prefix$arc $featureSummary 취향이 가장 또렷하게 읽혔어요. ${selected.name}은 ${selected.summary}';
  }

  static String _typeReason(_MenuProfile selected, Map<String, int> features) {
    final featureSummary = _featureSummary(selected, features);
    return '${selected.name}은 ${selected.typeDescription} 그래서 $featureSummary 취향과 자연스럽게 이어집니다.';
  }

  static String _tasteReason(RecommendationInput input, _MenuProfile selected) {
    switch (selected.id) {
      case 'yakgwa-story':
        return '바삭하고 결 있는 식감과 ${input.choiceStyle} 성향이 선물성, 지역성 쪽으로 이어져 행궁약과를 우선했습니다.';
      case 'flower-pancake':
        return '${input.sweetness}과 ${input.choiceStyle} 선택을 반영해 꽃의 색감과 은은한 단맛이 살아 있는 화전을 우선했습니다.';
      case 'mango-bingsu':
        return '${input.sweetness}, ${input.texture}, ${input.moment} 흐름이 달콤하고 시원하게 나누는 빙수와 잘 맞았습니다.';
      case 'green-tea-bingsu':
        return '${input.texture}은 살리면서 ${input.sweetness}을 선호하는 흐름이 녹차의 쌉싸름함과 잘 맞았습니다.';
      default:
        return '${input.sweetness}, ${input.texture} 선호가 ${selected.name}의 맛과 식감에 자연스럽게 이어집니다.';
    }
  }

  static String _preferenceArc(RecommendationInput input) {
    return '${input.personality}의 무드와 ${input.texture} 선호가 겹치면서';
  }

  static String _situationSignal(String situation) {
    if (_containsAny(situation, ['약과', '유밀과', '포장', '선물'])) {
      return '약과·포장 선호';
    }
    if (_containsAny(situation, ['교수', '격식', '상사', '어른'])) {
      return '격식 있는 선물';
    }
    if (_containsAny(situation, ['부모', '가족'])) {
      return '가족과 함께';
    }
    if (_containsAny(situation, ['빙수', '시원', '여름', '더운'])) {
      return '시원한 디저트';
    }
    if (_containsAny(situation, ['여행', '수원', '행궁', '기념'])) {
      return '수원 여행 기념';
    }
    if (_containsAny(situation, ['친구', '동료', '같이', '함께'])) {
      return '함께 나누는 메뉴';
    }
    if (_containsAny(situation, ['꽃', '화전', '사진', '예쁜', '색감'])) {
      return '보기 좋은 화전';
    }
    if (_containsAny(situation, ['한방', '쌍화', '깊은', '진한'])) {
      return '깊은 전통차';
    }
    if (_containsAny(situation, ['차', '따뜻', '조용', '휴식'])) {
      return '차분한 차 페어링';
    }
    return '자유 입력 반영';
  }

  static List<String> _topFeatureLabels(
    _MenuProfile selected,
    Map<String, int> features,
  ) {
    final matched = [
      for (final entry in features.entries)
        if ((selected.features[entry.key] ?? 0) > 0)
          MapEntry(entry.key, entry.value * selected.features[entry.key]!),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (final entry in matched.take(3))
        if (_featureLabels[entry.key] != null) _featureLabels[entry.key]!,
    ];
  }

  static String _featureSummary(
    _MenuProfile selected,
    Map<String, int> features,
  ) {
    final labels = _topFeatureLabels(selected, features);
    if (labels.isEmpty) return '균형 잡힌 취향';
    return labels.join('·');
  }

  static List<String> _promptFeatureLines(Map<String, int> features) {
    final entries = features.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in entries.take(8))
        if (_featureLabels[entry.key] != null)
          '${_featureLabels[entry.key]}: ${entry.value}',
    ];
  }

  static void _mergeFeatures(
    Map<String, int> target,
    Map<String, int>? source,
  ) {
    if (source == null) return;
    for (final entry in source.entries) {
      _addFeature(target, entry.key, entry.value);
    }
  }

  static void _addFeature(Map<String, int> target, String feature, int weight) {
    target[feature] = (target[feature] ?? 0) + weight;
  }

  static bool _containsAny(String value, List<String> keywords) {
    return keywords.any(value.contains);
  }

  static List<String> _dedupe(List<String> values) {
    final seen = <String>{};
    return [
      for (final value in values)
        if (seen.add(value)) value,
    ];
  }

  static int _hash(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash << 5) - hash) + codeUnit;
    }
    return hash;
  }
}

class _MenuProfile {
  const _MenuProfile({
    required this.id,
    required this.name,
    required this.dagwaType,
    required this.typeDescription,
    required this.profileTitle,
    required this.summary,
    required this.pairing,
    required this.message,
    required this.tags,
    required this.reasons,
    required this.features,
  });

  final String id;
  final String name;
  final String dagwaType;
  final String typeDescription;
  final String profileTitle;
  final String summary;
  final String pairing;
  final String message;
  final List<String> tags;
  final List<String> reasons;
  final Map<String, int> features;
}

class _MenuScore {
  const _MenuScore({
    required this.profile,
    required this.score,
    required this.specificScore,
  });

  final _MenuProfile profile;
  final int score;
  final int specificScore;
}
