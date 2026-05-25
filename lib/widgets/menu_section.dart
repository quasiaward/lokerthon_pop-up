import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../theme/app_colors.dart';
import 'common.dart';

enum MenuLanguage {
  ko('한국어'),
  en('English'),
  ja('日本語');

  const MenuLanguage(this.label);
  final String label;
}

class MenuSection extends StatefulWidget {
  const MenuSection({super.key});

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  MenuLanguage _language = MenuLanguage.ko;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1040 ? 4 : (width >= 700 ? 2 : 1);

    return Container(
      color: AppColors.paper,
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: SectionShell(
        child: Column(
          children: [
            const SectionHeading(
              eyebrow: 'Menu',
              title: '행궁다과 메뉴',
              description: '다과상, 화전, 전통차, 빙수의 대표 메뉴와 가격을 정리했습니다.',
            ),
            const SizedBox(height: 26),
            const _MenuCategoryStrip(),
            const SizedBox(height: 28),
            // 언어 탭 (React 스타일: 직각, 선택 시 dark 배경)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.wheat),
                color: AppColors.paper,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < MenuLanguage.values.length; i++) ...[
                    _LangTab(
                      language: MenuLanguage.values[i],
                      selected: MenuLanguage.values[i] == _language,
                      onTap: () =>
                          setState(() => _language = MenuLanguage.values[i]),
                    ),
                    if (i < MenuLanguage.values.length - 1)
                      Container(width: 1, height: 46, color: AppColors.wheat),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actualMenuItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: columns == 1
                    ? 0.94
                    : (columns == 2 ? 0.84 : 0.74),
              ),
              itemBuilder: (context, index) =>
                  _MenuCard(item: actualMenuItems[index], language: _language),
            ),
            const SizedBox(height: 16),
            Text(
              '* 표시된 가격은 공개 메뉴 기준이며 구성과 시즌에 따라 달라질 수 있습니다.',
              style: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCategoryStrip extends StatelessWidget {
  const _MenuCategoryStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: const [
        _MenuCue(icon: Icons.restaurant_menu_outlined, label: '대표 다과'),
        _MenuCue(icon: Icons.local_cafe_outlined, label: '전통차'),
        _MenuCue(icon: Icons.icecream_outlined, label: '빙수'),
        _MenuCue(icon: Icons.card_giftcard_outlined, label: '포장 다과'),
      ],
    );
  }
}

class _MenuCue extends StatelessWidget {
  const _MenuCue({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.hanji.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat.withValues(alpha: 0.82)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.cinnabar),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.brown,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 언어 탭 ─────────────────────────────────────────
class _LangTab extends StatelessWidget {
  const _LangTab({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final MenuLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        color: selected ? AppColors.deep : Colors.transparent,
        child: Text(
          language.label,
          style: TextStyle(
            color: selected ? AppColors.paper : AppColors.muted,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── 메뉴 카드 ───────────────────────────────────────
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item, required this.language});

  final ActualMenuItem item;
  final MenuLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 심볼 영역
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.hanji,
                      AppColors.porcelain.withValues(alpha: 0.72),
                    ],
                  ),
                  border: Border(bottom: BorderSide(color: AppColors.wheat)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.deep,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.price,
                          style: const TextStyle(
                            color: Color(0xFFE8D8C0),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.paper.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.26),
                          ),
                        ),
                        child: Text(
                          item.symbol,
                          style: TextStyle(
                            color: item.accent,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Noto Serif KR',
                            fontFamilyFallback: const ['AppleMyungjo', 'serif'],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 하단 텍스트 영역
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: AppColors.cinnabar,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name(language),
                      style: const TextStyle(
                        color: AppColors.deep,
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Noto Serif KR',
                        fontFamilyFallback: ['AppleMyungjo', 'serif'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        item.description(language),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [TagPill(label: item.tag)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on ActualMenuItem {
  String name(MenuLanguage language) => switch (language) {
    MenuLanguage.ko => ko,
    MenuLanguage.en => en,
    MenuLanguage.ja => ja,
  };

  String description(MenuLanguage language) => switch (language) {
    MenuLanguage.ko => koDescription,
    MenuLanguage.en => enDescription,
    MenuLanguage.ja => jaDescription,
  };
}
