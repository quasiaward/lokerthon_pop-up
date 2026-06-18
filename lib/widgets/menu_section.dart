import 'package:flutter/material.dart';

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

class _MenuItem {
  const _MenuItem({
    required this.name,
    required this.nameEn,
    required this.image,
    required this.prices,
    this.signature = false,
  });

  final String name;
  final String nameEn;
  final String image; // asset 경로
  final List<_Price> prices; // 1~2개 (HOT/ICE)
  final bool signature; // '대표' 태그

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

// ─── 음료 (Beverage) — Figma 1페이지 16종 ─────────────────────────────────
const _beverages = <_MenuItem>[
  _MenuItem(
    name: '대추차',
    nameEn: 'Jujube Tea',
    image: 'assets/figma/menu/jujube_tea.png',
    prices: [_Price('HOT', '8,000')],
  ),
  _MenuItem(
    name: '쌍화차',
    nameEn: 'Ssanghwa Tea',
    image: 'assets/figma/menu/ssanghwa_tea.png',
    prices: [_Price('HOT', '8,000')],
  ),
  _MenuItem(
    name: '생강차',
    nameEn: 'Ginger Tea',
    image: 'assets/figma/menu/ginger_tea.png',
    prices: [_Price('HOT', '6,000')],
  ),
  _MenuItem(
    name: '오미자 수단',
    nameEn: 'Omija Tea with Teok',
    image: 'assets/figma/menu/omija_sudan.png',
    prices: [_Price('ICE', '6,000')],
    signature: true,
  ),
  _MenuItem(
    name: '식혜',
    nameEn: 'Sweet Rice Punch',
    image: 'assets/figma/menu/sikhye.png',
    prices: [_Price('ICE', '4,500')],
  ),
  _MenuItem(
    name: '레몬 생강차',
    nameEn: 'Lemon Ginger Tea',
    image: 'assets/figma/menu/lemon_ginger_tea.png',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
  ),
  _MenuItem(
    name: '베리 레몬차',
    nameEn: 'Berry Lemon Tea',
    image: 'assets/figma/menu/berry_lemon_tea.png',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
  ),
  _MenuItem(
    name: '석류 레몬차',
    nameEn: 'Pomegranate Lemon Tea',
    image: 'assets/figma/menu/pomegranate_lemon_tea.png',
    prices: [_Price('HOT', '5,500'), _Price('ICE', '6,000')],
  ),
  _MenuItem(
    name: '오미자차',
    nameEn: 'Omija Tea',
    image: 'assets/figma/menu/omija_tea.png',
    prices: [_Price('HOT', '5,000'), _Price('ICE', '5,500')],
  ),
  _MenuItem(
    name: '유자차 / 에이드',
    nameEn: 'Yuja Tea / Ade',
    image: 'assets/figma/menu/yuja_ade.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '레몬차 / 에이드',
    nameEn: 'Lemon Tea / Ade',
    image: 'assets/figma/menu/lemon_ade.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '자몽차 / 에이드',
    nameEn: 'Grapefruit Tea / Ade',
    image: 'assets/figma/menu/grapefruit_ade.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '라임차 / 에이드',
    nameEn: 'Lime Tea / Ade',
    image: 'assets/figma/menu/lime_ade.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '청귤차 / 에이드',
    nameEn: 'Green Tangerine Tea / Ade',
    image: 'assets/figma/menu/green_tangerine_ade.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '모과차 / 에이드',
    nameEn: 'Quince Tea / Ade',
    image: 'assets/figma/menu/quince_ade.png',
    prices: [_Price('HOT', '4,500'), _Price('ICE', '5,000')],
  ),
  _MenuItem(
    name: '청포도 에이드',
    nameEn: 'Green Grape Ade',
    image: 'assets/figma/menu/green_grape_ade.png',
    prices: [_Price('ICE', '5,000')],
  ),
];

// 다과 / 빙수는 Figma 프레임을 추가로 받아 채울 예정(일러스트·배경색 대기 중).
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
    items: [],
    cardColor: Color(0xFFE7EBE3),
  ),
  _MenuCategory(
    key: '빙수',
    labelKo: '빙수',
    labelEn: 'Bingsu',
    items: [],
    cardColor: Color(0xFFEDE6DC),
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
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 40,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 260 / 263,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: _cardBorder, width: 3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  item.image,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stack) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            if (item.signature) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  tr('대표', 'Best'),
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
            ],
          ],
        ),
        const SizedBox(height: 10),
        for (final price in item.prices)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
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
                    color: Color(0xFF2A2320),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
      ],
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
          _PageDot(active: i == active, onTap: () => onChanged(i)),
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
  const _PageDot({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          color: active ? _maroon : const Color(0xFFD3C8C8),
          shape: BoxShape.circle,
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
