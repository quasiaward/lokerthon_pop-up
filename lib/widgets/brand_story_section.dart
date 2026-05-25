import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../theme/app_colors.dart';
import 'common.dart';

class BrandStorySection extends StatelessWidget {
  const BrandStorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 820;

    const stories = [
      _StoryItem(
        icon: Icons.location_on_outlined,
        eyebrow: '행궁로 25 2층',
        title: '화성행궁 산책길의 찻집',
        description: '화성행궁에서 걸어가기 좋은 위치에 있어 관람 전후 다과상과 차 한 잔으로 쉬어가기 좋습니다.',
      ),
      _StoryItem(
        icon: Icons.spa_outlined,
        eyebrow: '명인의 손맛',
        title: '떡과 다과를 정갈하게',
        description: '영양찰떡, 약과, 정과를 차와 함께 담아 전통 디저트를 부담 없는 한 상으로 제안합니다.',
      ),
      _StoryItem(
        icon: Icons.icecream_outlined,
        eyebrow: '빙수와 포장',
        title: '계절 메뉴와 작은 선물',
        description: '빙수, 전통차, 개별 약과까지 방문 목적에 따라 매장에서 먹거나 가볍게 챙겨 갈 수 있습니다.',
      ),
    ];

    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: SectionShell(
        child: Column(
          children: [
            const SectionHeading(
              eyebrow: 'Brand',
              title: '행궁동 전통 디저트',
              description: '화성행궁 인근 2층 찻집. 다과상, 전통차, 계절 빙수를 즐길 수 있습니다.',
            ),
            const SizedBox(height: 52),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < stories.length; i++) ...[
                        Expanded(child: _StoryCard(item: stories[i])),
                        if (i != stories.length - 1) const SizedBox(width: 20),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      for (final story in stories) ...[
                        _StoryCard(item: story),
                        const SizedBox(height: 18),
                      ],
                    ],
                  ),
            const SizedBox(height: 28),
            const _BrandProofBand(),
          ],
        ),
      ),
    );
  }
}

class _BrandProofBand extends StatelessWidget {
  const _BrandProofBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.deep,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
      ),
      child: const Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        spacing: 18,
        children: [
          _ProofItem(label: '공간', value: '화성행궁 옆 2층'),
          _ProofItem(label: '리뷰', value: placeVisitorReviewText),
          _ProofItem(label: '블로그', value: placeBlogReviewText),
          _ProofItem(label: '휴무', value: placeRegularClosed),
        ],
      ),
    );
  }
}

class _ProofItem extends StatelessWidget {
  const _ProofItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.gold.withValues(alpha: 0.84),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.paper,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryItem {
  const _StoryItem({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.item});
  final _StoryItem item;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 원형 (React 스타일: gold tint border)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.36)),
            ),
            child: Icon(item.icon, color: AppColors.cinnabar, size: 22),
          ),
          const SizedBox(height: 20),
          // Eyebrow
          Text(
            item.eyebrow.toUpperCase(),
            style: const TextStyle(
              color: AppColors.cinnabar,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              color: AppColors.deep,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Serif KR',
              fontFamilyFallback: ['AppleMyungjo', 'serif'],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.description,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.78,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
