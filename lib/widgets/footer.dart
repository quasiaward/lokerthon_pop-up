import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../l10n/lang.dart';

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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 820;
    final padding = width < 420 ? 20.0 : (isWide ? 0.0 : 36.0);

    return Container(
      width: double.infinity,
      height: isWide ? 339 : null,
      color: const Color(0xFFB0A79D),
      padding: EdgeInsets.symmetric(vertical: isWide ? 0 : 54),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1142),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: isWide
                ? Stack(
                    children: [
                      const Positioned(
                        left: 4,
                        top: 75,
                        width: 303,
                        child: _FooterBrandBlock(),
                      ),
                      const Positioned(
                        left: 559,
                        top: 75,
                        width: 316,
                        child: _FooterInfoBlock(),
                      ),
                      const Positioned(
                        left: 909,
                        top: 75,
                        width: 190,
                        child: _FooterContactBlock(),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 25,
                        child: _FooterCopyright(),
                      ),
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
                      SizedBox(height: 54),
                      _FooterCopyright(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(placeName, placeNameEn),
          style: const TextStyle(
            color: Color(0xFFFBF2E5),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          tr(
            '화성행궁 곁에서\n전통차와 다과를 만나는 공간입니다.',
            'Beside Hwaseong Palace —\na space for traditional tea and dagwa.',
          ),
          style: const TextStyle(
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
    return _FooterColumn(
      title: tr('운영 안내', 'Hours & Info'),
      lines: [
        tr(placeTodayStatus, placeTodayStatusEn),
        tr(placeRegularClosed, placeRegularClosedEn),
        tr(placeRoadAddress, placeRoadAddressEn),
        tr(placeShortHours, placeShortHoursEn),
      ],
    );
  }
}

class _FooterContactBlock extends StatelessWidget {
  const _FooterContactBlock();

  @override
  Widget build(BuildContext context) {
    return _FooterColumn(
      title: tr('연락처', 'Contact'),
      lines: const [placePhone, placeNaverUrl, '@haenggung_da_gwa'],
    );
  }
}

class _FooterCopyright extends StatelessWidget {
  const _FooterCopyright();

  @override
  Widget build(BuildContext context) {
    return Text(
      tr(
        '© 2026 행궁다과. 경기 수원시 팔달구 행궁로 25 2층. 사업자등록번호 추후 기재',
        '© 2026 Haenggung Dagwa. 25 Haenggung-ro 2F, Paldal-gu, Suwon, Gyeonggi. Business reg. no. to be announced.',
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFFEEEDE2).withValues(alpha: 0.7),
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        height: 1.35,
      ),
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
        const SizedBox(height: 15),
        for (final line in lines) ...[
          Text(
            line,
            style: const TextStyle(
              color: Color(0xFFE3D8C9),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
