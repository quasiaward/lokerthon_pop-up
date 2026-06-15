import 'dart:async';

import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../l10n/lang.dart';
import '../utils/url_opener.dart';
import '../widgets/brand_logo.dart';
import '../widgets/floating_chatbot.dart';
import '../widgets/footer.dart';
import '../widgets/lang_toggle.dart';
import '../widgets/watercolor_deco.dart';

// ─── 히어로 캐러셀 슬라이드 (Figma '최종' 디자인의 3장) ────────────────────
// Figma '최종' 디자인을 assets/figma/ 로 export 한 로컬 에셋(영구 적용).
const _heroSlides = <String>[
  'assets/figma/home_hero_1.png',
  'assets/figma/home_hero_2.png',
  'assets/figma/home_hero_3.png',
];

// ─── BRAND 섹션 소셜 카드 이미지 (로컬 에셋) ──────────────────────────────
const _brandInstagramImage = 'assets/figma/brand_instagram.png';
const _brandYoutubeImage = 'assets/figma/brand_youtube.png';
const _brandBlogImage = 'assets/figma/brand_blog.png';

const _menuDagwasangImage = 'assets/figma/menu_dagwasang.png';
const _menuBingsuImage = 'assets/figma/menu_green_bingsu.png';
const _menuOmijaSudanImage = 'assets/figma/menu_omija_sudan.png';

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

Widget _img(String asset, {BoxFit fit = BoxFit.cover}) =>
    Image.asset(asset, fit: fit);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F5),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _HeroSection(
                    onHomeTap: _scrollToTop,
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
                        SnackBar(
                          content: Text(tr(
                              '로그인은 발표 데모에서는 예약 확인 흐름으로 대체했습니다.',
                              'In this demo, login is replaced by the reservation lookup flow.')),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF534344),
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
            Text(
              tr('장바구니 안내', 'About the cart'),
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr('발표 데모에서는 메뉴를 담아 결제하기보다, 체험 예약과 케이터링 상담으로 이어지는 흐름을 보여줍니다.',
                  'In this demo, instead of checkout the cart leads into the experience booking and catering inquiry flows.'),
              style: const TextStyle(
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
                  child: Text(tr('케이터링 문의', 'Catering inquiry')),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(context, '/experience');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF934753),
                  ),
                  child: Text(tr('체험 예약', 'Book experience')),
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

class _HeroSection extends StatefulWidget {
  const _HeroSection({
    required this.onHomeTap,
    required this.onMenuTap,
    required this.onExperienceTap,
    required this.onCateringTap,
    required this.onAiTap,
    required this.onLoginTap,
    required this.onCartTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onMenuTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onCateringTap;
  final VoidCallback onAiTap;
  final VoidCallback onLoginTap;
  final VoidCallback onCartTap;

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (_heroSlides.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % _heroSlides.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goTo(int i) {
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return SizedBox(
      height: isWide ? 945 : 780,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: _HeroSlideImage(
                key: ValueKey<int>(_index),
                url: _heroSlides[_index],
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
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.22),
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
                onHomeTap: widget.onHomeTap,
                onMenuTap: widget.onMenuTap,
                onExperienceTap: widget.onExperienceTap,
                onCateringTap: widget.onCateringTap,
                onAiTap: widget.onAiTap,
                onLoginTap: widget.onLoginTap,
                onCartTap: widget.onCartTap,
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
              children: [
                for (var i = 0; i < _heroSlides.length; i++) ...[
                  if (i != 0) const SizedBox(width: 14),
                  _HeroDot(active: i == _index, onTap: () => _goTo(i)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 히어로 배경 슬라이드 한 장. Figma '최종' 디자인을 로컬 에셋으로 로드하고,
/// 실패 시에는 브랜드 톤의 단색으로 자연스럽게 대체한다.
class _HeroSlideImage extends StatelessWidget {
  const _HeroSlideImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stack) =>
          const ColoredBox(color: Color(0xFF4A3A33)),
    );
  }
}

class _HeroNav extends StatelessWidget {
  const _HeroNav({
    required this.onHomeTap,
    required this.onMenuTap,
    required this.onExperienceTap,
    required this.onCateringTap,
    required this.onAiTap,
    required this.onLoginTap,
    required this.onCartTap,
  });

  final VoidCallback onHomeTap;
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
                  _HeroNavBtn(tr('홈', 'Home'), onTap: onHomeTap, active: true),
                  _HeroNavBtn(tr('메뉴', 'Menu'), onTap: onMenuTap),
                  _HeroNavBtn(tr('원데이 클래스', 'One-day Class'),
                      onTap: onExperienceTap),
                  _HeroNavBtn(tr('퍼스널 다과 추천', 'Personal Picks'),
                      onTap: onAiTap),
                  _HeroNavBtn(tr('다과 상자 주문', 'Gift Box Order'),
                      onTap: onCateringTap),
                  _HeroNavBtn(tr('주문 / 예약확인', 'Order / Booking'),
                      onTap: onLoginTap),
                  const SizedBox(width: 4),
                  const LangToggle(light: true),
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
            _HeroNavBtn(tr('홈', 'Home'), onTap: onHomeTap, active: true),
            _HeroNavBtn(tr('메뉴', 'Menu'), onTap: onMenuTap),
            _HeroNavBtn(tr('원데이 클래스', 'One-day Class'),
                onTap: onExperienceTap),
            _HeroNavBtn(tr('퍼스널 다과 추천', 'Personal Picks'), onTap: onAiTap),
            _HeroNavBtn(tr('다과 상자 주문', 'Gift Box Order'),
                onTap: onCateringTap),
            const Spacer(),
            _HeroNavBtn(tr('주문 / 예약확인', 'Order / Booking'),
                onTap: onLoginTap),
            IconButton(
              onPressed: onCartTap,
              icon: const Icon(Icons.shopping_bag_outlined),
              color: Colors.white,
              tooltip: tr('장바구니', 'Cart'),
            ),
            const SizedBox(width: 6),
            const LangToggle(light: true),
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
  const _HeroNavBtn(this.label, {required this.onTap, this.active = false});

  final String label;
  final VoidCallback onTap;
  final bool active;

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
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          height: 1,
          decoration: active ? TextDecoration.underline : TextDecoration.none,
          decorationColor: Colors.white,
          decorationThickness: 2,
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
              tr('화성행궁 곁,\n명인이 빚은 다과.',
                  'Beside Hwaseong Palace,\ndagwa shaped by master hands.'),
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
            child: Text(
              tr('장인의 손길로 빚어낸 행궁다과의 섬세한 맛과 멋을 경험해보세요. 한 점의 다과에 담긴 전통과 느린 삶의 이야기를 전합니다.',
                  'Experience the delicate taste and beauty of Haenggung Dagwa, crafted by artisan hands. Each piece carries a story of tradition and an unhurried life.'),
              style: const TextStyle(
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
        children: [
          _InfoRow(
            icon: Icons.place_outlined,
            label: tr('위치', 'Location'),
            value: tr('행궁로 25 2층', '25 Haenggung-ro, 2F'),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: tr('운영', 'Hours'),
            value: tr('월,수,목,금,일 10:00-21:00 / 토 10:00-22:00',
                'Mon, Wed, Thu, Fri, Sun 10:00-21:00 / Sat 10:00-22:00'),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.event_busy_outlined,
            label: tr('휴무', 'Closed'),
            value: tr('매주 화요일 정기휴무', 'Closed every Tuesday'),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.info_outline_rounded,
            label: tr('문의', 'Contact'),
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
  const _HeroDot({required this.active, this.onTap});
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.38),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Brand Section ───────────────────────────────────────────────────────────

class _BrandSection extends StatelessWidget {
  const _BrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final padding = MediaQuery.sizeOf(context).width < 420 ? 20.0 : 36.0;
    final deco = decoScaleOf(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF6EFEF),
      padding: const EdgeInsets.symmetric(vertical: 82),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 0,
            bottom: -10 * deco,
            child: WatercolorDeco(decoBlossomPink, width: 542 * deco),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1142),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    _SectionTitle(
                      eyebrow: 'BRAND',
                      eyebrowColor: const Color(0xFFE06B7E),
                      title: tr('한국 다과의 서정을 담은 브랜드',
                          'A brand that captures the poetry of Korean dagwa'),
                      description: tr(
                          '행궁다과는 화성행궁의 정취와 한국 다과의 정서를 담은 브랜드입니다.\n전통 다과를 현대적으로 재해석하여 정갈한 맛과 계절의 이야기를 전하며, 바쁜 일상 속 잠시 머물러 쉬어갈 수 있는 여유로운 시간을 선물합니다.',
                          'Haenggung Dagwa is a brand inspired by the mood of Hwaseong Palace and the spirit of Korean dagwa.\nReinterpreting traditional sweets for today, it offers refined flavors and seasonal stories — a moment of calm to pause within a busy day.'),
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
                                child: _SocialCard(
                                  image: _brandInstagramImage,
                                  caption: tr('인스타그램 바로가기 →',
                                      'Go to Instagram →'),
                                  url: placeInstagramUrl,
                                  aspectRatio: 559 / 498,
                                ),
                              ),
                              const SizedBox(width: 30),
                              SizedBox(
                                width: col,
                                child: Column(
                                  children: [
                                    _SocialCard(
                                      image: _brandYoutubeImage,
                                      caption: tr('유튜브 바로가기 →',
                                          'Go to YouTube →'),
                                      url: placeYoutubeUrl,
                                      aspectRatio: 559 / 234,
                                    ),
                                    const SizedBox(height: 30),
                                    _SocialCard(
                                      image: _brandBlogImage,
                                      caption: tr('블로그 바로가기 →',
                                          'Go to Blog →'),
                                      url: placeBlogUrl,
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
                      Column(
                        children: [
                          _SocialCard(
                            image: _brandInstagramImage,
                            caption:
                                tr('인스타그램 바로가기 →', 'Go to Instagram →'),
                            url: placeInstagramUrl,
                            aspectRatio: 559 / 498,
                          ),
                          const SizedBox(height: 20),
                          _SocialCard(
                            image: _brandYoutubeImage,
                            caption: tr('유튜브 바로가기 →', 'Go to YouTube →'),
                            url: placeYoutubeUrl,
                            aspectRatio: 559 / 234,
                          ),
                          const SizedBox(height: 20),
                          _SocialCard(
                            image: _brandBlogImage,
                            caption: tr('블로그 바로가기 →', 'Go to Blog →'),
                            url: placeBlogUrl,
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

/// BRAND 섹션의 소셜(인스타/유튜브/블로그) 바로가기 카드.
/// 이미지는 로컬 에셋(assets/figma/)을 사용하며, 탭하면 [url]을 새 탭으로 연다.
/// [url]이 비어 있으면(링크 미정) 안내 스낵바를 띄운다.
class _SocialCard extends StatelessWidget {
  const _SocialCard({
    required this.image,
    required this.caption,
    required this.url,
    required this.aspectRatio,
  });
  final String image;
  final String caption;
  final String url;
  final double aspectRatio;

  void _handleTap(BuildContext context) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(tr('링크가 곧 연결될 예정입니다.',
                'This link will be connected soon.')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF534344),
          ),
        );
      return;
    }
    openExternalUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        const ColoredBox(color: Color(0xFF8C6B6B)),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF462B30).withValues(alpha: 0.62),
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
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

// ─── Menu Preview Section ────────────────────────────────────────────────────

class _MenuPreviewSection extends StatelessWidget {
  const _MenuPreviewSection({required this.onMoreTap});
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    final padding = MediaQuery.sizeOf(context).width < 420 ? 20.0 : 36.0;

    final cards = [
      _MenuCard(
        title: tr('다과상 A', 'Dagwa Set A'),
        price: tr('7,000 원', '7,000 KRW'),
        asset: _menuDagwasangImage,
        background: const Color(0xFFEEE2E2),
        border: const Color(0xFFE8B3B3),
      ),
      _MenuCard(
        title: tr('녹차빙수', 'Green Tea Bingsu'),
        price: tr('15,000 원', '15,000 KRW'),
        asset: _menuBingsuImage,
        background: const Color(0xFFE7EBE3),
        border: const Color(0xFF88A77E),
      ),
      _MenuCard(
        title: tr('오미자 수단', 'Omija Sudan'),
        price: tr('6,500 원', '6,500 KRW'),
        asset: _menuOmijaSudanImage,
        background: const Color(0xFFEFE7CF),
        border: const Color(0xFFAF915E),
      ),
    ];

    final deco = decoScaleOf(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF6F6F6),
      padding: const EdgeInsets.symmetric(vertical: 82),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: WatercolorDeco(decoBlossomYellow, width: 463 * deco),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1142),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    _SectionTitle(
                      eyebrow: 'MENU',
                      eyebrowColor: const Color(0xFF99C679),
                      title: tr('행궁다과 대표 메뉴', 'Signature menu of Haenggung Dagwa'),
                      description: tr(
                          '행궁다과의 대표 메뉴는 약과, 정과, 다식 등 한국 전통 다과를 중심으로 구성됩니다.\n계절의 재료와 차를 곁들여 정갈하게 준비한 한 상은 바쁜 일상 속 잠시 쉬어갈 수 있는 여유를 선물합니다.',
                          'Our signature menu centers on Korean traditional sweets such as yakgwa, jeonggwa, and dasik.\nElegantly prepared with seasonal ingredients and tea, each setting offers a restful pause within a busy day.'),
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
                        child: Text(
                          tr('메뉴 자세히 보러가기', 'View full menu'),
                          style: const TextStyle(
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
        title: tr('나만의 다과 추천', 'Personal Dagwa Picks'),
        body: tr('취향에 맞는 다과를 탐색해보세요',
            'Discover the dagwa that suits your taste.'),
        action: tr('테스트 바로가기', 'Take the test'),
        icon: Icons.account_tree_outlined,
        iconOverlay: Icons.edit_rounded,
        iconColor: const Color(0xFF9B4A59),
        tint: const Color(0xFFFFD9DC),
        cornerAsset: decoCardPink,
        onTap: onTasteTap,
      ),
      _ExpCard(
        title: tr('원데이 클래스', 'One-day Class'),
        body: tr('명인과 함께하는 힐링타임',
            'A healing time together with the master.'),
        action: tr('예약하기', 'Book'),
        icon: Icons.school_outlined,
        iconColor: const Color(0xFF557057),
        tint: const Color(0xFFDCE9C1),
        cornerAsset: decoCardGreen,
        onTap: onClassTap,
      ),
      _ExpCard(
        title: tr('커스텀 다과상자', 'Custom Dagwa Box'),
        body: tr('취향대로 구성하는 나만의 다과상자',
            'Compose your own dagwa box, just the way you like.'),
        action: tr('주문하기', 'Order'),
        icon: Icons.card_giftcard_rounded,
        iconColor: const Color(0xFF7D5724),
        tint: const Color(0xFFFFDEA7),
        cornerAsset: decoCardYellow,
        onTap: onCateringTap,
      ),
    ];

    final deco = decoScaleOf(context);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF6F4F0),
      padding: const EdgeInsets.symmetric(vertical: 88),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: WatercolorDeco(decoClusterSoft, width: 535 * deco),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1142),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  children: [
                    _SectionTitle(
                      eyebrow: 'Special Experiences',
                      eyebrowColor: const Color(0xFFA38650),
                      title: tr('행궁다과만의 특별한 경험',
                          'Special experiences at Haenggung Dagwa'),
                      description: tr(
                          '한 조각의 다과에는 계절의 풍경과 만드는 이의 정성이 담겨 있습니다.\n행궁다과는 취향을 발견하고, 직접 만들고, 함께 나누는 경험을 통해 다과가 가진 이야기를 전합니다.\n맛을 넘어 추억으로 남는 순간을 만나보세요.',
                          'Each piece of dagwa holds a season\'s scenery and the maker\'s care.\nThrough discovering your taste, making by hand, and sharing together, Haenggung Dagwa tells the story within each sweet.\nMeet moments that linger as memories, beyond taste.'),
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
    required this.cornerAsset,
    required this.onTap,
  });
  final String title;
  final String body;
  final String action;
  final IconData icon;
  final IconData? iconOverlay;
  final Color iconColor;
  final Color tint;
  final String cornerAsset;
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
                right: 0,
                top: 0,
                child: WatercolorDeco(data.cornerAsset, width: 223),
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
      child: Center(
        child: data.iconOverlay != null
            ? CustomPaint(
                size: const Size(30, 30),
                painter: _TasteTestGlyphPainter(data.iconColor),
              )
            : Icon(data.icon, color: data.iconColor, size: 29),
      ),
    );
  }
}

class _TasteTestGlyphPainter extends CustomPainter {
  const _TasteTestGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    final topLeft = Offset(size.width * 0.20, size.height * 0.22);
    final topMid = Offset(size.width * 0.53, size.height * 0.22);
    final lowerLeft = Offset(size.width * 0.20, size.height * 0.73);
    final lowerMid = Offset(size.width * 0.46, size.height * 0.58);

    canvas.drawLine(topLeft, topMid, stroke);
    canvas.drawLine(topLeft, lowerLeft, stroke);
    canvas.drawLine(lowerLeft, lowerMid, stroke);

    for (final node in [topLeft, topMid, lowerLeft]) {
      canvas.drawCircle(node, 2.3, fill);
      canvas.drawCircle(node, 4.7, stroke);
    }

    final pencilStart = Offset(size.width * 0.58, size.height * 0.82);
    final pencilEnd = Offset(size.width * 0.86, size.height * 0.49);
    canvas.drawLine(pencilStart, pencilEnd, stroke);
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.47),
      Offset(size.width * 0.89, size.height * 0.63),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TasteTestGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
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
