const personalityTypes = [
  '조용히 머무는 I형',
  '같이 나누는 E형',
  '차분히 음미하는 감각형',
  '이야기와 의미를 좋아하는 직관형',
];

const visitMoments = [
  '혼자 쉬고 싶어요',
  '부모님과 함께해요',
  '친구와 디저트를 먹어요',
  '작은 선물도 고려해요',
  '수원 여행 기념이에요',
];

const sweetnessPreferences = [
  '은은하고 담백한 단맛',
  '적당히 달콤한 맛',
  '확실히 달콤한 맛',
  '쌉싸름하고 깊은 맛',
];

const texturePreferences = [
  '쫀득한 떡 식감',
  '바삭하고 결 있는 식감',
  '부드럽고 촉촉한 식감',
  '시원하게 녹는 식감',
];

const teaPreferences = ['따뜻한 차와 함께', '상큼하고 산뜻하게', '한방차처럼 깊게', '차보다 시원한 메뉴'];

const choiceStyles = [
  '대표 메뉴를 고르는 편',
  '익숙하고 안정적인 메뉴',
  '새로운 메뉴도 좋아함',
  '보기 좋은 메뉴가 좋음',
];

class RecommendationInput {
  const RecommendationInput({
    required this.personality,
    required this.moment,
    required this.sweetness,
    required this.texture,
    required this.tea,
    required this.choiceStyle,
    required this.situation,
  });

  final String personality;
  final String moment;
  final String sweetness;
  final String texture;
  final String tea;
  final String choiceStyle;
  final String situation;

  RecommendationInput copyWith({
    String? personality,
    String? moment,
    String? sweetness,
    String? texture,
    String? tea,
    String? choiceStyle,
    String? situation,
  }) {
    return RecommendationInput(
      personality: personality ?? this.personality,
      moment: moment ?? this.moment,
      sweetness: sweetness ?? this.sweetness,
      texture: texture ?? this.texture,
      tea: tea ?? this.tea,
      choiceStyle: choiceStyle ?? this.choiceStyle,
      situation: situation ?? this.situation,
    );
  }
}

class RecommendationResult {
  const RecommendationResult({
    required this.productId,
    required this.productName,
    required this.dagwaType,
    required this.typeDescription,
    required this.profileTitle,
    required this.headline,
    required this.aiSummary,
    required this.confidence,
    required this.signals,
    required this.analysisSteps,
    required this.reasons,
    required this.teaPairing,
    required this.secondaryMenuName,
    required this.packagingMessage,
    required this.tags,
  });

  final String productId;
  final String productName;
  final String dagwaType;
  final String typeDescription;
  final String profileTitle;
  final String headline;
  final String aiSummary;
  final int confidence;
  final List<AiSignal> signals;
  final List<String> analysisSteps;
  final List<String> reasons;
  final String teaPairing;
  final String secondaryMenuName;
  final String packagingMessage;
  final List<String> tags;
}

class AiSignal {
  const AiSignal({
    required this.label,
    required this.value,
    required this.weight,
  });

  final String label;
  final String value;
  final int weight;
}
