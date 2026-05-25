import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'common.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({
    super.key,
    required this.onLogoTap,
    required this.onBrandTap,
    required this.onMenuTap,
    required this.onReservationTap,
    required this.onCateringTap,
    required this.onAiTap,
  });

  final VoidCallback onLogoTap;
  final VoidCallback onBrandTap;
  final VoidCallback onMenuTap;
  final VoidCallback onReservationTap;
  final VoidCallback onCateringTap;
  final VoidCallback onAiTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 680;

    return Material(
      color: AppColors.paper.withValues(alpha: 0.95),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.wheat)),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: isCompact ? 104 : 72,
            child: SectionShell(
              child: isCompact
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderBrand(onTap: onLogoTap, compact: true),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _NavItem(label: '소개', onTap: onBrandTap),
                              _NavItem(label: '메뉴', onTap: onMenuTap),
                              _NavItem(label: '체험', onTap: onReservationTap),
                              _NavItem(label: '케이터링', onTap: onCateringTap),
                              _NavItem(label: '다과 추천', onTap: onAiTap),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        _HeaderBrand(onTap: onLogoTap),
                        const Spacer(),
                        _NavItem(label: '소개', onTap: onBrandTap),
                        _NavItem(label: '메뉴', onTap: onMenuTap),
                        _NavItem(label: '체험', onTap: onReservationTap),
                        _NavItem(label: '케이터링', onTap: onCateringTap),
                        _NavItem(label: '다과 추천', onTap: onAiTap),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBrand extends StatelessWidget {
  const _HeaderBrand({required this.onTap, this.compact = false});

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: compact ? 34 : 42,
              height: compact ? 34 : 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.46),
                ),
              ),
              child: Center(
                child: Text(
                  '宮',
                  style: TextStyle(
                    color: AppColors.cinnabar,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 15 : 18,
                    fontFamily: 'AppleMyungjo',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '행궁다과',
              style: TextStyle(
                color: AppColors.deep,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                fontFamily: 'Noto Serif KR',
                fontFamilyFallback: ['AppleMyungjo', 'serif'],
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 12),
              Container(width: 1, height: 16, color: AppColors.wheat),
              const SizedBox(width: 12),
              const Text(
                '화성행궁 전통 다과',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.deep,
        overlayColor: AppColors.gold.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        minimumSize: const Size(0, 40),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
