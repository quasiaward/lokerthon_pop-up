class DagwaResult {
  const DagwaResult({
    required this.menuName,
    required this.title,
    required this.description,
    required this.pairing,
    required this.pairingDesc,
    required this.runnerUp,
    required this.runnerUpDesc,
    required this.imagePath,
  });

  final String menuName;
  final String title;
  final String description;
  final String pairing;
  final String pairingDesc;
  final String runnerUp;
  final String runnerUpDesc;
  final String imagePath;
}

const dagwaResults = <String, DagwaResult>{
  '흑임자다식': DagwaResult(
    menuName: '흑임자다식',
    title: '당신은 팔색조같은 매력을가진 흑임자다식!',
    description: '''흑임자 다식은 검은깨(흑임자)를 볶아 곱게 갈고 꿀이나 조청을 섞어 만든 전통 한과입니다.
흑임자다식은 순한 성질의 식품이며, 따뜻한 편으로 분류된다는 점에서 당신과 닮았어요!

그런데... 요즘 기력이 떨어지고 있진 않나요?
이런 면에서도 흑임자 다식과 당신은 찰떡궁합이예요!
흑임자다식은 항산화 작용, 기력보충과 혈관건강, 뼈건강에도 도움을주는 영양만점 간식이랍니다!''',
    pairing: '식혜',
    pairingDesc: '''부드럽고 고소한 흑임자 다식을 즐겼다면,
맑고 청량한 식혜로 입가심하는건 어떨까요?
산뜻한 다과 조합을 추천합니다.''',
    runnerUp: '도라지정과',
    runnerUpDesc: '''고소한 흑임자 다식을 맛봤다면,
이젠 쫄깃한 식감을 즐길 차례입니다!
건강과 맛 두마리 토끼를 잡을 수 있는 다과를 추천합니다.''',
    imagePath: 'assets/figma/result_흑임자다식.png',
  ),
  '도라지정과': DagwaResult(
    menuName: '도라지정과',
    title: '당신은 클래식한 매력을 가진 도라지정과!',
    description: '''도라지정과는 도라지를 꿀이나 조청에 오랜 시간 정성껏 졸여 만든 전통 다과입니다.
수차례 달이고 말리는 과정을 거쳐 완성되기에, 한 조각 안에 시간과 정성이 담겨 있어요.
처음부터 강렬하게 다가오기보다, 알수록 매력이 느껴지는 점은 당신과 닮아있습니다!

당신은 사람과의 관계에서도 서두르지 않습니다. 겉으로 자신을 드러내기보다는 차근차근 진심을 쌓아가며, 한 번 맺은 인연을 오래 소중히 여기는 사람이에요.
또한 화려함보다는 깊이 있는 취향을 추구하며, 유행보다 자신만의 기준과 감성을 중요하게 생각합니다.
그래서 도라지정과는 당신에게 딱 어울리는 다과예요.
은은한 달콤함처럼 부담 없이 다가가지만, 시간이 지날수록 더욱 생각나는 매력을 가지고 있으니까요.''',
    pairing: '생강차',
    pairingDesc: '도라지정과의 깊은 단맛과 쫀득한 식감을 더욱 부드럽게 즐길 수 있는 조합이에요. 따뜻한 차 한 잔과 함께하면 정과의 풍미가 더욱 오래 남습니다.',
    runnerUp: '육포다식',
    runnerUpDesc: '''도라지정과를 좋아한다면 은은한 단맛과 고소함이
매력적인 육포다식과도 잘 맞을 거예요. 씹을수록 깊어지는 풍미를 즐기는 당신에게 추천합니다.''',
    imagePath: 'assets/figma/result_도라지정과.png',
  ),
  '육포다식': DagwaResult(
    menuName: '육포다식',
    title: '당신은 독특한 4차원 육포다식!',
    description: '''육포다식은 얇게 저민 육포를 전통 다식처럼 정갈하게 담아낸 이색 다과입니다.
익숙한 재료지만 예상과는 다른 모습으로 다가오는 것처럼, 당신도 늘 남들과는 조금 다른 시선으로 세상을 바라보는 사람이에요.

당신은 틀에 맞추기보다 새로운 발상을 즐깁니다. 엉뚱한 상상도, 갑작스러운 아이디어도 당신에게는 자연스러운 일상이죠.
사람들과 함께 할때도 예상치 못한 한마디로 분위기를 바꾸고, 평범한 순간도 재미있는 추억으로 만듭니다.
자유로운 영혼처럼 보이지만, 좋아하는 것에는 누구보다 깊게 빠져드는 반전 매력도 가지고 있어요.

그래서 육포다식은 당신에게 가장 잘 어울리는 다과입니다.
익숙함 속에서 새로운 매력을 발견하게 만드는 특별한 조합처럼, 당신도 처음엔 독특하지만, 알면 알수록 빠져드는 매력을 가진 사람이니까요.''',
    pairing: '오미자차',
    pairingDesc: '''달고, 새콤하고, 쌉싸름한 여러 맛이 조화를 이루듯,
예측할 수 없는 오미자의 개성은 육포다식의 색다른 매력과도 잘 어울립니다.''',
    runnerUp: '콩고물 도라지정과',
    runnerUpDesc: '''색다른 매력을 좋아하는 당신이라면 익숙한 도라지정과에
고소한 콩고물을 더한 이 조합도 잘 어울립니다. 새로움도, 편안함도 놓치고 싶지 않은 당신에게 추천합니다.''',
    imagePath: 'assets/figma/result_육포다식.png',
  ),
  '콩고물 도라지정과': DagwaResult(
    menuName: '콩고물 도라지정과',
    title: '당신은 부드러운 인품을 가진 콩고물 도라지정과!',
    description: '''콩고물 도라지정과는 도라지를 꿀과 조청에 오랜 시간 졸인 뒤, 고소한 콩고물을 입혀 완성한 전통 다과입니다.
도라지 특유의 깊은 풍미와 쫀득한 식감, 그리고 콩고물의 부드러운 고소함이 어우러져 부담 없이 즐길 수 있는 매력을 가지고 있어요.

당신도 콩고물 도라지정과와 닮았습니다.
당신은 사람을 편안하게 만드는 힘을 가진 사람이에요. 눈에 띄게 화려하지 않아도 괜찮아요.
당신의 진짜 매력은 은은하게 스며들어 오래 남는 데 있으니까요.
콩고물 도라지정과가 부담스럽지 않은 달콤함으로 많은 사람들의 사랑을 받듯, 당신 역시 곁에 있을수록 더욱 소중하게 느껴지는 사람입니다.

혹시 아직 콩고물 도라지정과를 맛보지 못했다면 꼭 한 번 경험해 보세요. 당신과 꼭 닮은 그 부드럽고 쫀득한 매력을 발견할 수 있을 거예요!''',
    pairing: '생강차',
    pairingDesc: '''은은한 단맛과 포근한 향이 콩고물 도라지정과의 고소함을 더욱
부드럽게 감싸줍니다. 천천히 즐길수록 깊은 풍미를 느낄 수 있는 가장 편안한 조합이에요.''',
    runnerUp: '곶감 호두말이',
    runnerUpDesc: '부드럽고 따뜻한 매력을 가진 당신에게는 곶감 호두말이도 잘 어울립니다. 곶감의 은은한 단맛과 호두의 고소함이 조화를 이루어, 깊은 풍미를 느낄 수 있는 전통 다과예요.',
    imagePath: 'assets/figma/result_콩고물도라지정과.png',
  ),
  '곶감 호두말이': DagwaResult(
    menuName: '곶감 호두말이',
    title: 'TODO',
    description: 'TODO',
    pairing: '오미자차',
    pairingDesc: 'TODO',
    runnerUp: '구움 견과 강정',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_곶감호두말이.png',
  ),
  '구움 견과 강정': DagwaResult(
    menuName: '구움 견과 강정',
    title: 'TODO',
    description: 'TODO',
    pairing: '유자차',
    pairingDesc: 'TODO',
    runnerUp: '금귤정과',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_견과류.png',
  ),
  '금귤정과': DagwaResult(
    menuName: '금귤정과',
    title: 'TODO',
    description: 'TODO',
    pairing: '유자레몬차',
    pairingDesc: 'TODO',
    runnerUp: '깨강정',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_금귤정과.png',
  ),
  '깨강정': DagwaResult(
    menuName: '깨강정',
    title: 'TODO',
    description: 'TODO',
    pairing: '유자차',
    pairingDesc: 'TODO',
    runnerUp: '영양찰떡',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_깨강정.png',
  ),
  '영양찰떡': DagwaResult(
    menuName: '영양찰떡',
    title: 'TODO',
    description: 'TODO',
    pairing: 'TODO',
    pairingDesc: 'TODO',
    runnerUp: 'TODO',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_영양찰떡.png',
  ),
  '양갱': DagwaResult(
    menuName: '양갱',
    title: 'TODO',
    description: 'TODO',
    pairing: 'TODO',
    pairingDesc: 'TODO',
    runnerUp: 'TODO',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_양갱.png',
  ),
  '매작과': DagwaResult(
    menuName: '매작과',
    title: 'TODO',
    description: 'TODO',
    pairing: 'TODO',
    pairingDesc: 'TODO',
    runnerUp: '수원약과',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_매작과.png',
  ),
  '수원약과': DagwaResult(
    menuName: '수원약과',
    title: 'TODO',
    description: 'TODO',
    pairing: '녹차',
    pairingDesc: 'TODO',
    runnerUp: '흑임자다식',
    runnerUpDesc: 'TODO',
    imagePath: 'assets/figma/result_행궁약과.png',
  ),
};
