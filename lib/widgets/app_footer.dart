import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../theme/app_colors.dart';
import 'common.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Container(
      width: double.infinity,
      color: AppColors.deep,
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: SectionShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 5, child: _FooterBrand()),
                      SizedBox(width: 32),
                      Expanded(flex: 3, child: _FooterInfo()),
                      SizedBox(width: 32),
                      Expanded(flex: 3, child: _FooterContact()),
                    ],
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FooterBrand(),
                      SizedBox(height: 28),
                      _FooterInfo(),
                      SizedBox(height: 28),
                      _FooterContact(),
                    ],
                  ),
            const SizedBox(height: 36),
            Container(
              height: 1,
              color: AppColors.paper.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 22),
            Text(
              '© 2026 $placeName · $placeRoadAddress · 사업자등록번호 추후 기재',
              style: TextStyle(
                color: AppColors.hanji.withValues(alpha: 0.5),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '행궁다과',
          style: TextStyle(
            color: AppColors.paper,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontFamily: 'Noto Serif KR',
            fontFamilyFallback: ['AppleMyungjo', 'serif'],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Haenggung Dagwa',
          style: TextStyle(
            color: AppColors.hanji.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '화성행궁 곁에서 다과상, 전통차,\n빙수와 포장 다과를 만나는 공간입니다.',
          style: TextStyle(
            color: AppColors.hanji.withValues(alpha: 0.8),
            fontSize: 15,
            height: 1.75,
          ),
        ),
      ],
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FooterSectionTitle('운영 안내'),
        const SizedBox(height: 14),
        _FooterInfoRow(icon: Icons.schedule_outlined, text: placeTodayStatus),
        const SizedBox(height: 10),
        _FooterInfoRow(
          icon: Icons.event_busy_outlined,
          text: placeRegularClosed,
        ),
        const SizedBox(height: 10),
        _FooterInfoRow(
          icon: Icons.location_on_outlined,
          text: placeRoadAddress,
        ),
        const SizedBox(height: 10),
        _FooterInfoRow(icon: Icons.info_outline_rounded, text: placeShortHours),
      ],
    );
  }
}

class _FooterContact extends StatelessWidget {
  const _FooterContact();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FooterSectionTitle('연락처'),
        const SizedBox(height: 14),
        _FooterInfoRow(icon: Icons.phone_outlined, text: placePhone),
        const SizedBox(height: 10),
        _FooterInfoRow(icon: Icons.map_outlined, text: placeNaverUrl),
        const SizedBox(height: 10),
        _FooterInfoRow(
          icon: Icons.camera_alt_outlined,
          text: '@haenggung_da_gwa_1',
        ),
        const SizedBox(height: 20),
        Text(
          '체험과 케이터링은\n사전 전화 확인을 권장합니다.',
          style: TextStyle(
            color: AppColors.gold.withValues(alpha: 0.85),
            fontSize: 13,
            height: 1.7,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FooterSectionTitle extends StatelessWidget {
  const _FooterSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.paper,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _FooterInfoRow extends StatelessWidget {
  const _FooterInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold.withValues(alpha: 0.7), size: 16),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.hanji.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
