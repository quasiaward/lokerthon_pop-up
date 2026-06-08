import 'package:flutter/material.dart';

import '../data/place_info.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 820;
    final padding = MediaQuery.sizeOf(context).width < 420 ? 20.0 : 36.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFB0A79D),
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1142),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              children: [
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(flex: 4, child: _FooterBrandBlock()),
                          SizedBox(width: 44),
                          Expanded(flex: 3, child: _FooterInfoBlock()),
                          SizedBox(width: 44),
                          Expanded(flex: 3, child: _FooterContactBlock()),
                        ],
                      )
                    : const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FooterBrandBlock(),
                          SizedBox(height: 28),
                          _FooterInfoBlock(),
                          SizedBox(height: 28),
                          _FooterContactBlock(),
                        ],
                      ),
                const SizedBox(height: 54),
                Text(
                  '© 2026 행궁다과. 경기 수원시 팔달구 행궁로 25 2층. 사업자등록번호 추후 기재',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFEEEDE2).withValues(alpha: 0.7),
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    height: 1.35,
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

class _FooterBrandBlock extends StatelessWidget {
  const _FooterBrandBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          placeName,
          style: TextStyle(
            color: Color(0xFFFBF2E5),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        SizedBox(height: 30),
        Text(
          '화성행궁 곁에서 다과상, 전통차,\n빙수와 포장 다과를 만나는 공간입니다.',
          style: TextStyle(
            color: Color(0xFFE3D8C9),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FooterInfoBlock extends StatelessWidget {
  const _FooterInfoBlock();

  @override
  Widget build(BuildContext context) {
    return const _FooterColumn(
      title: '운영 안내',
      lines: [
        placeTodayStatus,
        placeRegularClosed,
        placeRoadAddress,
        placeShortHours,
      ],
    );
  }
}

class _FooterContactBlock extends StatelessWidget {
  const _FooterContactBlock();

  @override
  Widget build(BuildContext context) {
    return const _FooterColumn(
      title: '연락처',
      lines: [placePhone, placeNaverUrl, '@haenggung_da_gwa_1'],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFBF2E5),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        for (final line in lines) ...[
          Text(
            line,
            style: const TextStyle(
              color: Color(0xFFE3D8C9),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
