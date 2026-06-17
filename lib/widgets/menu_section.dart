import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import 'common.dart';
import 'lang_toggle.dart';
import 'watercolor_deco.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

// ── 데이터 모델 ────────────────────────────────────────────────────────────────
// 메뉴 추가하려면 _menuItems 리스트에 _MenuItem 항목 하나 추가하세요.
// hotPrice / icePrice 둘 다 있으면 둘 다 표시, 하나만 있으면 하나만 표시.
// category: '음료' | '다과' | '빙수'

class _MenuItem {
  const _MenuItem({
    required this.name,
    required this.nameEn,
    required this.category,
    this.hotPrice,
    this.icePrice,
    required this.imagePath,
    this.description = '',
    this.isNew = false,
  });

  final String name;
  final String nameEn;
  final String category;
  final int? hotPrice;
  final int? icePrice;
  final String imagePath;
  final String description;
  final bool isNew;
}

const _menuItems = <_MenuItem>[
  // ── 음료 ──
  _MenuItem(
    name: '대추차',
    nameEn: 'Jujube Tea',
    category: '음료',
    hotPrice: 8000,
    imagePath: 'assets/figma/menu_jujube_tea.png',
    description: '',
  ),
  _MenuItem(
    name: '쌍화차',
    nameEn: 'Ssanghwa Tea',
    category: '음료',
    hotPrice: 9000,
    imagePath: 'assets/figma/menu_ssanghwa_tea.png',
    description: '',
  ),
  _MenuItem(
    name: '생강차',
    nameEn: 'Ginger Tea',
    category: '음료',
    hotPrice: 8000,
    imagePath: 'assets/figma/menu_ginger_tea.png',
    description: '',
  ),
  _MenuItem(
    name: '식혜',
    nameEn: 'Sweet Rice Punch',
    category: '음료',
    icePrice: 4500,
    imagePath: 'assets/figma/menu_sikhye.png',
    description: '',
  ),
  _MenuItem(
    name: '오미자차',
    nameEn: 'Omija Tea',
    category: '음료',
    hotPrice: 5000,
    icePrice: 5000,
    imagePath: 'assets/figma/menu_omija_tea.png',
    description: '',
  ),
  _MenuItem(
    name: '오미자 수단',
    nameEn: 'Omija Tea with Tteok',
    category: '음료',
    hotPrice: 6500,
    icePrice: 6500,
    imagePath: 'assets/figma/menu_omija_sudan.png',
    description: '',
    isNew: true,
  ),
  _MenuItem(
    name: '베리레몬차',
    nameEn: 'Berry Lemon Tea',
    category: '음료',
    hotPrice: 5500,
    icePrice: 6000,
    imagePath: 'assets/figma/menu_berry_lemon_tea.png',
    description: '',
  ),
  _MenuItem(
    name: '흑임자 라떼',
    nameEn: 'Black Sesame Latte',
    category: '음료',
    hotPrice: 5500,
    icePrice: 5500,
    imagePath: 'assets/figma/menu_black_sesame_latte.png',
    description: '',
  ),

  // ── 다과 ──
  _MenuItem(
    name: '약과',
    nameEn: 'Yakgwa',
    category: '다과',
    hotPrice: 3000,
    imagePath: 'assets/figma/menu_yakgwa.png',
    description: '',
  ),
  _MenuItem(
    name: '다과상',
    nameEn: 'Dagwa Tray',
    category: '다과',
    hotPrice: 15000,
    imagePath: 'assets/figma/menu_dagwasang.png',
    description: '',
  ),

  // ── 빙수 ──
  _MenuItem(
    name: '그린 빙수',
    nameEn: 'Green Bingsu',
    category: '빙수',
    icePrice: 9000,
    imagePath: 'assets/figma/menu_green_bingsu.png',
    description: '',
  ),
];

// ── 카테고리 ───────────────────────────────────────────────────────────────────

const _categories = ['음료', '다과', '빙수'];

String _catLabel(String c) => switch (c) {
      '음료' => tr(c, 'Beverage'),
      '다과' => tr(c, 'Dessert'),
      '빙수' => tr(c, 'Bingsu'),
      _ => c,
    };

// ── 가격 포맷 ──────────────────────────────────────────────────────────────────

String _won(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${buf.toString()}원';
}

// ── 메인 위젯 ─────────────────────────────────────────────────────────────────

class MenuSection extends StatefulWidget {
  const MenuSection({super.key});

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  String _category = _categories.first;

  List<_MenuItem> get _visible =>
      _menuItems.where((m) => m.category == _category).toList();

  void _showModal(_MenuItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _MenuModal(item: item),
    );
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
                  // 제목
                  Text(
                    'MENU',
                    style: const TextStyle(
                      color: Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 34),

                  // 카테고리 탭
                  _CategoryTabs(
                    selected: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                  const SizedBox(height: 40),

                  // 툴바 (언어 토글 + 정렬)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB5B5B5)),
                        ),
                        child: const LangToggle(),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: '추천순',
                            child: Text(tr('추천순', 'Recommended')),
                          ),
                        ],
                        child: Row(
                          children: [
                            Text(
                              tr('추천순', 'Recommend'),
                              style: const TextStyle(
                                color: Color(0xFF534344),
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF534344)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 메뉴 그리드
                  if (_visible.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 28),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.wheat),
                      ),
                      child: Text(
                        tr('해당 카테고리의 메뉴는 준비 중입니다.',
                            'Items in this category are coming soon.'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 15,
                        ),
                      ),
                    )
                  else
                    _MenuGrid(
                      items: _visible,
                      onTap: _showModal,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 카테고리 탭 ────────────────────────────────────────────────────────────────

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final c in _categories)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => onChanged(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: c == selected
                      ? const Color(0xFF7A3B47)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: c == selected
                        ? const Color(0xFF7A3B47)
                        : const Color(0xFFB5B5B5),
                  ),
                ),
                child: Text(
                  _catLabel(c),
                  style: TextStyle(
                    color: c == selected ? Colors.white : const Color(0xFF6B5B5A),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── 메뉴 그리드 ────────────────────────────────────────────────────────────────

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.items, required this.onTap});

  final List<_MenuItem> items;
  final ValueChanged<_MenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 4
            : (constraints.maxWidth >= 680 ? 2 : 1);
        final gap = 24.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 34,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _MenuCard(item: item, onTap: () => onTap(item)),
              ),
          ],
        );
      },
    );
  }
}

// ── 메뉴 카드 ─────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.onTap});

  final _MenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF0E8E5),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Color(0xFFCFC4C0), size: 40),
                      ),
                    ),
                  ),
                ),
              ),
              if (item.isNew)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A3B47),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gowun Batang',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 이름
          Text(
            tr(item.name, item.nameEn),
            style: const TextStyle(
              color: Color(0xFF2C1F1F),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr(item.nameEn, item.name),
            style: const TextStyle(
              color: Color(0xFF8C7E7B),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          // HOT / ICE 가격
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (item.hotPrice != null)
                _PriceBadge(
                  label: 'HOT',
                  price: _won(item.hotPrice!),
                  color: const Color(0xFF934753),
                ),
              if (item.icePrice != null)
                _PriceBadge(
                  label: 'ICE',
                  price: _won(item.icePrice!),
                  color: const Color(0xFF4A7FA5),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  const _PriceBadge({
    required this.label,
    required this.price,
    required this.color,
  });

  final String label;
  final String price;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Gowun Batang',
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          price,
          style: TextStyle(
            color: color,
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── 모달 ──────────────────────────────────────────────────────────────────────

class _MenuModal extends StatelessWidget {
  const _MenuModal({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 이미지
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF0E8E5),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              color: Color(0xFFCFC4C0), size: 48),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름 + 닫기
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.isNew)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7A3B47),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Text(
                                      'New',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Gowun Batang',
                                      ),
                                    ),
                                  ),
                                Text(
                                  tr(item.name, item.nameEn),
                                  style: const TextStyle(
                                    color: Color(0xFF2C1F1F),
                                    fontFamily: 'Gowun Batang',
                                    fontFamilyFallback: _serifFallback,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  tr(item.nameEn, item.name),
                                  style: const TextStyle(
                                    color: Color(0xFF8C7E7B),
                                    fontFamily: 'Gowun Batang',
                                    fontFamilyFallback: _serifFallback,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close,
                                color: Color(0xFF8C7E7B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 설명
                      if (item.description.isNotEmpty) ...[
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Color(0xFF6B5B5A),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 15,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 구분선
                      const Divider(color: Color(0xFFEDE4E0)),
                      const SizedBox(height: 16),

                      // 가격
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          if (item.hotPrice != null)
                            _PriceBadge(
                              label: 'HOT',
                              price: _won(item.hotPrice!),
                              color: const Color(0xFF934753),
                            ),
                          if (item.icePrice != null)
                            _PriceBadge(
                              label: 'ICE',
                              price: _won(item.icePrice!),
                              color: const Color(0xFF4A7FA5),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
