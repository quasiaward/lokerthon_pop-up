import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common.dart';
import 'watercolor_deco.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

const _menuCategories = ['모든 메뉴', '대표 다과', '전통차', '음료', '빙수', '다과상'];

const _menuItems = [
  _FigmaMenuItem(
    name: '대추차',
    englishName: 'Jujube Tea',
    price: '8,000원',
    image: 'assets/figma/menu_jujube_tea.png',
    tags: ['대표', '전통차'],
    categories: ['전통차', '음료'],
  ),
  _FigmaMenuItem(
    name: '쌍화차',
    englishName: 'Hanbang Ssanghwacha',
    price: '8,000원',
    image: 'assets/figma/menu_ssanghwa_tea.png',
    tags: ['전통차'],
    categories: ['전통차', '음료'],
  ),
  _FigmaMenuItem(
    name: '생강차',
    englishName: 'Traditional Ginger Tea',
    price: '6,000원',
    image: 'assets/figma/menu_ginger_tea.png',
    tags: ['전통차'],
    categories: ['전통차', '음료'],
  ),
  _FigmaMenuItem(
    name: '식혜',
    englishName: 'Sweet Rice Punch',
    price: '4,500원',
    image: 'assets/figma/menu_sikhye.png',
    tags: ['전통차'],
    categories: ['전통차', '음료'],
  ),
  _FigmaMenuItem(
    name: '베리레몬차',
    englishName: 'TripleBerryLemon Tea',
    price: '5,500원',
    image: 'assets/figma/menu_berry_lemon_tea.png',
    tags: ['음료'],
    categories: ['음료'],
  ),
  _FigmaMenuItem(
    name: '흑임자 라떼',
    englishName: 'Black Sesame Latte',
    price: '5,500원',
    image: 'assets/figma/menu_black_sesame_latte.png',
    tags: ['대표', '음료'],
    categories: ['음료'],
  ),
  _FigmaMenuItem(
    name: '오미자차',
    englishName: 'Omiija Tea',
    price: '5,000원',
    image: 'assets/figma/menu_omija_tea.png',
    tags: ['대표', '전통차'],
    categories: ['전통차', '음료'],
  ),
  _FigmaMenuItem(
    name: '오미자 수단',
    englishName: 'Omiija Tea with Teok',
    price: '6,500원',
    image: 'assets/figma/menu_omija_sudan.png',
    tags: ['대표', '전통차'],
    categories: ['대표 다과', '전통차', '다과상'],
  ),
];

class MenuSection extends StatefulWidget {
  const MenuSection({super.key});

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  String _category = '모든 메뉴';

  List<_FigmaMenuItem> get _visibleItems {
    if (_category == '모든 메뉴') return _menuItems;
    if (_category == '대표 다과') {
      return _menuItems.where((item) => item.tags.contains('대표')).toList();
    }
    if (_category == '빙수') return const [];
    return _menuItems
        .where((item) => item.categories.contains(_category))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final deco = decoScaleOf(context, designWidth: 1409);

    return Container(
      color: const Color(0xFFF5F5F3),
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
                  const Text(
                    '행궁다과 메뉴',
                    style: TextStyle(
                      color: Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 34),
                  _CategoryTabs(
                    selected: _category,
                    onChanged: (category) =>
                        setState(() => _category = category),
                  ),
                  const SizedBox(height: 52),
                  const _MenuToolbar(),
                  const SizedBox(height: 24),
                  _MenuGrid(items: _visibleItems),
                  if (_visibleItems.isEmpty) const _EmptyCategory(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 12,
      children: [
        for (final category in _menuCategories)
          _CategoryPill(
            label: category,
            selected: category == selected,
            onTap: () => onChanged(category),
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
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF934753) : const Color(0xFFE6E6E6),
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

class _MenuToolbar extends StatelessWidget {
  const _MenuToolbar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB5B5B5)),
            color: Colors.transparent,
          ),
          child: const Text(
            '한국어',
            style: TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          itemBuilder: (context) => const [
            PopupMenuItem(value: '추천순', child: Text('추천순')),
            PopupMenuItem(value: '가격 낮은순', child: Text('가격 낮은순')),
          ],
          child: const Row(
            children: [
              Text(
                '추천순',
                style: TextStyle(
                  color: Color(0xFF534344),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF534344)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.items});

  final List<_FigmaMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 4
            : (constraints.maxWidth >= 680 ? 2 : 1);
        final gap = columns == 1 ? 28.0 : 24.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 34,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _MenuPhotoCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _MenuPhotoCard extends StatelessWidget {
  const _MenuPhotoCard({required this.item});

  final _FigmaMenuItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(item.image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            if (item.tags.contains('대표'))
              const Text(
                '대표 다과',
                style: TextStyle(
                  color: Color(0xFFE49A78),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          item.englishName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF534344),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Wrap(
              spacing: 5,
              children: [for (final tag in item.tags) _MiniTag(label: tag)],
            ),
            const Spacer(),
            Text(
              item.price,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBCBCBC)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Gowun Batang',
          fontFamilyFallback: _serifFallback,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat),
      ),
      child: const Text(
        '해당 카테고리의 메뉴는 준비 중입니다.',
        style: TextStyle(color: AppColors.muted, fontSize: 15),
      ),
    );
  }
}

class _FigmaMenuItem {
  const _FigmaMenuItem({
    required this.name,
    required this.englishName,
    required this.price,
    required this.image,
    required this.tags,
    required this.categories,
  });

  final String name;
  final String englishName;
  final String price;
  final String image;
  final List<String> tags;
  final List<String> categories;
}
