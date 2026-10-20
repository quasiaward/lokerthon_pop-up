import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'brand_mark.dart';
import 'kiosk_button.dart';
import 'kiosk_modal.dart';

/// 팝업 장소에서 행궁다과까지의 짧은 도보 경로를 앱 안에서 보여 주는 안내 시트.
/// 실제 지도 캡처에서 도로·건물 모양만 뽑아 앱 색으로 다시 칠한 배경
/// (`assets/map/route_map.png`, `tool/build_route_map.py`) 위에 경로와
/// 이름표를 그리고, 경로가 출발지에서 도착지까지 반복해서 이어진다.
class StoreDirectionsSheet extends StatefulWidget {
  const StoreDirectionsSheet({
    super.key,
    required this.onClose,
    this.onActivity,
  });

  /// 지도 배경을 미리 디코드한다. 앱 시작 때 한 번 부른다.
  static Future<void> precache(BuildContext context) =>
      _MapGeo.precache(context);

  final VoidCallback onClose;
  final VoidCallback? onActivity;

  @override
  State<StoreDirectionsSheet> createState() => _StoreDirectionsSheetState();
}

class _StoreDirectionsSheetState extends State<StoreDirectionsSheet>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
    reverseDuration: Motion.base,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.emphasized,
    reverseCurve: Curves.easeInCubic,
  );

  /// 경로가 그려지고 도착지가 한 번 반짝인 뒤 다시 시작한다.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _loop
        ..stop()
        ..value = _RouteOverlayPainter.drawEnd;
    } else if (_controller.isDismissed && !_closing) {
      // 시트가 다 올라온 뒤에 경로를 그리기 시작한다. 올라오는 동안에는
      // 경로 레이어를 다시 그리지 않아 첫 프레임들이 가볍다.
      _controller.forward().whenComplete(() {
        if (mounted && !_closing) _loop.repeat();
      });
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    widget.onActivity?.call();
    _closing = true;
    _loop.stop();
    if (!MediaQuery.disableAnimationsOf(context)) {
      try {
        await _controller.reverse().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (mounted) widget.onClose();
  }

  @override
  void dispose() {
    _loop.dispose();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    scopesRoute: true,
    explicitChildNodes: true,
    namesRoute: true,
    label: tr('행궁다과 길 안내', 'Directions to Haenggung Dagwa', '行宮茶菓への道案内'),
    child: KioskModal(
      opacity: _curve,
      onDismiss: _close,
      dismissLabel: tr('닫기', 'Close', '閉じる'),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_curve),
          // 크기 변화 없이 위치만 옮겨야 캐시된 레이어를 그대로 쓴다.
          // 지도와 안내를 또렷하게 읽어야 하는 시트라 반투명 유리 대신
          // 불투명한 면을 쓴다. 뒤 흐림도 필요 없어 움직임이 가볍다.
          child: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 26),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.sheet),
                  border: Border.all(color: AppColors.mist),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentDeep.withValues(alpha: 0.16),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: SizedBox(
                  key: const ValueKey('directions-sheet'),
                  width: 1188,
                  height: 824,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(44, 18, 44, 34),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 54,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.lineStrong.withValues(
                                alpha: 0.42,
                              ),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 로고와 닫기 버튼의 폭이 달라 Spacer로는 가운데가 맞지
                        // 않는다. 문구는 줄 전체의 가운데에 따로 놓는다.
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              children: [
                                const BrandMark(compact: true),
                                const Spacer(),
                                Semantics(
                                  button: true,
                                  label: tr('닫기', 'Close', '閉じる'),
                                  child: IconButton.filledTonal(
                                    onPressed: _close,
                                    icon: const Icon(Icons.close_rounded),
                                    iconSize: 26,
                                    style: IconButton.styleFrom(
                                      fixedSize: const Size(50, 50),
                                      backgroundColor: AppColors.accentSoft,
                                      foregroundColor: AppColors.accentDeep,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 자간이 마지막 글자 뒤에도 붙어 글자가 그만큼
                            // 왼쪽으로 보인다. 같은 폭을 앞에 더해 맞춘다.
                            Padding(
                              padding: const EdgeInsets.only(left: 2.8),
                              child: Text(
                                'A SHORT WALK',
                                key: const ValueKey('directions-eyebrow'),
                                style: Type.eyebrow(
                                  AppColors.accent,
                                  tracking: 2.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _RouteIllustration(loop: _loop),
                              ),
                              const SizedBox(width: 34),
                              Expanded(
                                flex: 4,
                                child: _RouteDetails(
                                  key: const ValueKey(
                                    'store-directions-details',
                                  ),
                                  onClose: _close,
                                ),
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
          ),
        ),
      ),
    ),
  );
}

/// 지도 배경 좌표. 캡처를 가로 2000px로 줄인 기준이며
/// `tool/build_route_map.py`의 CROP과 같아야 한다.
abstract final class _MapGeo {
  static const asset = 'assets/map/route_map.png';

  /// 시트를 처음 열 때 디코드하느라 프레임이 밀리지 않도록 앱 시작 때
  /// 미리 올려 둔다.
  static Future<void> precache(BuildContext context) =>
      precacheImage(const AssetImage(asset), context);
  static const crop = Rect.fromLTWH(520, 0, 1120, 1194);

  /// 가회당 입구 → 행궁로 → 행궁다과 입구.
  static const route = [
    Offset(1170, 902),
    Offset(1146, 916),
    Offset(1015, 162),
    Offset(1040, 176),
  ];
  static const start = Offset(1205, 868);
  static const destination = Offset(1092, 196);

  /// 도보 배지는 경로 왼쪽, 공예공간아치와 성림맨션 이름 사이에 둔다.
  static const walkBadge = Offset(1046, 505);

  /// [size] 영역을 BoxFit.cover로 채운 배경에서 [point]가 놓이는 위치.
  static Offset place(Offset point, Size size) {
    final scale = math.max(size.width / crop.width, size.height / crop.height);
    final dx = (size.width - crop.width * scale) / 2;
    final dy = (size.height - crop.height * scale) / 2;
    return Offset(
      dx + (point.dx - crop.left) * scale,
      dy + (point.dy - crop.top) * scale,
    );
  }
}

class _RouteIllustration extends StatelessWidget {
  const _RouteIllustration({required this.loop});

  final Animation<double> loop;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: tr(
      '가회당에서 행궁로를 따라 행궁다과 2층까지 이동하는 길 안내 지도',
      'Map of the route from Gahoedang along Haenggung-ro to Haenggung Dagwa on the second floor',
      'カフェダンから行宮路を通り、行宮茶菓2階までの案内地図',
    ),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.ground,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.mist),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            Offset at(Offset p) => _MapGeo.place(p, size);
            // 움직이지 않는 지도·이름은 한 레이어로 캐시하고, 반복해서
            // 다시 그리는 경로만 따로 둔다.
            return Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: Image(
                            image: AssetImage(_MapGeo.asset),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            gaplessPlayback: true,
                          ),
                        ),
                        ..._roadLabels(at),
                        for (final poi in _pois) _PoiMarker.place(poi, at),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _RouteOverlayPainter(loop, [
                        for (final p in _MapGeo.route) at(p),
                      ], at(_MapGeo.destination)),
                    ),
                  ),
                ),
                _anchored(
                  at(_MapGeo.walkBadge),
                  const Alignment(1, 0),
                  _WalkBadge(tr('1분', '1 min', '1分')),
                ),
                _anchored(
                  at(_MapGeo.start),
                  Alignment.bottomCenter,
                  const _MapPin(
                    color: AppColors.celadon,
                    icon: Icons.storefront_rounded,
                  ),
                ),
                _anchored(
                  at(_MapGeo.destination),
                  Alignment.bottomCenter,
                  const _MapPin(
                    color: AppColors.accent,
                    icon: Icons.local_cafe_rounded,
                  ),
                ),
                _besidePin(
                  at(_MapGeo.destination),
                  size,
                  _PlaceLabel(
                    eyebrow: tr('도착', 'ARRIVE', '到着'),
                    title: tr('행궁다과 · 2층', 'Haenggung Dagwa · 2F', '行宮茶菓・2階'),
                    detail: tr('행궁로 25', '25 Haenggung-ro', '行宮路25'),
                    color: AppColors.accent,
                  ),
                ),
                _besidePin(
                  at(_MapGeo.start),
                  size,
                  _PlaceLabel(
                    eyebrow: tr('출발 · 현재 위치', 'START · YOU ARE HERE', '出発・現在地'),
                    title: tr('가회당 · 팝업', 'Gahoedang · Pop-up', 'カフェダン・ポップアップ'),
                    detail: tr('행궁로 33', '33 Haenggung-ro', '行宮路33'),
                    color: AppColors.celadon,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  /// 핀 머리 오른쪽에 이름표를 붙인다. 지도 밖으로 넘치지 않게 폭을 줄인다.
  static Widget _besidePin(Offset tip, Size size, _PlaceLabel label) {
    const gap = 26.0;
    const edge = 12.0;
    final left = tip.dx + gap;
    return Positioned(
      left: left,
      // 핀 머리(끝에서 약 32px 위)와 이름표의 세로 가운데를 맞춘다.
      top: tip.dy - 32,
      child: FractionalTranslation(
        translation: const Offset(0, -0.5),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.max(120, size.width - left - edge),
          ),
          child: label,
        ),
      ),
    );
  }

  /// [point]에 자식의 [anchor] 지점이 오도록 놓는다.
  static Widget _anchored(Offset point, Alignment anchor, Widget child) =>
      Positioned(
        left: point.dx,
        top: point.dy,
        child: FractionalTranslation(
          translation: Offset(-(anchor.x + 1) / 2, -(anchor.y + 1) / 2),
          child: child,
        ),
      );

  static List<Widget> _roadLabels(Offset Function(Offset) at) => [
    _anchored(
      at(const Offset(1178, 1100)),
      Alignment.center,
      _RoadLabel(tr('행궁로', 'Haenggung-ro', '行宮路'), angle: 1.39),
    ),
    _anchored(
      at(const Offset(790, 418)),
      Alignment.center,
      _RoadLabel(
        tr('행궁로26번길', 'Haenggung-ro 26beon-gil', '行宮路26番ギル'),
        angle: -0.58,
      ),
    ),
    _anchored(
      at(const Offset(1508, 598)),
      Alignment.center,
      _RoadLabel(
        tr('정조로801번길', 'Jeongjo-ro 801beon-gil', '正祖路801番ギル'),
        angle: 0.55,
      ),
    ),
  ];
}

class _RoadLabel extends StatelessWidget {
  const _RoadLabel(this.text, {required this.angle});

  final String text;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Text(
      text,
      style: Type.caption.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.faint,
      ),
    ),
  );
}

enum _PoiKind { food, shop, stay, place, parking }

/// 이름이 아이콘 아래에서 어느 쪽으로 뻗는지. 경로 옆 건물은 길을 가리지
/// 않도록 길 반대쪽으로 뻗게 한다.
enum _PoiText { center, toLeft, toRight }

class _Poi {
  const _Poi(this.at, this.kind, this.ko, this.en, this.ja, [this.text]);

  /// 지도 캡처(가로 2000px)에서 아이콘 중심.
  final Offset at;
  final _PoiKind kind;
  final String ko;
  final String en;
  final String ja;
  final _PoiText? text;
}

/// 지도 캡처의 장소 아이콘 위치를 그대로 옮겼다. 캡처에서 아이콘을 색으로
/// 찾아 중심 좌표를 잡았다. 출발·도착 이름표에 가려지는 곳(고요재·디자인하우스)과
/// 캡처 가장자리에서 잘리는 곳은 뺐다.
const _pois = [
  // 행궁로 서쪽
  _Poi(
    Offset(953, 171),
    _PoiKind.stay,
    '행궁사랑채',
    'Sarangchae Lounge',
    '行宮サランチェ',
    _PoiText.toLeft,
  ),
  _Poi(Offset(887, 281), _PoiKind.food, '91커피', '91 Coffee', '91コーヒー'),
  _Poi(Offset(625, 166), _PoiKind.place, '수원용달이사', 'Suwon Movers', '水原引越し'),
  _Poi(
    Offset(971, 389),
    _PoiKind.food,
    '행궁장작 한방통닭',
    'Jangjak Chicken',
    'チャンジャクチキン',
  ),
  _Poi(
    Offset(866, 444),
    _PoiKind.place,
    '공예공간아치',
    'Craft Space Achi',
    '工芸空間アチ',
  ),
  _Poi(
    Offset(938, 557),
    _PoiKind.place,
    '성림맨션',
    'Seongnim Mansion',
    'ソンリムマンション',
  ),
  _Poi(
    Offset(607, 601),
    _PoiKind.place,
    '오룡파크빌라',
    'Oryong Park Villa',
    'オリョンパークヴィラ',
  ),
  _Poi(
    Offset(581, 654),
    _PoiKind.stay,
    '게스트하우스 자이소리',
    'Guesthouse Jaisori',
    'ゲストハウス・チャイソリ',
    _PoiText.toRight,
  ),
  _Poi(
    Offset(1043, 664),
    _PoiKind.food,
    '메가MGC커피',
    'MEGA MGC COFFEE',
    'メガMGCコーヒー',
    _PoiText.toLeft,
  ),
  _Poi(
    Offset(781, 728),
    _PoiKind.place,
    '열린문화공간 후소',
    'Culture Space Huso',
    '文化空間フソ',
  ),
  _Poi(
    Offset(909, 753),
    _PoiKind.place,
    '남창동 열린문화공간',
    'Namchang Culture Space',
    '南昌洞文化空間',
  ),
  _Poi(
    Offset(1064, 865),
    _PoiKind.place,
    '너랑나랑',
    'Neorang Narang',
    'ノランナラン',
    _PoiText.toLeft,
  ),
  _Poi(Offset(699, 903), _PoiKind.place, '로라하우스', 'Laura House', 'ローラハウス'),
  _Poi(
    Offset(1097, 947),
    _PoiKind.place,
    '나정희규방공예',
    'Na Jeonghui Crafts',
    'ナ・ジョンヒ工芸',
    _PoiText.toLeft,
  ),
  _Poi(
    Offset(1107, 1074),
    _PoiKind.place,
    '지현이발관',
    'Jihyun Barber',
    'ジヒョン理容室',
    _PoiText.toLeft,
  ),
  // 행궁로 동쪽
  _Poi(
    Offset(1075, 53),
    _PoiKind.food,
    '공차',
    'Gong cha',
    'ゴンチャ',
    _PoiText.toRight,
  ),
  _Poi(
    Offset(1072, 233),
    _PoiKind.food,
    '베로베로',
    'Verovero',
    'ベロベロ',
    _PoiText.toRight,
  ),
  _Poi(Offset(1128, 274), _PoiKind.parking, 'P', 'P', 'P'),
  _Poi(Offset(1306, 324), _PoiKind.place, '사진공예사', 'Photo Craft', '写真工芸社'),
  _Poi(
    Offset(1157, 412),
    _PoiKind.food,
    '열두알우동집',
    'Yeoldual Udon',
    'ヨルドゥアルうどん',
    _PoiText.toRight,
  ),
  _Poi(Offset(1339, 434), _PoiKind.shop, '핑크핑크해', 'Pink Pinkhae', 'ピンクピンクヘ'),
  _Poi(Offset(1229, 474), _PoiKind.food, '세프스위트', 'Chef Sweet', 'シェフスイート'),
  _Poi(Offset(1425, 452), _PoiKind.place, '대민빌딩', 'Daemin Bldg.', 'テミンビル'),
  _Poi(
    Offset(1125, 535),
    _PoiKind.place,
    '나녕공방',
    'Nanyeong Studio',
    'ナニョン工房',
    _PoiText.toRight,
  ),
  _Poi(Offset(1351, 571), _PoiKind.shop, '남양마트', 'Namyang Mart', 'ナミャンマート'),
  _Poi(
    Offset(1151, 597),
    _PoiKind.place,
    '향기도예',
    'Hyanggi Pottery',
    'ヒャンギ陶芸',
    _PoiText.toRight,
  ),
  _Poi(Offset(1428, 604), _PoiKind.shop, '제일의류', 'Jeil Clothing', 'チェイル衣料'),
  _Poi(
    Offset(1365, 669),
    _PoiKind.place,
    '산들체험학습여행사',
    'Sandeul Travel',
    'サンドゥル旅行社',
  ),
  _Poi(
    Offset(1161, 694),
    _PoiKind.place,
    '꽃울담다 종이노리',
    'Kkotul Paper Craft',
    'コッウル紙工芸',
    _PoiText.toRight,
  ),
  _Poi(
    Offset(1239, 950),
    _PoiKind.place,
    '금상오피스텔',
    'Geumsang Officetel',
    'クムサン・オフィステル',
  ),
  _Poi(
    Offset(1119, 1003),
    _PoiKind.place,
    '스튜디오 로티니',
    'Studio Rotini',
    'スタジオ・ロティーニ',
    _PoiText.toLeft,
  ),
  _Poi(
    Offset(1225, 1040),
    _PoiKind.place,
    '판앤펀캐리커쳐',
    'Fun & Fun Caricature',
    'ファン&ファン似顔絵',
    _PoiText.toRight,
  ),
  _Poi(
    Offset(1242, 1111),
    _PoiKind.place,
    '남창세탁소',
    'Namchang Laundry',
    'ナムチャン洗濯所',
  ),
];

/// 네이버 지도처럼 작은 아이콘 아래에 이름을 둔다.
class _PoiMarker extends StatelessWidget {
  const _PoiMarker(this.poi);

  final _Poi poi;

  static const _dot = 12.0;

  static Widget place(_Poi poi, Offset Function(Offset) at) {
    final p = at(poi.at);
    final (anchor, shift) = switch (poi.text ?? _PoiText.center) {
      _PoiText.center => (Alignment.topCenter, Offset.zero),
      _PoiText.toRight => (Alignment.topLeft, const Offset(-_dot / 2, 0)),
      _PoiText.toLeft => (Alignment.topRight, const Offset(_dot / 2, 0)),
    };
    return _RouteIllustration._anchored(
      p + shift - const Offset(0, _dot / 2),
      anchor,
      _PoiMarker(poi),
    );
  }

  Color get _color => switch (poi.kind) {
    _PoiKind.food => const Color(0xFFE39A7E),
    _PoiKind.shop => const Color(0xFFE2B45A),
    _PoiKind.stay => const Color(0xFFC39AD0),
    _PoiKind.place => const Color(0xFF9CA5C6),
    _PoiKind.parking => const Color(0xFF7FA3E6),
  };

  @override
  Widget build(BuildContext context) {
    if (poi.kind == _PoiKind.parking) {
      return Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Text(
          'P',
          style: Type.caption.copyWith(
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
    }
    final align = switch (poi.text ?? _PoiText.center) {
      _PoiText.center => CrossAxisAlignment.center,
      _PoiText.toRight => CrossAxisAlignment.start,
      _PoiText.toLeft => CrossAxisAlignment.end,
    };
    final food = poi.kind == _PoiKind.food || poi.kind == _PoiKind.shop;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        Container(
          width: _dot,
          height: _dot,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tr(poi.ko, poi.en, poi.ja),
          style: Type.caption.copyWith(
            fontSize: 10.5,
            height: 1.15,
            fontWeight: FontWeight.w600,
            color: food
                ? Color.lerp(_color, AppColors.ink, 0.35)
                : AppColors.muted,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 3),
              Shadow(color: Colors.white, blurRadius: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _WalkBadge extends StatelessWidget {
  const _WalkBadge(this.label);

  /// 번역 문구는 밖에서 받는다. const 위젯 안에서 tr()을 부르면 언어가
  /// 바뀌어도 다시 그려지지 않을 수 있다.
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.directions_walk_rounded,
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Type.caption.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

/// 물방울 모양 지도 핀. 아래 꼭짓점이 좌표에 닿는다.
class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 54,
    child: CustomPaint(
      painter: _PinPainter(color),
      child: Align(
        alignment: const Alignment(0, -0.42),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    ),
  );
}

class _PinPainter extends CustomPainter {
  const _PinPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final tip = Offset(r, size.height);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..cubicTo(r - 6, size.height - 10, 0, r + 12, 0, r)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..cubicTo(size.width, r + 12, r + 6, size.height - 10, tip.dx, tip.dy)
      ..close();
    canvas
      ..drawShadow(path, AppColors.accentDeep, 4, false)
      ..drawPath(path, Paint()..color = color)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = Colors.white,
      );
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => oldDelegate.color != color;
}

class _PlaceLabel extends StatelessWidget {
  const _PlaceLabel({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.color,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 230),
    padding: const EdgeInsets.fromLTRB(14, 10, 16, 11),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border(left: BorderSide(color: color, width: 4)),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentDeep.withValues(alpha: 0.1),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Type.eyebrow(color, latin: isEn, size: 11, tracking: 1.2),
        ),
        const SizedBox(height: 3),
        // 핀 옆 폭이 좁으면 잘리지 않고 두 줄로 흐른다.
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Type.section.copyWith(fontSize: 17, height: 1.25),
        ),
        Text(detail, style: Type.caption.copyWith(fontSize: 13)),
      ],
    ),
  );
}

class _RouteDetails extends StatelessWidget {
  const _RouteDetails({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(
                  '행궁다과까지\n걸어서 1분이에요',
                  'Haenggung Dagwa is\njust a 1-minute walk',
                  '行宮茶菓まで\n歩いて約1分です',
                ),
                style: Type.question.copyWith(fontSize: 38, height: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                tr(
                  '팝업을 나와 행궁로를 따라 98m만 걸어오세요.',
                  'Leave the pop-up and follow Haenggung-ro for 98 m.',
                  'ポップアップを出て、行宮路を98mほどお進みください。',
                ),
                style: Type.bodyMuted.copyWith(fontSize: 18, height: 1.48),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _RouteMetric(
                    icon: Icons.directions_walk_rounded,
                    value: tr('약 1분', '1 min', '約1分'),
                  ),
                  const SizedBox(width: 10),
                  _RouteMetric(icon: Icons.route_rounded, value: '98 m'),
                ],
              ),
              const SizedBox(height: 20),
              _RouteStep(
                number: '1',
                title: tr('팝업에서 출발', 'Leave the pop-up', 'ポップアップを出発'),
                body: tr(
                  '가회당에서 나와 행궁로를 따라 걸어주세요.',
                  'Exit Gahoedang and follow Haenggung-ro.',
                  'カフェダンを出て、行宮路に沿ってお進みください。',
                ),
              ),
              const SizedBox(height: 10),
              _RouteStep(
                number: '2',
                title: tr('건물 2층에 도착', 'Head up to the 2nd floor', '建物の2階へ'),
                body: tr(
                  '행궁로 25 건물 2층에서 기다리고 있어요.',
                  'We’re waiting on the 2nd floor at 25 Haenggung-ro.',
                  '行宮路25の建物2階でお待ちしています。',
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      KioskButton(
        label: tr('확인했어요', 'Got it', '確認しました'),
        fullWidth: true,
        icon: Icons.check_rounded,
        onPressed: onClose,
      ),
    ],
  );
}

class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.celadonSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: AppColors.celadon),
          const SizedBox(width: 8),
          Text(value, style: Type.section.copyWith(fontSize: 17)),
        ],
      ),
    ),
  );
}

class _RouteStep extends StatelessWidget {
  const _RouteStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.ground,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: Type.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Type.section.copyWith(fontSize: 18)),
              const SizedBox(height: 3),
              Text(
                body,
                style: Type.caption.copyWith(fontSize: 14, height: 1.42),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// 경로 한 바퀴: 옅은 전체 경로 위로 진한 선이 출발지에서 도착지까지
/// 이어지고, 도착지에서 물결이 한 번 퍼진 뒤 사라졌다가 다시 시작한다.
class _RouteOverlayPainter extends CustomPainter {
  _RouteOverlayPainter(this.loop, this.points, this.destination)
    : super(repaint: loop);

  /// 한 바퀴 중 선이 다 그려지는 시점.
  static const drawEnd = 0.55;
  static const _fadeStart = 0.86;

  final Animation<double> loop;
  final List<Offset> points;
  final Offset destination;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final metric = path.computeMetrics().first;
    final t = loop.value;

    // 전체 경로 (옅게)
    canvas
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white,
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.accent.withValues(alpha: 0.22),
      );

    final draw = Curves.easeInOutCubic.transform((t / drawEnd).clamp(0.0, 1.0));
    final fade = t < _fadeStart
        ? 1.0
        : 1 - Curves.easeIn.transform((t - _fadeStart) / (1 - _fadeStart));
    if (draw > 0 && fade > 0) {
      final shown = metric.extractPath(0, metric.length * draw);
      canvas.drawPath(
        shown,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.accent.withValues(alpha: fade),
      );

      // 진행 방향 화살표
      final arrow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.9 * fade);
      for (var d = 26.0; d < metric.length * draw - 10; d += 24) {
        final tan = metric.getTangentForOffset(d)!;
        final dir = tan.vector;
        final normal = Offset(-dir.dy, dir.dx);
        final c = tan.position;
        canvas.drawPath(
          Path()
            ..moveTo(
              (c - dir * 2.5 + normal * 2.6).dx,
              (c - dir * 2.5 + normal * 2.6).dy,
            )
            ..lineTo((c + dir * 1.5).dx, (c + dir * 1.5).dy)
            ..lineTo(
              (c - dir * 2.5 - normal * 2.6).dx,
              (c - dir * 2.5 - normal * 2.6).dy,
            ),
          arrow,
        );
      }

      // 걷는 사람 위치
      if (draw < 1) {
        final head = metric.getTangentForOffset(metric.length * draw)!.position;
        canvas
          ..drawCircle(
            head,
            14,
            Paint()..color = AppColors.accent.withValues(alpha: 0.18),
          )
          ..drawCircle(head, 7.5, Paint()..color = Colors.white)
          ..drawCircle(head, 5, Paint()..color = AppColors.accent);
      }
    }

    // 도착 물결
    if (t >= drawEnd && t < _fadeStart + 0.1) {
      final p = ((t - drawEnd) / (_fadeStart + 0.1 - drawEnd)).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(p);
      canvas.drawCircle(
        destination,
        10 + 34 * eased,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.accent.withValues(alpha: 0.45 * (1 - p)),
      );
    }

    // 출발점
    canvas
      ..drawCircle(points.first, 7, Paint()..color = Colors.white)
      ..drawCircle(points.first, 4.5, Paint()..color = AppColors.celadon);
  }

  @override
  bool shouldRepaint(_RouteOverlayPainter oldDelegate) =>
      oldDelegate.destination != destination ||
      !_samePoints(oldDelegate.points, points);

  static bool _samePoints(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
