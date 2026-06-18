import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/lang.dart';
import 'common.dart';
import 'lang_toggle.dart';
import 'watercolor_deco.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

// ─── 색상 (Figma '홈페이지 최종' 메뉴 화면 기준) ───────────────────────────
const _pageBg = Color(0xFFF5F5F3);
const _maroon = Color(0xFF934753); // 음료 카드 배경
const _cardBorder = Color(0xFFEBEBDF); // 카드 테두리 3px
const _titleColor = Color(0xFF534344);
const _tempColor = Color(0xFF9A9285);
const _signatureColor = Color(0xFFE06B7E);

// ─── 데이터 모델 ──────────────────────────────────────────────────────────
class _Price {
  const _Price(
    this.temp,
    this.amount,
  ); // temp: 'HOT' | 'ICE' | '' , amount: '8,000'
  final String temp;
  final String amount;

  int get value => int.parse(amount.replaceAll(',', ''));
}

class _RowCrop {
  const _RowCrop({required this.left});

  final double left;
}

enum _SpecialArt { none, mugwortLatte }

class _MenuItem {
  const _MenuItem({
    required this.name,
    required this.nameEn,
    required this.image,
    required this.prices,
    this.signature = false,
    this.badgeKo,
    this.badgeEn,
    this.rowCrop,
    this.specialArt = _SpecialArt.none,
    this.imagePadding = const EdgeInsets.fromLTRB(20, 22, 20, 14),
    this.imageAlignment = Alignment.bottomCenter,
  });

  final String name;
  final String nameEn;
  final String image; // asset 경로
  final List<_Price> prices; // 1~2개 (HOT/ICE)
  final bool signature; // '대표' 태그
  final String? badgeKo;
  final String? badgeEn;
  final _RowCrop? rowCrop;
  final _SpecialArt specialArt;
  final EdgeInsets imagePadding;
  final Alignment imageAlignment;

  int get minValue =>
      prices.map((p) => p.value).reduce((a, b) => a < b ? a : b);
}

class _MenuCategory {
  const _MenuCategory({
    required this.key,
    required this.labelKo,
    required this.labelEn,
    required this.items,
    required this.cardColor,
    this.pageSize = 16,
  });

  final String key;
  final String labelKo;
  final String labelEn;
  final List<_MenuItem> items;
  final Color cardColor; // 카드 배경색 (음료=마룬, 다과/빙수는 프레임 확인 후 조정)
  final int pageSize;
}

// ─── 음료 (Beverage) — Figma 1~2페이지 26종 ───────────────────────────────
const _beverages = <_MenuItem>[
  _MenuItem(
    name: '대추차',
    nameEn: 'Jujube Tea',
    image: 'assets/figma/menu/jujube_tea_sharp.png',
    prices: [_Price('HOT', '8,000')],
    signature: true,
  ),
  _MenuItem(
    name: '쌍화차',
    nameEn: 'Ssanghwa Tea',
    image: 'assets/figma/menu/ssanghwa_tea_sharp.png',
    prices: [_Price('HOT', '8,000')],
  ),
  _MenuItem(
    name: '생강차',
    nameEn: 'Ginger Tea',
    image: 'assets/figma/menu/ginger_tea_sharp.png',
    prices: [_Price('HOT', '6,000')],
  ),
  _MenuItem(
    name: '오미자 수단',
    nameEn: 'Omija Tea with Teok',
    image: 'assets/figma/menu/omija_sudan_sharp.png',
    prices: [_Price('ICE', '6,000')],
    signature: true,
  ),
  _MenuItem(
    name: '식혜',
    nameEn: 'Sweet Rice Punch',
    image: 'assets/figma/menu/sikhye_sharp.png',
    prices: [_Price('ICE', '4,500')],
  ),
  _MenuItem(
    name: '레몬 생강차',
    nameEn: 'Lemon Ginger Tea',
    image: 'assets/figma/menu/lemon_ginger_tea_sharp.png',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
  ),
  _MenuItem(
    name: '베리 레몬차',
    nameEn: 'Berry Lemon Tea',
    image: 'assets/figma/menu/berry_lemon_tea_sharp.png',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
  ),
  _MenuItem(
    name: '석류 레몬차',
    nameEn: 'Pomegranate Lemon Tea',
    image: 'assets/figma/menu/pomegranate_lemon_tea_sharp.png',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
  ),
  _MenuItem(
    name: '오미자차',
    nameEn: 'Omija Tea',
    image: 'assets/figma/menu/omija_tea_sharp.png',
    prices: [_Price('HOT', '5,000'), _Price('ICE', '5,500')],
  ),
  _MenuItem(
    name: '유자차 / 에이드',
    nameEn: 'Yuja Tea / Ade',
    image: 'assets/figma/menu/yuja_ade_sharp.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '레몬차 / 에이드',
    nameEn: 'Lemon Tea / Ade',
    image: 'assets/figma/menu/lemon_ade_sharp.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '자몽차 / 에이드',
    nameEn: 'Grapefruit Tea / Ade',
    image: 'assets/figma/menu/grapefruit_ade_sharp.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '라임차 / 에이드',
    nameEn: 'Lime Tea / Ade',
    image: 'assets/figma/menu/lime_ade_sharp.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '청귤차 / 에이드',
    nameEn: 'Green Tangerine Tea / Ade',
    image: 'assets/figma/menu/green_tangerine_ade_sharp.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '모과차 / 에이드',
    nameEn: 'Quince Tea / Ade',
    image: 'assets/figma/menu/quince_ade_sharp.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '청포도 에이드',
    nameEn: 'Green Grape Ade',
    image: 'assets/figma/menu/green_grape_ade_sharp.png',
    prices: [_Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '초코 라떼',
    nameEn: 'Chocolate Latte',
    image: 'assets/figma/menu/choco_latte.svg',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
    imagePadding: EdgeInsets.fromLTRB(42, 18, 42, 0),
  ),
  _MenuItem(
    name: '녹차 라떼',
    nameEn: 'Green Tea Latte',
    image: 'assets/figma/menu/green_tea_latte.svg',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
    imagePadding: EdgeInsets.fromLTRB(42, 18, 42, 0),
  ),
  _MenuItem(
    name: '자색고구마 라떼',
    nameEn: 'Purple Sweet Potato Latte',
    image: 'assets/figma/menu/purple_sweet_potato_latte.svg',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
    imagePadding: EdgeInsets.fromLTRB(42, 18, 42, 0),
  ),
  _MenuItem(
    name: '쑥 라떼',
    nameEn: 'Mugwort Latte',
    image: '',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
    specialArt: _SpecialArt.mugwortLatte,
    imagePadding: EdgeInsets.fromLTRB(48, 12, 48, 0),
  ),
  _MenuItem(
    name: '흑임자 라떼',
    nameEn: 'Black Sesame Latte',
    image: 'assets/figma/menu/black_sesame_latte_figma.svg',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
    imagePadding: EdgeInsets.fromLTRB(42, 18, 42, 0),
  ),
  _MenuItem(
    name: '벚꽃 라떼',
    nameEn: 'Cherry Blossom Latte',
    image: 'assets/figma/menu/cherry_blossom_latte.svg',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
    imagePadding: EdgeInsets.fromLTRB(42, 18, 42, 0),
  ),
  _MenuItem(
    name: '도라지 라떼',
    nameEn: 'Bellflower Latte',
    image: 'assets/figma/menu/bellflower_latte.svg',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
    imagePadding: EdgeInsets.fromLTRB(42, 18, 42, 0),
  ),
  _MenuItem(
    name: '아메리카노',
    nameEn: 'Americano',
    image: 'assets/figma/menu/americano.svg',
    prices: [_Price('HOT', '3,500'), _Price('ICE', '3,500')],
    imagePadding: EdgeInsets.fromLTRB(38, 8, 38, 0),
  ),
  _MenuItem(
    name: '카페 라떼',
    nameEn: 'Cafe Latte',
    image: 'assets/figma/menu/cafe_latte.svg',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
    imagePadding: EdgeInsets.fromLTRB(38, 8, 38, 0),
  ),
  _MenuItem(
    name: '바닐라 라떼',
    nameEn: 'Vanilla Latte',
    image: 'assets/figma/menu/vanilla_latte.svg',
    prices: [_Price('HOT', '5,000'), _Price('ICE', '5,500')],
    imagePadding: EdgeInsets.fromLTRB(38, 8, 38, 0),
  ),
];

const _desserts = <_MenuItem>[
  _MenuItem(
    name: '단팥죽',
    nameEn: 'Sweet Red Bean Porridge',
    image: 'assets/figma/menu/dessert_row_1.svg',
    prices: [_Price('', '7,000')],
    rowCrop: _RowCrop(left: 568),
  ),
  _MenuItem(
    name: '구운영양찰떡',
    nameEn: 'Roasted Nutritious Rice Cake',
    image: 'assets/figma/menu/dessert_row_1.svg',
    prices: [_Price('', '3,000')],
    rowCrop: _RowCrop(left: 852),
  ),
  _MenuItem(
    name: '쑥떡와플',
    nameEn: 'Mugwort Rice Cake Waffle',
    image: 'assets/figma/menu/mugwort_waffle.svg',
    prices: [_Price('', '6,000')],
    signature: true,
    imagePadding: EdgeInsets.fromLTRB(36, 32, 36, 32),
    imageAlignment: Alignment.center,
  ),
  _MenuItem(
    name: '다과상 A',
    nameEn: 'Dagwa Set A',
    image: 'assets/figma/menu/dessert_set_a.svg',
    prices: [_Price('', '7,000')],
    imagePadding: EdgeInsets.fromLTRB(15, 54, 15, 54),
    imageAlignment: Alignment.center,
  ),
  _MenuItem(
    name: '다과상 B',
    nameEn: 'Dagwa Set B',
    image: 'assets/figma/menu/dessert_set_b.svg',
    prices: [_Price('', '9,500')],
    imagePadding: EdgeInsets.fromLTRB(15, 44, 15, 44),
    imageAlignment: Alignment.center,
  ),
  _MenuItem(
    name: '다과상 C',
    nameEn: 'Dagwa Set C',
    image: 'assets/figma/menu/dessert_set_c.svg',
    prices: [_Price('', '15,000')],
    imagePadding: EdgeInsets.fromLTRB(15, 26, 15, 29),
    imageAlignment: Alignment.center,
  ),
];

const _bingsu = <_MenuItem>[
  _MenuItem(
    name: '그냥 빙수',
    nameEn: 'Original Bingsu',
    image: 'assets/figma/menu/bingsu_row_1.svg',
    prices: [_Price('', '15,000')],
    rowCrop: _RowCrop(left: 0),
  ),
  _MenuItem(
    name: '녹차 빙수',
    nameEn: 'Green Tea Bingsu',
    image: 'assets/figma/menu/bingsu_row_1.svg',
    prices: [_Price('', '15,000')],
    rowCrop: _RowCrop(left: 284),
  ),
  _MenuItem(
    name: '흑임자 빙수',
    nameEn: 'Black Sesame Bingsu',
    image: 'assets/figma/menu/bingsu_row_1.svg',
    prices: [_Price('', '15,000')],
    rowCrop: _RowCrop(left: 568),
  ),
  _MenuItem(
    name: '망고 빙수',
    nameEn: 'Mango Bingsu',
    image: 'assets/figma/menu/bingsu_row_1.svg',
    prices: [_Price('', '15,000')],
    rowCrop: _RowCrop(left: 852),
  ),
  _MenuItem(
    name: '블루베리 빙수',
    nameEn: 'Blueberry Bingsu',
    image: 'assets/figma/menu/blueberry_bingsu.svg',
    prices: [_Price('', '15,000')],
    imagePadding: EdgeInsets.fromLTRB(24, 20, 24, 20),
    imageAlignment: Alignment.center,
  ),
  _MenuItem(
    name: '벚꽃베리 빙수',
    nameEn: 'Cherry Berry Bingsu',
    image: 'assets/figma/menu/cherry_berry_bingsu.svg',
    prices: [_Price('', '15,000')],
    badgeKo: '시즌',
    badgeEn: 'Season',
    imagePadding: EdgeInsets.fromLTRB(20, 14, 20, 18),
    imageAlignment: Alignment.center,
  ),
];

const _categories = <_MenuCategory>[
  _MenuCategory(
    key: '음료',
    labelKo: '음료',
    labelEn: 'Beverage',
    items: _beverages,
    cardColor: _maroon,
    pageSize: 16,
  ),
  _MenuCategory(
    key: '다과',
    labelKo: '다과',
    labelEn: 'Dessert',
    items: _desserts,
    cardColor: _maroon,
  ),
  _MenuCategory(
    key: '빙수',
    labelKo: '빙수',
    labelEn: 'Bingsu',
    items: _bingsu,
    cardColor: _maroon,
  ),
];

enum _SortMode { recommended, priceLow, priceHigh }

class MenuSection extends StatefulWidget {
  const MenuSection({super.key});

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  int _categoryIndex = 0;
  int _page = 0;
  _SortMode _sort = _SortMode.recommended;

  _MenuCategory get _category => _categories[_categoryIndex];

  List<_MenuItem> get _sortedItems {
    final items = [..._category.items];
    switch (_sort) {
      case _SortMode.recommended:
        break;
      case _SortMode.priceLow:
        items.sort((a, b) => a.minValue.compareTo(b.minValue));
      case _SortMode.priceHigh:
        items.sort((a, b) => b.minValue.compareTo(a.minValue));
    }
    return items;
  }

  List<List<_MenuItem>> get _pages {
    final items = _sortedItems;
    if (items.isEmpty) return const [];
    final size = _category.pageSize;
    return [
      for (var i = 0; i < items.length; i += size)
        items.sublist(i, (i + size).clamp(0, items.length)),
    ];
  }

  void _selectCategory(int index) {
    setState(() {
      _categoryIndex = index;
      _page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deco = decoScaleOf(context, designWidth: 1409);
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    final pages = _pages;
    final currentPage = pages.isEmpty ? -1 : _page.clamp(0, pages.length - 1);

    return Container(
      color: _pageBg,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: WatercolorDeco(decoBlossomYellowPage, width: 582 * deco),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 96),
            child: SectionShell(
              child: Column(
                children: [
                  Text(
                    tr('행궁다과 메뉴', 'MENU'),
                    style: TextStyle(
                      color: _titleColor,
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: isWide ? 50 : 34,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 34),
                  _CategoryTabs(
                    selected: _categoryIndex,
                    onChanged: _selectCategory,
                  ),
                  const SizedBox(height: 52),
                  _MenuToolbar(
                    sort: _sort,
                    onSortChanged: (mode) => setState(() => _sort = mode),
                  ),
                  const SizedBox(height: 28),
                  if (currentPage < 0)
                    _ComingSoon(category: _category)
                  else ...[
                    _MenuGrid(
                      items: pages[currentPage],
                      cardColor: _category.cardColor,
                    ),
                    if (pages.length > 1) ...[
                      const SizedBox(height: 44),
                      _Pagination(
                        count: pages.length,
                        active: currentPage,
                        onChanged: (i) => setState(() => _page = i),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 카테고리 탭 ──────────────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 12,
      children: [
        for (var i = 0; i < _categories.length; i++)
          _CategoryPill(
            label: tr(_categories[i].labelKo, _categories[i].labelEn),
            selected: i == selected,
            onTap: () => onChanged(i),
          ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? _maroon : const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF806D6D),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 툴바 (언어 토글 + 정렬) ──────────────────────────────────────────────
class _MenuToolbar extends StatelessWidget {
  const _MenuToolbar({required this.sort, required this.onSortChanged});

  final _SortMode sort;
  final ValueChanged<_SortMode> onSortChanged;

  String _sortLabel(_SortMode mode) => switch (mode) {
    _SortMode.recommended => tr('추천순', 'Recommend'),
    _SortMode.priceLow => tr('낮은 가격순', 'Low price'),
    _SortMode.priceHigh => tr('높은 가격순', 'High price'),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB5B5B5)),
          ),
          child: const LangToggle(),
        ),
        const Spacer(),
        PopupMenuButton<_SortMode>(
          initialValue: sort,
          onSelected: onSortChanged,
          itemBuilder: (context) => [
            for (final mode in _SortMode.values)
              PopupMenuItem(value: mode, child: Text(_sortLabel(mode))),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _sortLabel(sort),
                style: const TextStyle(
                  color: _titleColor,
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.keyboard_arrow_down_rounded, color: _titleColor),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 메뉴 그리드 ──────────────────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.items, required this.cardColor});

  final List<_MenuItem> items;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 4
            : (constraints.maxWidth >= 680 ? 2 : 1);
        const gap = 24.0;
        final itemWidth = columns == 1
            ? (constraints.maxWidth < 260 ? constraints.maxWidth : 260.0)
            : (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          alignment: columns == 1 ? WrapAlignment.center : WrapAlignment.start,
          spacing: gap,
          runSpacing: 54,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _MenuItemCard(item: item, cardColor: cardColor),
              ),
          ],
        );
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.cardColor});

  final _MenuItem item;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final badgeKo = item.badgeKo ?? (item.signature ? '대표' : null);
    final badgeEn = item.badgeEn ?? (item.signature ? 'Best' : null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 260 / 263,
          child: _MenuArtCard(item: item, cardColor: cardColor),
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                tr(item.name, item.nameEn),
                style: const TextStyle(
                  color: Color(0xFF1C1C18),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            if (badgeKo != null && badgeEn != null) ...[
              const SizedBox(width: 10),
              _MenuBadge(label: tr(badgeKo, badgeEn)),
            ],
          ],
        ),
        const SizedBox(height: 14),
        for (final price in item.prices)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                if (price.temp.isNotEmpty)
                  SizedBox(
                    width: 34,
                    child: Text(
                      price.temp,
                      style: const TextStyle(
                        color: _tempColor,
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                Text(
                  tr('${price.amount}원', '${price.amount}W'),
                  style: const TextStyle(
                    color: _titleColor,
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MenuArtCard extends StatelessWidget {
  const _MenuArtCard({required this.item, required this.cardColor});

  final _MenuItem item;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    if (item.rowCrop case final crop?) {
      return _CroppedRowCard(asset: item.image, crop: crop);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: _cardBorder, width: 3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: item.imagePadding,
        child: Align(
          alignment: item.imageAlignment,
          child: switch (item.specialArt) {
            _SpecialArt.mugwortLatte => const _MugwortLatteArt(),
            _SpecialArt.none => _MenuAsset(
              path: item.image,
              fit: BoxFit.contain,
            ),
          },
        ),
      ),
    );
  }
}

class _MenuAsset extends StatelessWidget {
  const _MenuAsset({required this.path, required this.fit});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return const SizedBox.shrink();
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(path, fit: fit, clipBehavior: Clip.none);
    }
    return Image.asset(
      path,
      fit: fit,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
    );
  }
}

class _CroppedRowCard extends StatelessWidget {
  const _CroppedRowCard({required this.asset, required this.crop});

  final String asset;
  final _RowCrop crop;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 260;
          return ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -crop.left * scale,
                  top: 0,
                  width: 1112 * scale,
                  height: constraints.maxHeight,
                  child: asset.endsWith('.svg')
                      ? SvgPicture.asset(
                          asset,
                          fit: BoxFit.fill,
                          clipBehavior: Clip.none,
                        )
                      : Image.asset(
                          asset,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MugwortLatteArt extends StatelessWidget {
  const _MugwortLatteArt();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 154,
        height: 262,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 30,
              top: -6,
              width: 10,
              height: 230,
              child: Transform.rotate(
                angle: -0.2,
                alignment: Alignment.topCenter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 11,
              top: 44,
              width: 116,
              height: 202,
              child: _MenuAsset(
                path: 'assets/figma/menu/mugwort_latte_back.svg',
                fit: BoxFit.fill,
              ),
            ),
            for (final foam in _mugwortFoam)
              Positioned(
                left: foam.left,
                top: foam.top,
                width: foam.size,
                height: foam.size,
                child: Transform.rotate(
                  angle: foam.angle,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: foam.opacity),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: foam.opacity),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            for (final leaf in _mugwortLeaves)
              Positioned(
                left: leaf.left,
                top: leaf.top,
                width: leaf.width,
                height: leaf.height,
                child: Transform.rotate(
                  angle: leaf.angle,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF566341),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            const Positioned(
              left: 0,
              top: 34,
              width: 138,
              height: 228,
              child: _MenuAsset(
                path: 'assets/figma/menu/mugwort_latte_body.svg',
                fit: BoxFit.fill,
              ),
            ),
            const Positioned(
              left: 0,
              top: 34,
              width: 138,
              height: 228,
              child: _MenuAsset(
                path: 'assets/figma/menu/mugwort_latte_highlight.svg',
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MugwortFoam {
  const _MugwortFoam(this.left, this.top, this.size, this.angle, this.opacity);

  final double left;
  final double top;
  final double size;
  final double angle;
  final double opacity;
}

class _MugwortLeaf {
  const _MugwortLeaf(this.left, this.top, this.width, this.height, this.angle);

  final double left;
  final double top;
  final double width;
  final double height;
  final double angle;
}

const _mugwortFoam = <_MugwortFoam>[
  _MugwortFoam(28, 62, 39, -0.26, 0.57),
  _MugwortFoam(60, 76, 39, 0.25, 0.98),
  _MugwortFoam(34, 127, 39, -0.16, 0.41),
  _MugwortFoam(58, 138, 39, -0.53, 0.59),
  _MugwortFoam(41, 190, 39, 0.23, 0.86),
];

const _mugwortLeaves = <_MugwortLeaf>[
  _MugwortLeaf(84, 39, 5, 30, -0.01),
  _MugwortLeaf(88, 8, 5, 30, 0.37),
  _MugwortLeaf(99, 8, 5, 41, 0.77),
  _MugwortLeaf(71, 38, 5, 30, 0.85),
];

class _MenuBadge extends StatelessWidget {
  const _MenuBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: _maroon),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _signatureColor,
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─── 페이지네이션 ─────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.count,
    required this.active,
    required this.onChanged,
  });

  final int count;
  final int active;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageArrow(
          icon: Icons.arrow_back_ios_rounded,
          enabled: active > 0,
          onTap: () => onChanged(active - 1),
        ),
        const SizedBox(width: 12),
        for (var i = 0; i < count; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          _PageDot(
            index: i + 1,
            active: i == active,
            onTap: () => onChanged(i),
          ),
        ],
        const SizedBox(width: 12),
        _PageArrow(
          icon: Icons.arrow_forward_ios_rounded,
          enabled: active < count - 1,
          onTap: () => onChanged(active + 1),
        ),
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({
    required this.index,
    required this.active,
    required this.onTap,
  });

  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _maroon : Colors.transparent,
          shape: BoxShape.circle,
          border: active
              ? null
              : Border.all(color: const Color(0xFFCDC2C2), width: 2),
        ),
        child: Text(
          '$index',
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFCDC2C2),
            fontFamily: 'Pretendard',
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      iconSize: 16,
      color: _titleColor,
      disabledColor: const Color(0xFFCBC2C2),
      icon: Icon(icon),
    );
  }
}

// ─── 준비 중 카테고리 (다과 / 빙수) ────────────────────────────────────────
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.category});

  final _MenuCategory category;

  @override
  Widget build(BuildContext context) {
    final label = tr(category.labelKo, category.labelEn);
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder, width: 2),
      ),
      child: Text(
        tr('$label 메뉴는 곧 업데이트됩니다.', 'The $label menu is coming soon.'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _tempColor,
          fontFamily: 'Gowun Batang',
          fontFamilyFallback: _serifFallback,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}
