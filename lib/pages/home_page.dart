import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../widgets/brand_logo.dart';
import '../widgets/floating_chatbot.dart';
import '../widgets/footer.dart';

const _heroImage = 'assets/figma/home_hero.png';
const _brandWindowImage = 'assets/figma/brand_window.png';
const _brandTrayImage = 'assets/figma/brand_tray.png';
const _brandTableImage = 'assets/figma/brand_table.png';
const _menuDagwasangImage = 'assets/figma/menu_dagwasang.png';
const _menuBingsuImage = 'assets/figma/menu_green_bingsu.png';
const _menuYakgwaImage = 'assets/figma/menu_yakgwa.png';
const _botanicalDecoImage = 'assets/figma/catering_figma_deco.png';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];
const _sansFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

ImageProvider _imgProvider(String asset) => AssetImage(asset);

Widget _img(String asset, {BoxFit fit = BoxFit.cover}) =>
    Image.asset(asset, fit: fit);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F5),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _HeroSection(
                    onMenuTap: () =>
                        Navigator.pushReplacementNamed(context, '/menu'),
                    onExperienceTap: () =>
                        Navigator.pushReplacementNamed(context, '/experience'),
                    onCateringTap: () =>
                        Navigator.pushReplacementNamed(context, '/catering'),
                    onAiTap: () =>
                        Navigator.pushReplacementNamed(context, '/ai'),
                    onLoginTap: () => ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('로그인은 발표 데모에서는 예약 확인 흐름으로 대체했습니다.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF534344),
                        ),
                      ),
                    onCartTap: () => _showCartSheet(context),
                  ),
                  const _BrandSection(),
                  _MenuPreviewSection(
                    onMoreTap: () =>
                        Navigator.pushReplacementNamed(context, '/menu'),
                  ),
                  _ExperienceSection(
                    onTasteTap: () =>
                        Navigator.pushReplacementNamed(context, '/ai'),
                    onClassTap: () =>
                        Navigator.pushReplacementNamed(context, '/experience'),
                    onCateringTap: () =>
                        Navigator.pushReplacementNamed(context, '/catering'),
                  ),
                  const AppFooter(),
                ],
              ),
            ),
          ),
          const FloatingHaenggungChatbot(),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFFFCF7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '장바구니 안내',
              style: TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '발표 데모에서는 메뉴를 담아 결제하기보다, 체험 예약과 케이터링 상담으로 이어지는 흐름을 보여줍니다.',
              style: TextStyle(
                color: Color(0xFF6F625B),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(context, '/catering');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF934753),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('케이터링 문의'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(context, '/experience');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF934753),
                  ),
                  child: const Text('체험 예약'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Section ───────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onMenuTap,
    required this.onExperienceTap,
    required this.onCateringTap,
    required this.onAiTap,
    required this.onLoginTap,
    required this.onCartTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onCateringTap;
  final VoidCallback onAiTap;
  final VoidCallback onLoginTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return SizedBox(
      height: isWide ? 945 : 780,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _imgProvider(_heroImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.16),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _HeroNav(
                onMenuTap: onMenuTap,
                onExperienceTap: onExperienceTap,
                onCateringTap: onCateringTap,
                onAiTap: onAiTap,
                onLoginTap: onLoginTap,
                onCartTap: onCartTap,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _HeroContent(isWide: isWide),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _HeroDot(active: true),
                SizedBox(width: 14),
                _HeroDot(active: false),
                SizedBox(width: 14),
                _HeroDot(active: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroNav extends StatelessWidget {
  const _HeroNav({
    required this.onMenuTap,
    required this.onExperienceTap,
    required this.onCateringTap,
    required this.onAiTap,
    required this.onLoginTap,
    required this.onCartTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onCateringTap;
  final VoidCallback onAiTap;
  final VoidCallback onLoginTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 1000;

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(left: 20, top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroLogoButton(
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _HeroNavBtn('소개', onTap: () {}),
                  _HeroNavBtn('메뉴', onTap: onMenuTap),
                  _HeroNavBtn('체험', onTap: onExperienceTap),
                  _HeroNavBtn('케이터링', onTap: onCateringTap),
                  _HeroNavBtn('나만의 다과 추천', onTap: onAiTap),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1200 ? width / 12 + 30 : 36.0;

    return SizedBox(
      height: 80,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            _HeroLogoButton(
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            const Spacer(),
            _HeroNavBtn('소개', onTap: () {}),
            _HeroNavBtn('메뉴', onTap: onMenuTap),
            _HeroNavBtn('체험', onTap: onExperienceTap),
            _HeroNavBtn('케이터링', onTap: onCateringTap),
            _HeroNavBtn('나만의 다과 추천', onTap: onAiTap),
            const Spacer(),
            _HeroNavBtn('로그인', onTap: onLoginTap),
            _HeroNavBtn('장바구니', onTap: onCartTap),
          ],
        ),
      ),
    );
  }
}

class _HeroLogoButton extends StatelessWidget {
  const _HeroLogoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const HaenggungBrandLogo(light: true, height: 43),
    );
  }
}

class _HeroNavBtn extends StatelessWidget {
  const _HeroNavBtn(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontFamilyFallback: _sansFallback,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          height: 1,
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width < 420 ? 20.0 : 36.0;

    return Padding(
      padding: EdgeInsets.only(
        top: isWide ? 198 : 142,
        left: padding,
        right: padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isWide ? 560 : double.infinity,
            child: Text(
              '화성행궁 곁,\n명인이 빚은 다과.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: isWide ? 50 : 40,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 38),
          SizedBox(
            width: isWide ? 495 : double.infinity,
            child: const Text(
              '장인의 손길로 빚어낸 행궁다과의 섬세한 맛과 멋을 경험해보세요. 한 점의 다과에 담긴 전통과 느린 삶의 이야기를 전합니다.',
              style: TextStyle(
                color: Color(0xFFF2F2ED),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 18,
                height: 1.55,
              ),
            ),
          ),
          SizedBox(height: isWide ? 64 : 34),
          _HeroInfoPanel(isWide: isWide),
        ],
      ),
    );
  }
}

class _HeroInfoPanel extends StatelessWidget {
  const _HeroInfoPanel({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? 549 : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFD9).withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _InfoRow(icon: Icons.place_outlined, label: '위치', value: '행궁로 25 2층'),
          SizedBox(height: 20),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: '운영',
            value: '월,수,목,금,일 10:00-21:00 / 토 10:00-22:00',
          ),
          SizedBox(height: 20),
          _InfoRow(
            icon: Icons.event_busy_outlined,
            label: '휴무',
            value: '매주 화요일 정기휴무',
          ),
          SizedBox(height: 20),
          _InfoRow(
            icon: Icons.info_outline_rounded,
            label: '문의',
            value: placePhone,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: const Color(0xFF534344), size: 23),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontFamilyFallback: _sansFallback,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontFamilyFallback: _sansFallback,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroDot extends StatelessWidget {
  const _HeroDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.38),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BotanicalDeco extends StatelessWidget {
  const _BotanicalDeco({
    required this.width,
    required this.height,
    this.opacity = 0.19,
    this.rotationDegrees = 0,
  });

  final double width;
  final double height;
  final double opacity;
  final double rotationDegrees;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotationDegrees * math.pi / 180,
          child: SizedBox(
            width: width,
            height: height,
            child: Image.asset(_botanicalDecoImage, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _BotanicalDecoWindow extends StatelessWidget {
  const _BotanicalDecoWindow({
    required this.width,
    required this.height,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageOffset,
    this.opacity = 0.19,
  });

  final double width;
  final double height;
  final double imageWidth;
  final double imageHeight;
  final Offset imageOffset;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: imageOffset.dx,
                top: imageOffset.dy,
                child: _BotanicalDeco(
                  width: imageWidth,
                  height: imageHeight,
                  opacity: opacity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Brand Section ───────────────────────────────────────────────────────────

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final padding = MediaQuery.sizeOf(context).width < 420 ? 20.0 : 36.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF3EEEE),
      padding: const EdgeInsets.symmetric(vertical: 82),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: isWide ? -560 : -430,
            bottom: isWide ? -355 : -210,
            child: _BotanicalDeco(
              width: isWide ? 1101 : 760,
              height: isWide ? 688 : 475,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1142),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    const _SectionTitle(
                      eyebrow: 'BRAND',
                      eyebrowColor: Color(0xFFE06B7E),
                      title: '한국 다과의 서정을 담은 브랜드',
                      description:
                          '행궁다과는 화성행궁의 정취와 한국 다과의 정서를 담은 브랜드입니다.\n전통 다과를 현대적으로 재해석하여 정갈한 맛과 계절의 이야기를 전하며, 바쁜 일상 속 잠시 머물러 쉬어갈 수 있는 여유로운 시간을 선물합니다.',
                    ),
                    const SizedBox(height: 72),
                    if (isWide)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final col = (constraints.maxWidth - 30) / 2;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: col,
                                child: const _CaptionedImage(
                                  asset: _brandWindowImage,
                                  caption: '화성행궁 산책길의 찻집',
                                  aspectRatio: 559 / 498,
                                ),
                              ),
                              const SizedBox(width: 30),
                              SizedBox(
                                width: col,
                                child: const Column(
                                  children: [
                                    _CaptionedImage(
                                      asset: _brandTrayImage,
                                      caption: '떡과 다과를 정갈하게',
                                      aspectRatio: 559 / 234,
                                    ),
                                    SizedBox(height: 30),
                                    _CaptionedImage(
                                      asset: _brandTableImage,
                                      caption: '계절 메뉴와 작은 경험들',
                                      aspectRatio: 559 / 234,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    else
                      const Column(
                        children: [
                          _CaptionedImage(
                            asset: _brandWindowImage,
                            caption: '화성행궁 산책길의 찻집',
                            aspectRatio: 559 / 498,
                          ),
                          SizedBox(height: 20),
                          _CaptionedImage(
                            asset: _brandTrayImage,
                            caption: '떡과 다과를 정갈하게',
                            aspectRatio: 559 / 234,
                          ),
                          SizedBox(height: 20),
                          _CaptionedImage(
                            asset: _brandTableImage,
                            caption: '계절 메뉴와 작은 경험들',
                            aspectRatio: 559 / 234,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionedImage extends StatelessWidget {
  const _CaptionedImage({
    required this.asset,
    required this.caption,
    required this.aspectRatio,
  });
  final String asset;
  final String caption;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Positioned.fill(child: _img(asset)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF462B30).withValues(alpha: 0.54),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 20,
              right: 24,
              child: Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Preview Section ────────────────────────────────────────────────────

class _MenuPreviewSection extends StatelessWidget {
  const _MenuPreviewSection({required this.onMoreTap});
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    final padding = MediaQuery.sizeOf(context).width < 420 ? 20.0 : 36.0;

    const cards = [
      _MenuCard(
        title: '다과상 A',
        price: '7,000 원',
        asset: _menuDagwasangImage,
        background: Color(0xFFEEE2E2),
        border: Color(0xFFE8B3B3),
      ),
      _MenuCard(
        title: '녹차빙수',
        price: '15,000 원',
        asset: _menuBingsuImage,
        background: Color(0xFFE7EBE3),
        border: Color(0xFF88A77E),
      ),
      _MenuCard(
        title: '행궁약과',
        price: '2,500 원',
        asset: _menuYakgwaImage,
        background: Color(0xFFEFE7CF),
        border: Color(0xFFAF915E),
      ),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFF6F6F4),
      padding: const EdgeInsets.symmetric(vertical: 82),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isWide)
            const Positioned(
              right: -560,
              top: -331,
              child: _BotanicalDeco(width: 1101, height: 688, opacity: 0.16),
            ),
          Positioned(
            left: isWide ? -24 : -78,
            bottom: isWide ? 16 : -8,
            child: _BotanicalDecoWindow(
              width: isWide ? 430 : 300,
              height: isWide ? 430 : 350,
              imageWidth: isWide ? 790 : 650,
              imageHeight: isWide ? 614 : 505,
              imageOffset: Offset(isWide ? -445 : -365, isWide ? -145 : -112),
              opacity: 0.17,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1142),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    const _SectionTitle(
                      eyebrow: 'MENU',
                      eyebrowColor: Color(0xFF99C679),
                      title: '행궁다과의 대표 메뉴',
                      description:
                          '행궁다과의 대표 메뉴는 약과, 정과, 다식 등 한국 전통 다과를 중심으로 구성됩니다.\n계절의 재료와 차를 곁들여 정갈하게 준비한 한 상은 바쁜 일상 속 잠시 쉬어갈 수 있는 여유를 선물합니다.',
                    ),
                    const SizedBox(height: 70),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            Expanded(
                              child: _MenuPreviewCard(
                                data: cards[i],
                                onTap: onMoreTap,
                              ),
                            ),
                            if (i != cards.length - 1)
                              const SizedBox(width: 36),
                          ],
                        ],
                      )
                    else
                      Column(
                        children: [
                          for (final card in cards) ...[
                            _MenuPreviewCard(data: card, onTap: onMoreTap),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: isWide
                          ? Alignment.centerRight
                          : Alignment.center,
                      child: FilledButton(
                        onPressed: onMoreTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF934753),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          '메뉴 자세히 보러가기',
                          style: TextStyle(
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard {
  const _MenuCard({
    required this.title,
    required this.price,
    required this.asset,
    required this.background,
    required this.border,
  });
  final String title;
  final String price;
  final String asset;
  final Color background;
  final Color border;
}

class _MenuPreviewCard extends StatelessWidget {
  const _MenuPreviewCard({required this.data, required this.onTap});
  final _MenuCard data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 356),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          decoration: BoxDecoration(
            color: data.background,
            border: Border.all(color: data.border),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F2D2D).withValues(alpha: 0.25),
                blurRadius: 19.1,
                spreadRadius: -1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: AspectRatio(
                  aspectRatio: 327 / 423,
                  child: _img(data.asset),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF706761),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    data.price,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF706761),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Experience Section ──────────────────────────────────────────────────────

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection({
    required this.onTasteTap,
    required this.onClassTap,
    required this.onCateringTap,
  });

  final VoidCallback onTasteTap;
  final VoidCallback onClassTap;
  final VoidCallback onCateringTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;
    final padding = MediaQuery.sizeOf(context).width < 420 ? 20.0 : 36.0;

    final cards = [
      _ExpCard(
        title: '취향 테스트',
        body: '개인의 취향을 분석해 어울리는 다과와 차를 추천합니다.',
        action: '시작하기',
        icon: Icons.account_tree_outlined,
        iconOverlay: Icons.edit_rounded,
        iconColor: const Color(0xFF9B4A59),
        tint: const Color(0xFFFFDCE0),
        onTap: onTasteTap,
      ),
      _ExpCard(
        title: '다과 클래스',
        body: '직접 빚고 맛보며 한국 다과의 이야기를 배워봅니다.',
        action: '예약하기',
        icon: Icons.school_outlined,
        iconColor: const Color(0xFF557057),
        tint: const Color(0xFFDCE9C1),
        onTap: onClassTap,
      ),
      _ExpCard(
        title: '맞춤형 케이터링',
        body: '행사 성격과 인원에 맞춘 다과 세트를 구성합니다.',
        action: '문의하기',
        icon: Icons.restaurant_rounded,
        iconColor: const Color(0xFF7D5724),
        tint: const Color(0xFFFFDEA7),
        onTap: onCateringTap,
      ),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8F6F1),
      padding: const EdgeInsets.symmetric(vertical: 88),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: isWide ? -170 : -360,
            bottom: isWide ? 0 : -40,
            child: _BotanicalDeco(
              width: isWide ? 724 : 640,
              height: isWide ? 487 : 430,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1142),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    const _SectionTitle(
                      eyebrow: 'Special Experiences',
                      eyebrowColor: Color(0xFFA38650),
                      title: '행궁다과의 특별한 경험',
                      description:
                          '한 조각의 다과에는 계절의 풍경과 만드는 이의 정성이 담겨 있습니다.\n행궁다과는 취향을 발견하고, 직접 만들고, 함께 나누는 경험을 통해 다과가 가진 이야기를 전합니다.\n맛을 넘어 추억으로 남는 순간을 만나보세요.',
                    ),
                    const SizedBox(height: 68),
                    if (isWide)
                      Row(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            Expanded(child: _ExpCardWidget(data: cards[i])),
                            if (i != cards.length - 1)
                              const SizedBox(width: 30),
                          ],
                        ],
                      )
                    else
                      Column(
                        children: [
                          for (final card in cards) ...[
                            _ExpCardWidget(data: card),
                            const SizedBox(height: 18),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpCard {
  const _ExpCard({
    required this.title,
    required this.body,
    required this.action,
    required this.icon,
    this.iconOverlay,
    required this.iconColor,
    required this.tint,
    required this.onTap,
  });
  final String title;
  final String body;
  final String action;
  final IconData icon;
  final IconData? iconOverlay;
  final Color iconColor;
  final Color tint;
  final VoidCallback onTap;
}

class _ExpCardWidget extends StatelessWidget {
  const _ExpCardWidget({required this.data});
  final _ExpCard data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 363),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -44,
                top: -116,
                child: _BotanicalDeco(
                  width: 276,
                  height: 271,
                  opacity: 0.43,
                  rotationDegrees: 20.92,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ExperienceCardIcon(data: data),
                    const SizedBox(height: 24),
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Color(0xFF1C1C18),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 24,
                        height: 1.32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.body,
                      style: const TextStyle(
                        color: Color(0xFF534344),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.action,
                          style: const TextStyle(
                            color: Color(0xFF934753),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF934753),
                          size: 14,
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
    );
  }
}

class _ExperienceCardIcon extends StatelessWidget {
  const _ExperienceCardIcon({required this.data});

  final _ExpCard data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: data.tint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(data.icon, color: data.iconColor, size: 28),
          if (data.iconOverlay != null)
            Positioned(
              right: 11,
              bottom: 10,
              child: Icon(data.iconOverlay, color: data.iconColor, size: 17),
            ),
        ],
      ),
    );
  }
}

// ─── Shared Section Title ────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.eyebrow,
    required this.eyebrowColor,
    required this.title,
    required this.description,
  });
  final String eyebrow;
  final Color eyebrowColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: isWide ? 26.0 : 12.0,
          runSpacing: 6,
          children: [
            Container(
              width: isWide ? 76.5 : 42,
              height: 1,
              color: eyebrowColor,
            ),
            Text(
              eyebrow,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: eyebrowColor,
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: isWide ? 25.0 : 16.0,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF534344),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: isWide ? 50 : 34,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 981),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF9A9285),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: isWide ? 20.0 : 16.0,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
