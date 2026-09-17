import '../l10n/lang.dart';

/// 추천 결과 한 건.
///
/// [menuName]과 [runnerUp]은 **로직 키**다. `dagwaResults`의 맵 키,
/// `toneFor()`의 조회 키, 추천 엔진이 돌려주는 값이 모두 이 한국어 문자열이므로
/// 번역하지 않는다. 화면에 보이는 이름은 [name]이 따로 갖는다.
class DagwaResult {
  const DagwaResult({
    required this.menuName,
    required this.name,
    required this.title,
    required this.description,
    required this.pairing,
    required this.pairingDesc,
    required this.runnerUp,
    required this.runnerUpDesc,
    required this.imagePath,
  });

  /// 로직 키 (한국어 고정).
  final String menuName;

  /// 화면에 보이는 다과 이름.
  final L10nText name;

  /// 결과 화면의 한 줄 리드.
  final L10nText title;

  /// 상세 시트의 본문.
  final L10nText description;

  /// 어울리는 차 이름.
  final L10nText pairing;
  final L10nText pairingDesc;

  /// 로직 키 (한국어 고정). 표시할 때는 이 키로 찾은 결과의 [name]을 쓴다.
  final String runnerUp;
  final L10nText runnerUpDesc;

  final String imagePath;
}

const dagwaResults = <String, DagwaResult>{
  '흑임자다식': DagwaResult(
    menuName: '흑임자다식',
    name: L10nText('흑임자다식', 'Black Sesame Dasik', '黒ごま茶食'),
    title: L10nText(
      '당신은 팔색조같은 매력을가진 흑임자다식!',
      'You are Black Sesame Dasik — quietly full of surprises.',
      'あなたは多彩な魅力をもつ黒ごま茶食！',
    ),
    description: L10nText(
      '''흑임자 다식은 검은깨(흑임자)를 볶아 곱게 갈고 꿀이나 조청을 섞어 만든 전통 한과입니다.
흑임자다식은 순한 성질의 식품이며, 따뜻한 편으로 분류된다는 점에서 당신과 닮았어요!

그런데... 요즘 기력이 떨어지고 있진 않나요?
이런 면에서도 흑임자 다식과 당신은 찰떡궁합이예요!
흑임자다식은 항산화 작용, 기력보충과 혈관건강, 뼈건강에도 도움을주는 영양만점 간식이랍니다!''',
      '''Black sesame dasik is made by roasting black sesame, grinding it fine, and binding it with honey or grain syrup.
It is gentle by nature and counted among the warming foods — much like you.

By the way… have you been running a little low on energy lately?
That is one more thing the two of you have in common.
Black sesame dasik is rich in antioxidants and supports your stamina, circulation and bone health.''',
      '''黒ごま茶食は、黒ごまを香ばしく炒ってすり潰し、蜂蜜や水飴で練り固めた伝統菓子です。
穏やかな性質をもち、体を温める食べものに分類される点が、あなたによく似ています。

ところで……最近、少し疲れが溜まっていませんか？
その点でも、黒ごま茶食とあなたは相性抜群です。
抗酸化作用があり、滋養強壮や血管・骨の健康にも役立つ、栄養満点のおやつなんです。''',
    ),
    pairing: L10nText('식혜', 'Sikhye', 'シッケ'),
    pairingDesc: L10nText(
      '''부드럽고 고소한 흑임자 다식을 즐겼다면,
맑고 청량한 식혜로 입가심하는건 어떨까요?
산뜻한 다과 조합을 추천합니다.''',
      '''After the soft, nutty richness of black sesame dasik,
let a glass of clear, cool sikhye refresh your palate.
A bright and clean way to finish.''',
      '''香ばしくまろやかな黒ごま茶食を味わったあとは、
澄んで爽やかなシッケで口直しはいかがでしょう。
すっきりとした組み合わせをおすすめします。''',
    ),
    runnerUp: '도라지정과',
    runnerUpDesc: L10nText(
      '''고소한 흑임자 다식을 맛봤다면,
이젠 쫄깃한 식감을 즐길 차례입니다!
건강과 맛 두마리 토끼를 잡을 수 있는 다과를 추천합니다.''',
      '''Now that you have tasted something nutty and smooth,
it is time for a chewier bite.
A sweet that brings health and flavour together.''',
      '''香ばしい黒ごま茶食を味わったら、
次はもちもちの食感を楽しむ番です。
健康とおいしさを両立した一品をおすすめします。''',
    ),
    imagePath: 'assets/figma/result_흑임자다식.png',
  ),
  '도라지정과': DagwaResult(
    menuName: '도라지정과',
    name: L10nText('도라지정과', 'Bellflower Jeonggwa', '桔梗の蜜煮'),
    title: L10nText(
      '당신은 클래식한 매력을 가진 도라지정과!',
      'You are Bellflower Root Jeonggwa — a classic that grows on you.',
      'あなたはクラシックな魅力をもつ桔梗の蜜煮！',
    ),
    description: L10nText(
      '''도라지정과는 도라지를 꿀이나 조청에 오랜 시간 정성껏 졸여 만든 전통 다과입니다.
수차례 달이고 말리는 과정을 거쳐 완성되기에, 한 조각 안에 시간과 정성이 담겨 있어요.
처음부터 강렬하게 다가오기보다, 알수록 매력이 느껴지는 점은 당신과 닮아있습니다!

당신은 사람과의 관계에서도 서두르지 않습니다. 겉으로 자신을 드러내기보다는 차근차근 진심을 쌓아가며, 한 번 맺은 인연을 오래 소중히 여기는 사람이에요.
또한 화려함보다는 깊이 있는 취향을 추구하며, 유행보다 자신만의 기준과 감성을 중요하게 생각합니다.
그래서 도라지정과는 당신에게 딱 어울리는 다과예요.
은은한 달콤함처럼 부담 없이 다가가지만, 시간이 지날수록 더욱 생각나는 매력을 가지고 있으니까요.''',
      '''Bellflower root jeonggwa is made by simmering bellflower root slowly in honey or grain syrup.
It is boiled and dried again and again, so every piece holds hours of patient work.
It does not announce itself all at once — it grows on you. That is very much like you.

You never rush your relationships. Rather than putting yourself on display,
you build trust a little at a time and hold on to the people you have let in.
You prefer depth to spectacle, and your own taste to whatever happens to be in fashion.
That is why this is your sweet.
Its gentle sweetness is easy to meet, and harder and harder to forget.''',
      '''桔梗の蜜煮は、桔梗の根を蜂蜜や水飴でじっくりと煮詰めて作る伝統菓子です。
何度も煮ては干す工程を重ねるため、ひと切れに時間と手間が詰まっています。
はじめから強く主張せず、知るほどに惹かれていく——そんなところがあなたに似ています。

あなたは人との関係を急ぎません。自分を大きく見せるより、少しずつ誠実さを積み重ね、
一度結んだ縁を長く大切にする人です。
華やかさよりも深みのある好みを大事にし、流行より自分の基準を信じています。
だからこそ、桔梗の蜜煮はあなたにぴったりの菓子です。
控えめな甘さのように気負わず近づき、時が経つほど恋しくなる魅力をもっているのですから。''',
    ),
    pairing: L10nText('생강차', 'Ginger Tea', '生姜茶'),
    pairingDesc: L10nText(
      '도라지정과의 깊은 단맛과 쫀득한 식감을 더욱 부드럽게 즐길 수 있는 조합이에요. 따뜻한 차 한 잔과 함께하면 정과의 풍미가 더욱 오래 남습니다.',
      'This pairing softens the deep sweetness and chewy bite of the jeonggwa. With a warm cup beside it, the flavour lingers far longer.',
      '桔梗の蜜煮の深い甘さともちもちの食感を、よりまろやかに楽しめる組み合わせです。温かいお茶を添えると、余韻がいっそう長く続きます。',
    ),
    runnerUp: '육포다식',
    runnerUpDesc: L10nText(
      '''도라지정과를 좋아한다면 은은한 단맛과 고소함이
매력적인 육포다식과도 잘 맞을 거예요. 씹을수록 깊어지는 풍미를 즐기는 당신에게 추천합니다.''',
      '''If this one suits you, beef jerky dasik will too —
quietly sweet, savoury, and deeper with every chew.''',
      '''桔梗の蜜煮がお好みなら、ほのかな甘さと香ばしさをもつ
干し肉茶食もきっと合います。噛むほどに深まる風味を楽しむあなたにおすすめです。''',
    ),
    imagePath: 'assets/figma/result_도라지정과.png',
  ),
  '육포다식': DagwaResult(
    menuName: '육포다식',
    name: L10nText('육포다식', 'Beef Jerky Dasik', '干し肉茶食'),
    title: L10nText(
      '당신은 독특한 4차원 육포다식!',
      'You are Beef Jerky Dasik — delightfully off the beaten path.',
      'あなたは個性派の干し肉茶食！',
    ),
    description: L10nText(
      '''육포다식은 얇게 저민 육포를 전통 다식처럼 정갈하게 담아낸 이색 다과입니다.
익숙한 재료지만 예상과는 다른 모습으로 다가오는 것처럼, 당신도 늘 남들과는 조금 다른 시선으로 세상을 바라보는 사람이에요.

당신은 틀에 맞추기보다 새로운 발상을 즐깁니다. 엉뚱한 상상도, 갑작스러운 아이디어도 당신에게는 자연스러운 일상이죠.
사람들과 함께 할때도 예상치 못한 한마디로 분위기를 바꾸고, 평범한 순간도 재미있는 추억으로 만듭니다.
자유로운 영혼처럼 보이지만, 좋아하는 것에는 누구보다 깊게 빠져드는 반전 매력도 가지고 있어요.

그래서 육포다식은 당신에게 가장 잘 어울리는 다과입니다.
익숙함 속에서 새로운 매력을 발견하게 만드는 특별한 조합처럼, 당신도 처음엔 독특하지만, 알면 알수록 빠져드는 매력을 가진 사람이니까요.''',
      '''Beef jerky dasik takes thinly sliced dried beef and presses it into the neat form of a traditional dasik.
A familiar ingredient arriving in an unfamiliar shape — rather like the way you see the world.

You would rather invent than fit a mould. Odd daydreams and sudden ideas are ordinary days for you.
In a group, one unexpected remark from you can turn the whole mood, and a plain moment into a story worth retelling.
You look like a free spirit, yet when something captures you, nobody falls deeper.

That is why this is your sweet.
Like a pairing that finds something new inside something familiar, you are unusual at first
and more and more compelling the longer anyone knows you.''',
      '''干し肉茶食は、薄く削いだ干し肉を伝統的な茶食のように端正に整えた、ひと味違う菓子です。
馴染みのある素材が思いがけない姿で現れるように、あなたもいつも人とは少し違う視点で世界を見ています。

型にはまるより、新しい発想を楽しむ人。突拍子もない想像も、ふいに浮かぶアイデアも、あなたには日常です。
人といるときも、思いがけないひと言で場の空気を変え、平凡な瞬間を面白い思い出に変えてしまいます。
自由な魂に見えて、好きなものには誰よりも深くのめり込む——そんな意外性も持ち合わせています。

だからこそ、干し肉茶食はあなたに最もよく似合う菓子です。
馴染みの中に新しさを見つけさせる特別な組み合わせのように、
あなたも最初は個性的で、知るほどに惹き込まれる魅力をもつ人なのですから。''',
    ),
    pairing: L10nText('오미자차', 'Omija Tea', 'オミジャ茶'),
    pairingDesc: L10nText(
      '''달고, 새콤하고, 쌉싸름한 여러 맛이 조화를 이루듯,
예측할 수 없는 오미자의 개성은 육포다식의 색다른 매력과도 잘 어울립니다.''',
      '''Sweet, tart and faintly bitter all at once —
omija is as unpredictable as this sweet, and the two get along beautifully.''',
      '''甘み、酸味、ほろ苦さが響き合うように、
読めないオミジャの個性は、干し肉茶食の風変わりな魅力とよく合います。''',
    ),
    runnerUp: '콩고물 도라지정과',
    runnerUpDesc: L10nText(
      '''색다른 매력을 좋아하는 당신이라면 익숙한 도라지정과에
고소한 콩고물을 더한 이 조합도 잘 어울립니다. 새로움도, 편안함도 놓치고 싶지 않은 당신에게 추천합니다.''',
      '''If you enjoy a twist, try familiar bellflower jeonggwa dusted
with nutty soybean powder — new and comforting at the same time.''',
      '''ひと味違う魅力を好むあなたなら、馴染みの桔梗の蜜煮に
香ばしいきな粉をまとわせたこの一品もぴったり。新しさも心地よさも手放したくないあなたへ。''',
    ),
    imagePath: 'assets/figma/result_육포다식.png',
  ),
  '콩고물 도라지정과': DagwaResult(
    menuName: '콩고물 도라지정과',
    name: L10nText('콩고물 도라지정과', 'Soybean Bellflower Jeonggwa', 'きな粉桔梗の蜜煮'),
    title: L10nText(
      '당신은 부드러운 인품을 가진 콩고물 도라지정과!',
      'You are Soybean-Dusted Bellflower Jeonggwa — gentle and easy to be around.',
      'あなたは柔らかな人柄のきな粉桔梗の蜜煮！',
    ),
    description: L10nText(
      '''콩고물 도라지정과는 도라지를 꿀과 조청에 오랜 시간 졸인 뒤, 고소한 콩고물을 입혀 완성한 전통 다과입니다.
도라지 특유의 깊은 풍미와 쫀득한 식감, 그리고 콩고물의 부드러운 고소함이 어우러져 부담 없이 즐길 수 있는 매력을 가지고 있어요.

당신도 콩고물 도라지정과와 닮았습니다.
당신은 사람을 편안하게 만드는 힘을 가진 사람이에요. 눈에 띄게 화려하지 않아도 괜찮아요.
당신의 진짜 매력은 은은하게 스며들어 오래 남는 데 있으니까요.
콩고물 도라지정과가 부담스럽지 않은 달콤함으로 많은 사람들의 사랑을 받듯, 당신 역시 곁에 있을수록 더욱 소중하게 느껴지는 사람입니다.

혹시 아직 콩고물 도라지정과를 맛보지 못했다면 꼭 한 번 경험해 보세요. 당신과 꼭 닮은 그 부드럽고 쫀득한 매력을 발견할 수 있을 거예요!''',
      '''This sweet simmers bellflower root slowly in honey and grain syrup, then finishes it in a coat of nutty soybean powder.
The root's deep flavour and chewy bite meet the soft, toasty dusting — easy to enjoy, easy to keep enjoying.

You are much the same.
You have a way of putting people at ease. You do not need to be the brightest thing in the room.
Your real charm seeps in gently and stays a long time.
Just as this sweet is loved for a sweetness that never overwhelms,
you are the kind of person who feels more precious the longer someone is near you.

If you have not tried it yet, do. You will find the same soft, chewy charm you carry yourself.''',
      '''きな粉桔梗の蜜煮は、桔梗の根を蜂蜜と水飴でじっくり煮詰め、香ばしいきな粉をまとわせた伝統菓子です。
桔梗ならではの深い風味ともちもちの食感、きな粉のやさしい香ばしさが重なり、気負わず楽しめる一品です。

あなたも、この菓子によく似ています。
そばにいる人をほっとさせる力をもつ人。派手に目立たなくても構いません。
あなたの本当の魅力は、静かに沁みて長く残るところにあるのですから。
この菓子が重すぎない甘さで多くの人に愛されるように、
あなたもまた、一緒にいるほど大切に思えてくる人です。

まだ味わったことがなければ、ぜひ一度。あなたによく似た、やわらかでもちもちの魅力に出会えるはずです。''',
    ),
    pairing: L10nText('생강차', 'Ginger Tea', '生姜茶'),
    pairingDesc: L10nText(
      '''은은한 단맛과 포근한 향이 콩고물 도라지정과의 고소함을 더욱
부드럽게 감싸줍니다. 천천히 즐길수록 깊은 풍미를 느낄 수 있는 가장 편안한 조합이에요.''',
      '''A quiet sweetness and a warm aroma wrap around the toasty soybean coating.
The slower you take it, the deeper it gets — the most comfortable pairing here.''',
      '''ほのかな甘さとあたたかな香りが、きな粉の香ばしさをやさしく包みます。
ゆっくり味わうほど深い風味が立ちのぼる、いちばん穏やかな組み合わせです。''',
    ),
    runnerUp: '곶감 호두말이',
    runnerUpDesc: L10nText(
      '부드럽고 따뜻한 매력을 가진 당신에게는 곶감 호두말이도 잘 어울립니다. 곶감의 은은한 단맛과 호두의 고소함이 조화를 이루어, 깊은 풍미를 느낄 수 있는 전통 다과예요.',
      'Dried persimmon and walnut roll suits your soft, warm character too — the quiet sweetness of persimmon meeting the richness of walnut.',
      'やわらかであたたかな魅力をもつあなたには、干し柿のくるみ巻きもよく似合います。干し柿のほのかな甘さとくるみの香ばしさが調和した、深い風味の伝統菓子です。',
    ),
    imagePath: 'assets/figma/result_콩고물도라지정과.png',
  ),
  '곶감 호두말이': DagwaResult(
    menuName: '곶감 호두말이',
    name: L10nText('곶감 호두말이', 'Persimmon Walnut Roll', '干し柿のくるみ巻き'),
    title: L10nText(
      '당신은 다과계의 브레인, 곶감 호두말이!',
      'You are the Dried Persimmon & Walnut Roll — the thinker of the tea table.',
      'あなたは菓子界の頭脳、干し柿のくるみ巻き！',
    ),
    description: L10nText(
      '''곶감 호두말이는 잘 말린 곶감 속에 호두를 넣어 만든 전통 다과입니다.
복잡한 재료를 사용하지 않지만, 곶감의 은은한 단맛과 호두의 고소함이 만나 깊고 조화로운 맛을 만들어냅니다.

당신도 곶감 호두말이와 닮았습니다.
무엇이든 감정보다 이성으로 한 번 더 생각해 보고, 여러 관점에서 상황을 살펴보는 능력이 뛰어난 사람이에요.
사람들은 종종 당신에게 조언을 구하거나 의견을 묻곤 합니다.

하지만 단순히 똑똑하기만 한 사람은 아니에요. 곶감의 달콤함처럼 따뜻한 배려를 품고 있고, 호두처럼 알찬 내면을 가진 사람이기도 합니다.

겉으로 드러나는 화려함보다 내실을 중요하게 생각하는 당신.
그래서 곶감 호두말이는 당신에게 꼭 어울리는 다과입니다.
한입은 달콤하고, 한입은 고소한 곶감 호두말이처럼 당신 역시 알면 알수록 매력이 발견되는 사람이니까요''',
      '''A well-dried persimmon wrapped around a walnut — that is the whole recipe.
Nothing complicated, and yet the persimmon's quiet sweetness and the walnut's richness make something deep and balanced.

You are much the same.
You think things through with your head before your heart, and you are unusually good at turning a situation over and looking at it from several sides.
People come to you for advice.

But you are not only clever. Like the sweetness of the persimmon, you carry real warmth,
and like the walnut, there is substance inside.

You care about what is real rather than what glitters.
That is why this is your sweet.
One bite sweet, the next bite rich — and, like you, more rewarding the better you are known.''',
      '''干し柿のくるみ巻きは、よく干した柿でくるみを巻いた伝統菓子です。
複雑な材料は使わないのに、干し柿のほのかな甘さとくるみの香ばしさが出会い、深く調和した味わいが生まれます。

あなたも、この菓子に似ています。
何ごとも感情より理性でもう一度考え、複数の視点から状況を見渡せる人。
人はしばしば、あなたに助言や意見を求めます。

けれど、ただ賢いだけの人ではありません。干し柿の甘さのようなあたたかい気遣いをもち、
くるみのように中身の詰まった人でもあります。

見た目の華やかさより、実のあることを大切にするあなた。
だからこそ、干し柿のくるみ巻きはあなたにぴったりです。
ひと口は甘く、ひと口は香ばしい——知るほどに魅力が見つかるところまで、よく似ています。''',
    ),
    pairing: L10nText('오미자차', 'Omija Tea', 'オミジャ茶'),
    pairingDesc: L10nText(
      '''달콤한 곶감과 고소한 호두의 풍미를 깔끔하게 정리해 주는
차입니다. 다섯 가지 맛이 어우러진 오미자차처럼 다양한 관점을
가진 당신과도 잘 어울리는 조합이에요.''',
      '''A tea that tidies up the sweet persimmon and rich walnut cleanly.
Omija holds five tastes at once — much like the many angles
you are able to hold in mind.''',
      '''甘い干し柿と香ばしいくるみの風味を、すっきりと整えてくれるお茶です。
五つの味が溶け合うオミジャ茶のように、
多様な視点をもつあなたにもよく似合う組み合わせです。''',
    ),
    runnerUp: '견과류 강정',
    runnerUpDesc: L10nText(
      '''바삭한 식감 속에 다양한 견과류가 담겨 있어, 하나의 답보다 여러 가능성을 탐구하는 당신의 성향과 닮았습니다.
곶감 호두말이가 깊이 있는 통찰력이라면, 견과류 강정은 호기심과 탐구심을 담은 다과입니다. 🥜✨''',
      '''A crisp bite holding many different nuts at once — like your habit of chasing several possibilities instead of settling on one answer.
If the persimmon roll is deep insight, nut gangjeong is curiosity. 🥜✨''',
      '''さくっとした食感の中にさまざまなナッツが詰まっていて、
ひとつの答えより複数の可能性を探るあなたの性質に似ています。
干し柿のくるみ巻きが洞察なら、ナッツおこしは好奇心と探究心の菓子です。🥜✨''',
    ),
    imagePath: 'assets/figma/result_곶감호두말이.png',
  ),
  '구움 견과 강정': DagwaResult(
    menuName: '구움 견과 강정',
    name: L10nText('구움 견과 강정', 'Roasted Nut Gangjeong', '焼きナッツおこし'),
    title: L10nText(
      '당신은 매력이 넘치는 인기쟁이, 구움 견과 강정!',
      'You are Roasted Nut Gangjeong — everybody\'s favourite.',
      'あなたは魅力あふれる人気者、焼きナッツおこし！',
    ),
    description: L10nText(
      '''구움견과는 다양한 견과류를 정성껏 구워 만든 전통 간식입니다.
아몬드, 호두, 캐슈넛 등 각기 다른 매력을 가진 견과들이 한데 모여 조화를 이루듯,
구움견과는 한 가지 매력으로 설명하기 어려운 다과예요.

당신도 구움견과와 닮았습니다.
사람들과 자연스럽게 어울리고, 어디에서든 자신만의 분위기를 만들어내는 매력 부자예요. 밝은 에너지와 친화력으로 주변 사람들에게 좋은 인상을 남기며, 함께 있으면 즐겁고 편안한 사람이기도 합니다.

구움견과가 여러 견과의 매력을 한 번에 즐길 수 있는 다과라면,
당신은 여러 가지 매력을 자연스럽게 품고 있는 사람입니다.
그래서 사람들은 당신과 함께하는 시간을 좋아합니다.

한 번의 만남으로 끝나지 않고, 자꾸 찾게 되는 이유가 분명 있으니까요!''',
      '''Roasted nut gangjeong gathers carefully toasted nuts into one traditional snack.
Almonds, walnuts, cashews — each with its own character, all in harmony.
It is not a sweet you can sum up in a single word.

Neither are you.
You fall in with people easily and carry your own atmosphere wherever you go.
Your brightness and warmth leave a good impression, and time with you is easy time.

If this sweet lets you enjoy several nuts at once,
you are someone who holds several charms at once without trying.
That is why people like being around you.

One meeting is never quite enough — and there is a reason for that.''',
      '''焼きナッツおこしは、さまざまなナッツをていねいに焼き上げて作る伝統的なおやつです。
アーモンド、くるみ、カシューナッツ——それぞれ異なる魅力をもつナッツが集まって調和するように、
ひとつの魅力では言い表せない菓子です。

あなたも、この菓子に似ています。
人と自然に打ち解け、どこにいても自分らしい空気をつくる魅力の持ち主。
明るいエネルギーと親しみやすさで良い印象を残し、一緒にいると楽しく心地よい人です。

焼きナッツおこしが複数のナッツの魅力を一度に楽しめる菓子なら、
あなたはいくつもの魅力を自然に併せもつ人。
だから人は、あなたと過ごす時間が好きなのです。

一度会って終わりにならない理由が、きっとあります。''',
    ),
    pairing: L10nText('유자차', 'Yuja Tea', '柚子茶'),
    pairingDesc: L10nText(
      '''상큼한 향과 달콤한 맛이 구움견과의 고소함을 더욱 돋보이게
해줍니다. 밝고 긍정적인 매력을 가진 당신처럼, 기분 좋은
에너지를 전해주는 조합이에요.''',
      '''A bright aroma and gentle sweetness lift the toasted nuts.
Like your own sunny streak, this pairing hands over
a little good energy.''',
      '''爽やかな香りと甘さが、焼きナッツの香ばしさをいっそう引き立てます。
明るく前向きなあなたのように、
心地よいエネルギーを届けてくれる組み合わせです。''',
    ),
    runnerUp: '금귤정과',
    runnerUpDesc: L10nText(
      '''첫인상부터 사람들의 시선을 사로잡는 매력이 있다는 점에서
당신과도 닮아 있어요. 구움견과가 다채로운 매력의 소유자라면, 금귤정과는 톡톡 튀는 상큼한 매력을 가진 다과입니다. 🍊✨''',
      '''It catches the eye from the first glance, much as you do.
If nut gangjeong is many charms at once, kumquat jeonggwa is one bright, zesty spark. 🍊✨''',
      '''第一印象で人の視線をつかむところが、あなたに似ています。
焼きナッツおこしが多彩な魅力なら、金柑の蜜煮は弾けるような爽やかさをもつ菓子です。🍊✨''',
    ),
    imagePath: 'assets/figma/result_견과류.png',
  ),
  '금귤정과': DagwaResult(
    menuName: '금귤정과',
    name: L10nText('금귤정과', 'Kumquat Jeonggwa', '金柑の蜜煮'),
    title: L10nText(
      '당신은 상큼발랄한 매력을 가진 금귤정과!',
      'You are Kumquat Jeonggwa — bright, zesty and hard to miss.',
      'あなたは爽やかで快活な金柑の蜜煮！',
    ),
    description: L10nText(
      '''금귤정과는 금귤을 꿀과 조청에 천천히 졸여 만든 전통 다과입니다.

작고 귀여운 모양 속에 상큼함과 달콤함을 모두 담고 있어, 한입 먹는 순간 기분까지 밝아지는 매력을 가지고 있어요.

당신도 금귤정과와 닮았습니다.
밝고 긍정적인 에너지로 주변 분위기를 환하게 만드는 사람이에요. 처음 만난 사람과도 금세 친해지고, 어디에서든 자연스럽게 웃음을 만들어내는 재주가 있습니다.
또한 새로운 경험을 즐기고 호기심이 많아, 늘 주변에 활력을 불어넣어 줍니다.

금귤정과가 작지만 강한 존재감을 가진 다과라면,
당신 역시 작은 행동 하나만으로도 주변에 긍정적인 영향을 주는 사람입니다.

상큼한 첫인상과 달콤한 뒷맛처럼, 알면 알수록 더 매력적인 사람이기도 하고요!''',
      '''Kumquat jeonggwa is made by simmering whole kumquats slowly in honey and grain syrup.

Small and neat, it holds both tartness and sweetness — one bite and the day looks brighter.

You are much the same.
You light up a room with easy, positive energy. You make friends with strangers quickly,
and you have a talent for producing laughter wherever you happen to be.
Curious and fond of new things, you keep the people around you awake.

If this sweet is small but impossible to overlook,
you are someone whose smallest gesture leaves a mark.

A zesty first impression, a sweet finish — and more charming the better you are known.''',
      '''金柑の蜜煮は、金柑を蜂蜜と水飴でゆっくり煮詰めて作る伝統菓子です。

小さく愛らしい姿の中に爽やかさと甘さを併せもち、ひと口で気分まで明るくしてくれます。

あなたも、この菓子に似ています。
明るく前向きなエネルギーで、その場の空気をぱっと晴らす人。初対面の相手ともすぐ打ち解け、
どこにいても自然と笑いを生み出す才があります。
新しい経験を楽しみ、好奇心が旺盛で、まわりにいつも活気を運びます。

金柑の蜜煮が小さくても強い存在感をもつ菓子なら、
あなたもまた、ささやかな行動ひとつで周囲によい影響を与える人です。

爽やかな第一印象と甘い後味のように、知るほどに惹かれる人でもあります。''',
    ),
    pairing: L10nText('석류레몬차', 'Pomegranate Lemon Tea', 'ザクロレモン茶'),
    pairingDesc: L10nText(
      '''상큼한 금귤정과와 새콤달콤한 석류레몬차의 조합은 기분까지
산뜻하게 만들어 줍니다.
톡톡 튀는 매력을 가진 당신에게 딱 어울리는 조합이에요.''',
      '''Zesty kumquat with a sweet-tart pomegranate lemon tea
leaves everything feeling a little fresher.
A pairing that matches your spark exactly.''',
      '''爽やかな金柑の蜜煮と甘酸っぱいザクロレモン茶の組み合わせは、
気分までさっぱりと晴らしてくれます。
弾けるような魅力をもつあなたにぴったりです。''',
    ),
    runnerUp: '깨강정',
    runnerUpDesc: L10nText(
      '''고소한 깨를 조청으로 엮어 만든 깨강정은 바삭한 식감과 달콤한
풍미가 매력인 전통 다과입니다. 금귤정과가 상큼한 첫인상이라면
깨강정은 기분 좋은 에너지와 유쾌함을 가진 다과예요. ✨🌾''',
      '''Sesame gangjeong binds toasted sesame with grain syrup — crisp,
sweet and moreish. If kumquat is the zesty first impression,
sesame gangjeong is cheerful company. ✨🌾''',
      '''香ばしいごまを水飴で固めたごまおこしは、さくっとした食感と
やさしい甘さが魅力の伝統菓子です。金柑の蜜煮が爽やかな第一印象なら、
ごまおこしは心地よい元気と楽しさをくれる菓子です。✨🌾''',
    ),
    imagePath: 'assets/figma/result_금귤정과.png',
  ),
  '깨강정': DagwaResult(
    menuName: '깨강정',
    name: L10nText('깨강정', 'Sesame Gangjeong', 'ごまおこし'),
    title: L10nText(
      '당신은 깨발랄한 매력을 가진 깨강정!',
      'You are Sesame Gangjeong — small joys, stacked high.',
      'あなたは陽気な魅力のごまおこし！',
    ),
    description: L10nText(
      '''작은 깨알들이 모여 단단한 강정이 되듯, 깨강정은 소소한 즐거움과 긍정적인 에너지가 모여 만들어진 전통다과입니다. 바삭한 식감과 달콤한 맛 덕분에 한입 먹으면 기분까지 좋아집니다.

당신도 깨강정과 닮았습니다.
언제 어디서나 밝은 에너지를 뿜어내며 주변 사람들에게 웃음을 전하는 사람이에요. 사소한 일에서도 재미를 발견하고, 평범한 하루를 특별하게 만드는 재주를 가지고 있습니다.
또한 사람들과 어울리는 것을 좋아하고, 특유의 친근함으로 금세 분위기를 편안하게 만들어요.

가벼워 보일 수 있지만 의외로 끈기와 책임감도 갖추고 있습니다. 깨알 같은 노력들이 쌓여 결국 큰 결과를 만들어내는 사람이죠.

깨강정이 한 조각만 먹어도 자꾸 손이 가는 다과라면, 당신 역시 한 번 만나면 계속 생각나는 매력을 가진 사람입니다.''',
      '''Countless tiny sesame seeds press together into something solid — small pleasures and good energy, gathered into one sweet. Crisp and gently sweet, one bite lifts the mood.

You are much the same.
Wherever you are, you give off light and hand laughter to the people near you. You find the fun in small things and have a knack for making an ordinary day feel like an occasion.
You like company, and your particular warmth settles a room quickly.

You may look easy-going, but there is more grit in you than people expect. Seed-sized efforts, stacked patiently, are how you arrive at large results.

If one piece of sesame gangjeong is never quite enough, neither is one meeting with you.''',
      '''小さなごま粒が寄り集まって固い菓子になるように、ごまおこしは、ささやかな楽しさと前向きなエネルギーが集まってできた伝統菓子です。さくっとした食感とやさしい甘さで、ひと口食べれば気分まで明るくなります。

あなたも、この菓子に似ています。
いつでもどこでも明るいエネルギーを放ち、まわりに笑顔を届ける人。ささいなことにも面白さを見つけ、平凡な一日を特別に変える才があります。
人と過ごすことを好み、持ち前の親しみやすさで、すぐに場をなごませます。

軽やかに見えて、意外なほど粘り強く責任感もある人。ごま粒のような努力を積み重ね、やがて大きな結果を生み出します。

ひと切れでは手が止まらないごまおこしのように、あなたも一度会えば思い出してしまう魅力の持ち主です。''',
    ),
    pairing: L10nText('유자차', 'Yuja Tea', '柚子茶'),
    pairingDesc: L10nText(
      '''달콤하고 고소한 깨강정에 상큼한 유자 향이 더해지면 더욱
산뜻하게 즐길 수 있습니다.
밝고 경쾌한 매력을 가진 당신과도 잘 어울리는 조합이에요.''',
      '''A bright citron aroma over sweet, toasted sesame
keeps everything light on the palate.
It suits your cheerful, quick-footed charm.''',
      '''甘く香ばしいごまおこしに爽やかな柚子の香りが加わると、
いっそう軽やかに楽しめます。
明るく快活なあなたにもよく似合う組み合わせです。''',
    ),
    runnerUp: '영양찰떡',
    runnerUpDesc: L10nText(
      '''깨강정이 톡톡 튀는 밝은 에너지를 가진 다과라면, 영양찰떡은
든든하고 따뜻한 매력을 가진 다과예요. 필요할 때는 누구보다
든든한 존재가 되어주는 당신의 모습과도 닮았습니다.''',
      '''If sesame gangjeong is bright, quick energy, the nutty rice cake
is steady warmth — the way you become the most dependable
person in the room exactly when it matters.''',
      '''ごまおこしが弾けるような明るさなら、栄養もちは
どっしりとあたたかな魅力の菓子です。いざというとき
誰よりも頼りになるあなたの姿にも重なります。''',
    ),
    imagePath: 'assets/figma/result_깨강정.png',
  ),
  '영양찰떡': DagwaResult(
    menuName: '영양찰떡',
    name: L10nText('영양찰떡', 'Nutty Rice Cake', '栄養もち'),
    title: L10nText(
      '당신은 언제나 든든한 영양찰떡!',
      'You are the Nutty Rice Cake — steady, always.',
      'あなたはいつも頼もしい栄養もち！',
    ),
    description: L10nText(
      '''영양찰떡은 찹쌀에 견과류와 곡물을 아낌없이 넣어 쪄낸 전통 다과입니다.
든든한 한 조각만으로도 오랫동안 포만감과 에너지를 채워주는 것처럼,
당신은 주변 사람들에게 믿음과 안정감을 주는 존재이자 리더입니다.
어려운 상황에서도 중심을 잡고, 사람들을 자연스럽게 이끌어가는 힘을 가지고 있어요.
또한 자신뿐 아니라 함께하는 사람들까지 세심하게 챙기는 따뜻한 면도 가지고 있습니다. 든든한 버팀목이 되어주면서도, 필요할 때는 힘이 되는 한마디를 건네는 당신 덕분에
주변에는 오래 함께하는 사람들이 많습니다.

그래서 영양찰떡은 당신에게 가장 잘 어울리는 다과입니다. 한 알 한 알의 좋은 재료가 모여 든든한 한 조각을 완성하듯, 당신도 신뢰와 배려, 책임감을 바탕으로 주변을 단단하게 만드는 사람입니다.
언제나 중심을 지키며 모두에게 힘이 되어주는, 영양만점 같은 존재니까요.''',
      '''Nutty rice cake steams glutinous rice with a generous hand of nuts and grains.
One solid piece carries you a long way — and so do you.
You are the person others trust, and the one who ends up leading.
You hold the centre when things get difficult, and people follow you without being asked.
You look after yourself, yes, but you look after everyone with you as well. You are the beam that holds the room up,
and you find the one sentence someone needs to hear. That is why so many people stay in your life for so long.

That is why this is your sweet. Good ingredients, grain by grain, make one dependable piece —
and trust, care and responsibility, one at a time, are how you make everything around you solid.
Always at the centre, always something to lean on.''',
      '''栄養もちは、もち米にナッツと穀物を惜しみなく加えて蒸し上げた伝統菓子です。
たったひと切れで長く満たしてくれるように、
あなたはまわりの人に信頼と安心を与える存在であり、まとめ役でもあります。
難しい状況でも軸を失わず、人を自然に導く力をもっています。
自分だけでなく、共にいる人まで細やかに気づかうあたたかさも。しっかりと支えになりながら、
必要なときには力になるひと言を贈る——だからあなたのまわりには、長く一緒にいる人が多いのです。

だからこそ、栄養もちはあなたに最もよく似合う菓子です。良い材料がひと粒ずつ集まって
頼もしいひと切れになるように、あなたも信頼と思いやりと責任で、まわりを確かなものにしていきます。
いつも中心を守り、みんなの力になる——まさに栄養満点の存在です。''',
    ),
    pairing: L10nText('오미자 수단', 'Omija Sudan', 'オミジャスダン'),
    pairingDesc: L10nText(
      '''한결같은 당신에게도 일탈은 필요한 법입니다!
맛과 멋, 재미까지 챙긴 오미자 수단과 함께
일상을 벗어나보는건 어떨까요?''',
      '''Even the most constant person deserves a detour.
Omija sudan has flavour, looks and a little mischief —
step out of the ordinary for a moment.''',
      '''いつも変わらないあなたにも、寄り道は必要です。
味も見た目も楽しさも備えたオミジャスダンと一緒に、
日常から少し離れてみませんか。''',
    ),
    runnerUp: '양갱',
    runnerUpDesc: L10nText(
      '''묵직한 매력을 가진 당신에게는 양갱도 좋은 선택입니다. 한결같은 달콤함과 부드러운 식감처럼,
당신의 든든함도 시간이 지날수록 더욱 빛을 발하기를 바랍니다.''',
      '''Yanggaeng is a good choice for someone with your weight of character. Its unchanging sweetness and soft texture —
may your steadiness shine the same way, more with every year.''',
      '''どっしりとした魅力をもつあなたには、ようかんも良い選択です。
変わらない甘さとなめらかな食感のように、
あなたの頼もしさも、時が経つほど輝きますように。''',
    ),
    imagePath: 'assets/figma/result_영양찰떡.png',
  ),
  '양갱': DagwaResult(
    menuName: '양갱',
    name: L10nText('양갱', 'Yanggaeng', 'ようかん'),
    title: L10nText(
      '당신은 취향 확고한 할매입맛, 양갱!',
      'You are Yanggaeng — old-soul taste, firmly your own.',
      'あなたは好みの定まった渋好み、ようかん！',
    ),
    description: L10nText(
      '''양갱은 팥과 한천을 정성껏 졸여 굳혀 만든 전통 다과입니다.
화려한 비주얼이나 강한 자극 없이도 오랜 시간 사랑받아 온 이유가 있는 다과죠.
부드러운 식감과 은은한 단맛, 그리고 진한 팥의 풍미는 먹을수록 깊은 매력을 느끼게 합니다.

당신도 양갱과 닮았습니다.
남들이 유행을 따라갈 때도 자신만의 취향을 꿋꿋하게 지키는 사람이에요. 좋아하는 것에는 확신이 있고, 겉모습보다 본질과 가치를 중요하게 생각합니다.
처음에는 차분해 보일 수 있지만, 가까워질수록 깊은 생각과 따뜻한 마음을 가진 사람이라는 것을 알게 돼요.

또한 쉽게 흔들리지 않는 안정감 덕분에 주변 사람들에게 신뢰를 주는 존재이기도 합니다.
양갱이 오랜 시간 사랑받아 온 전통 다과인 것처럼, 당신 역시 시간이 지날수록 더욱 빛나는 매력을 가진 사람입니다.

혹시 아직 양갱의 진짜 매력을 모르고 있었다면, 이번 기회에 한입 맛보며 당신과의 공통점을 찾아보세요!''',
      '''Yanggaeng is red bean and agar, simmered down with care and set firm.
No spectacle, no sharp edges — and loved for centuries all the same. There is a reason for that.
A soft texture, a restrained sweetness and the deep flavour of red bean that opens up the more you eat.

You are much the same.
While everyone else follows the trend, you hold on to your own taste. You are certain about what you like,
and you weigh substance over surface.
You can seem reserved at first, but the closer anyone gets, the clearer your depth and warmth become.

Because you are not easily shaken, people trust you.
Just as yanggaeng has been loved across generations, you are someone who shines more with time.

If you have never quite understood the appeal, take a bite now and look for what the two of you share.''',
      '''ようかんは、小豆と寒天をていねいに煮詰めて固めた伝統菓子です。
華やかな見た目も強い刺激もないのに、長く愛されてきた理由がある菓子です。
なめらかな食感、控えめな甘さ、そして濃い小豆の風味は、食べるほどに深い魅力を感じさせます。

あなたも、ようかんに似ています。
まわりが流行を追うときも、自分の好みを揺るがず守る人。好きなものには確信があり、
見た目より本質と価値を大切にします。
はじめは落ち着いて見えても、近づくほどに、深い思考とあたたかい心の持ち主だと分かります。

簡単には揺らがない安定感ゆえに、まわりから信頼される存在でもあります。
ようかんが長く愛されてきた伝統菓子であるように、あなたもまた、時が経つほど輝く魅力をもつ人です。

もしまだようかんの本当の魅力を知らなかったなら、この機会にひと口。あなたとの共通点が見つかるはずです。''',
    ),
    pairing: L10nText('대추차', 'Jujube Tea', 'なつめ茶'),
    pairingDesc: L10nText(
      '대추의 은은한 단맛이 양갱의 깊은 팥 풍미와 잘 어우러져 가장 편안하고 정갈한 조합을 만들어줍니다.',
      'The quiet sweetness of jujube meets the deep red bean flavour of yanggaeng — the calmest, tidiest pairing on the table.',
      'なつめのほのかな甘さが、ようかんの深い小豆の風味とよく溶け合い、いちばん穏やかで端正な組み合わせになります。',
    ),
    runnerUp: '매작과',
    runnerUpDesc: L10nText(
      '''매작과는 반죽을 꼬아 바삭하게 튀긴 뒤 조청을 입힌 전통
다과입니다. 양갱이 깊고 차분한 매력이라면, 매작과는 은근한
개성과 재미를 가진 매력을 품고 있어요.''',
      '''Maejakgwa twists dough, fries it crisp and glazes it with grain
syrup. If yanggaeng is deep and calm, maejakgwa carries a quieter
kind of personality — and a little fun.''',
      '''メジャッカは、生地をねじって揚げ、水飴をまとわせた伝統菓子です。
ようかんが深く落ち着いた魅力なら、メジャッカは
さりげない個性と楽しさをもつ菓子です。''',
    ),
    imagePath: 'assets/figma/result_양갱.png',
  ),
  '매작과': DagwaResult(
    menuName: '매작과',
    name: L10nText('매작과', 'Maejakgwa', 'メジャッカ'),
    title: L10nText(
      '당신은 사랑받는 귀염둥이, 매작과!',
      'You are Maejakgwa — effortlessly adored.',
      'あなたは愛される人気者、メジャッカ！',
    ),
    description: L10nText(
      '''매작과는 밀가루 반죽을 꼬아 꽃잎 모양으로 만든 뒤 바삭하게 튀기고, 조청을 입혀 완성하는 전통 다과입니다.
앙증맞은 모양과 달콤한 맛 덕분에 예로부터 잔칫상과 다과상에서 사랑받아 온 메뉴예요.

당신도 매작과와 닮았습니다.
주변 사람들에게 자연스럽게 사랑받는 재주가 있는 사람이에요. 특별히 애교를 부리지 않아도 귀엽고 친근한 분위기를 가지고 있어, 처음 만난 사람도 어렵지 않게 다가옵니다.
또한 밝고 긍정적인 에너지로 주변 분위기를 부드럽게 만들어 주는 역할을 해요.
작은 일에도 즐거움을 발견할 줄 알고, 사람들과 함께 웃는 시간을 소중하게 생각하는 당신.
그래서 사람들은 당신과 함께 있으면 괜히 기분이 좋아집니다.

매작과가 한 번 먹으면 자꾸 손이 가는 다과인 것처럼, 당신 역시 자꾸 생각나고 보고 싶은 매력을 가진 사람이에요.
혹시 아직 매작과를 맛보지 못했다면 꼭 한 번 경험해 보세요. 당신처럼 사랑스러운 매력을 가진 다과를 발견하게 될 거예요!''',
      '''Maejakgwa twists wheat dough into a petal shape, fries it crisp and finishes it in grain syrup.
Its small, pretty form and gentle sweetness have made it a favourite at feasts and tea tables for centuries.

You are much the same.
You have a gift for being loved without working at it. You do not have to try to be charming —
there is something warm and easy about you, and even strangers find you approachable.
Your bright energy softens the mood of a room.
You find delight in small things and treasure the hours spent laughing with people.
That is why being near you simply feels good.

One piece of maejakgwa is never the last, and you are the same — someone people think of and want to see again.
If you have not tried it yet, please do. You will meet a sweet as lovable as you are.''',
      '''メジャッカは、小麦の生地をねじって花びらの形にし、さくっと揚げて水飴をまとわせた伝統菓子です。
愛らしい姿とやさしい甘さから、古くから祝いの膳や茶菓子の席で愛されてきました。

あなたも、この菓子に似ています。
まわりから自然に愛される才をもつ人。特別に甘えなくても、可愛らしく親しみやすい空気をまとっていて、
初対面の相手もすっと近づいてきます。
明るく前向きなエネルギーで、その場の空気をやわらかくする役割も果たします。
小さなことにも喜びを見つけ、人と笑い合う時間を大切にするあなた。
だから人は、あなたといるとなんだか嬉しくなるのです。

ひと口食べると手が止まらないメジャッカのように、あなたもまた、また会いたくなる魅力の持ち主です。
まだ味わったことがなければ、ぜひ一度。あなたのように愛らしい菓子に出会えるはずです。''',
    ),
    pairing: L10nText('식혜', 'Sikhye', 'シッケ'),
    pairingDesc: L10nText(
      '''달콤하고 시원한 행궁식혜는 매작과의 바삭한 식감을 더욱
돋보이게 해줍니다. 보기만 해도 기분 좋아지는 조합처럼, 당신 역시 주변 사람들에게 웃음과 즐거움을 전하는 존재예요.''',
      '''Sweet, cold Haenggung sikhye makes the crispness of maejakgwa
stand out. A pairing that cheers you up just to look at — rather like
what you do for everyone around you.''',
      '''甘くて冷たいヘングンシッケが、メジャッカのさくっとした食感を
いっそう引き立てます。見るだけで嬉しくなる組み合わせのように、
あなたもまわりに笑顔と楽しさを届ける存在です。''',
    ),
    runnerUp: '수원약과',
    runnerUpDesc: L10nText(
      '''수원약과는 정성껏 반죽해 튀긴 뒤 조청을 머금어 깊은
달콤함을 담아낸 전통 다과입니다. 매작과가 귀엽고 통통 튀는 매력이라면,
행궁약과는 사랑스럽고 든든한 매력을 가진 다과예요.''',
      '''Suwon yakgwa is kneaded with care, fried, then soaked in grain syrup
for a deep sweetness. If maejakgwa is bright and playful,
yakgwa is lovable and reassuring.''',
      '''水原ヤックァは、ていねいに練った生地を揚げ、水飴を含ませて
深い甘さを閉じ込めた伝統菓子です。メジャッカが可愛らしく弾ける魅力なら、
ヤックァは愛らしくて頼もしい魅力の菓子です。''',
    ),
    imagePath: 'assets/figma/result_매작과.png',
  ),
  '수원약과': DagwaResult(
    menuName: '수원약과',
    name: L10nText('수원약과', 'Suwon Yakgwa', '水原ヤックァ'),
    title: L10nText(
      '당신은 겉바속촉 매력을 가진 MZ, 수원약과!',
      'You are Suwon Yakgwa — crisp outside, soft within.',
      'あなたは外はさくっ中はしっとり、水原ヤックァ！',
    ),
    description: L10nText(
      '''수원약과는 전통 약과의 깊은 풍미는 그대로 담고, 한입에 즐기기 좋은 감각적인 매력을 더한 대표 메뉴입니다.
겉은 바삭하게, 속은 촉촉하게. 익숙한 전통의 맛에 새로운 감성을 더해 남녀노소 누구나 즐길 수 있는 다과예요.

당신도 수원약과와 닮았습니다.
첫인상은 트렌디하고 밝아 보이지만, 가까워질수록 생각보다 깊고 따뜻한 사람이라는 것을 알게 됩니다.
유행을 즐길 줄 알면서도 자신만의 기준이 분명하고,
새로운 것과 익숙한 것을 자연스럽게 조화시키는 감각을 가지고 있어요.
또한 사람들과 어울리는 것을 좋아하지만, 가벼운 관계보다는 진심이 담긴 인연을 더 소중하게 생각합니다.

겉은 바삭한 센스, 속은 촉촉한 진심.
그래서 사람들은 당신을 볼수록 더욱 매력을 느끼게 됩니다.
수원약과처럼 당신 역시 누구에게나 사랑받지만, 그 안에는 자신만의 깊이와 개성을 품고 있는 사람이에요.''',
      '''Suwon yakgwa keeps the deep flavour of the traditional honey pastry and adds a modern, one-bite elegance.
Crisp on the outside, moist within. A familiar taste in a fresh register — a sweet for absolutely everyone.

You are much the same.
At first glance you read as bright and current; the closer anyone gets, the more depth and warmth they find.
You enjoy what is in fashion while keeping your own standards clear,
and you have a real gift for making the new and the familiar sit comfortably together.
You like company, but you hold sincere connections far above easy ones.

Crisp sense outside, soft sincerity within.
That is why people find you more compelling the longer they look.
Like Suwon yakgwa, you are loved by everyone — and still entirely your own.''',
      '''水原ヤックァは、伝統的なヤックァの深い風味をそのままに、ひと口で楽しめる洗練された魅力を加えた看板菓子です。
外はさくっと、中はしっとり。馴染みある伝統の味に新しい感性を重ね、世代を問わず楽しめる菓子です。

あなたも、この菓子に似ています。
第一印象は今っぽく明るく見えても、近づくほどに、思っていたより深くあたたかい人だと分かります。
流行を楽しみながらも自分の基準がはっきりしていて、
新しいものと馴染みのものを自然に調和させる感覚をもっています。
人と過ごすのは好きですが、軽い関係より、真心のこもった縁をずっと大切にします。

外はさくっとしたセンス、中はしっとりした誠実さ。
だから人は、見るほどにあなたの魅力を感じるのです。
水原ヤックァのように、あなたも誰からも愛されながら、自分だけの深さと個性を秘めた人です。''',
    ),
    pairing: L10nText('오미자수단', 'Omija Sudan', 'オミジャスダン'),
    pairingDesc: L10nText(
      '''오미자의 새콤달콤한 맛과 화려한 색감이 수원약과의 트렌디한
매력을 더욱 돋보이게 해줍니다. 전통 재료로 만들었지만 세련되고
특별한 느낌을 주는 점이 당신과 꼭 닮아 있어요.''',
      '''The sweet-tart taste and vivid colour of omija set off the modern
appeal of Suwon yakgwa. Made from traditional ingredients yet
refined and distinctive — exactly like you.''',
      '''オミジャの甘酸っぱさと鮮やかな色合いが、水原ヤックァの
今っぽい魅力をいっそう引き立てます。伝統の素材から生まれながら
洗練されて特別——そこがあなたにそっくりです。''',
    ),
    runnerUp: '흑임자다식',
    runnerUpDesc: L10nText(
      '''흑임자다식은 고소한 흑임자를 곱게 갈아 정성스럽게 빚어낸 전통 다과입니다.
유행도 좋아하지만 자신만의 취향도 포기하지 않는 당신이라면,
흑임자다식의 깊고 고소한 매력도 어울립니다.''',
      '''Black sesame dasik grinds toasted black sesame fine and shapes it by hand.
If you enjoy what is current without ever giving up your own taste,
its deep, nutty character will suit you.''',
      '''黒ごま茶食は、香ばしい黒ごまを細かくすり潰し、ていねいに形づくった伝統菓子です。
流行も好みながら、自分の好みも手放さないあなたなら、
黒ごま茶食の深く香ばしい魅力もきっと似合います。''',
    ),
    imagePath: 'assets/figma/result_행궁약과.png',
  ),
};
