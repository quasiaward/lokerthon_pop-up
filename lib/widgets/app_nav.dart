import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import 'brand_logo.dart';
import 'lang_toggle.dart';

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

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1000;

    return Container(
      color: const Color(0xFFFFFEF8),
      child: SafeArea(
        bottom: false,
        child: compact
            ? _CompactNav(currentRoute: currentRoute)
            : _WideNav(currentRoute: currentRoute),
      ),
    );
  }
}

class _WideNav extends StatelessWidget {
  const _WideNav({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width >= 1200 ? width / 12 + 30 : 36.0;

    return SizedBox(
      height: 80,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            _LogoButton(),
            const Spacer(),
            _NavItem(tr('소개', 'About'), '/', currentRoute,
                onTap: () => _goHome(context)),
            _NavItem(
              tr('메뉴', 'Menu'),
              '/menu',
              currentRoute,
              onTap: () => _navigate(context, '/menu'),
            ),
            _NavItem(
              tr('체험', 'Experience'),
              '/experience',
              currentRoute,
              onTap: () => _navigate(context, '/experience'),
            ),
            _NavItem(
              tr('케이터링', 'Catering'),
              '/custom',
              currentRoute,
              onTap: () => _navigate(context, '/custom'),
            ),
            _NavItem(
              tr('나만의 다과 추천', 'Find Your Dagwa'),
              '/ai',
              currentRoute,
              onTap: () => _navigate(context, '/ai'),
            ),
            const Spacer(),
            _NavItem(
              tr('로그인', 'Log in'),
              '',
              currentRoute,
              onTap: () => _showDemoNotice(
                  context,
                  tr('로그인은 발표 데모에서는 예약 확인 흐름으로 대체했습니다.',
                      'In this demo, login is replaced by the reservation lookup flow.')),
            ),
            _NavItem(
              tr('장바구니', 'Cart'),
              '',
              currentRoute,
              onTap: () => _showCartSheet(context),
            ),
            const SizedBox(width: 8),
            const LangToggle(),
          ],
        ),
      ),
    );
  }
}

class _CompactNav extends StatelessWidget {
  const _CompactNav({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 10, right: 12),
          child: Row(
            children: [
              _LogoButton(),
              const Spacer(),
              const LangToggle(),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Row(
            children: [
              _NavItem(tr('소개', 'About'), '/', currentRoute,
                  onTap: () => _goHome(context)),
              _NavItem(
                tr('메뉴', 'Menu'),
                '/menu',
                currentRoute,
                onTap: () => _navigate(context, '/menu'),
              ),
              _NavItem(
                tr('체험', 'Experience'),
                '/experience',
                currentRoute,
                onTap: () => _navigate(context, '/experience'),
              ),
              _NavItem(
                tr('케이터링', 'Catering'),
                '/custom',
                currentRoute,
                onTap: () => _navigate(context, '/custom'),
              ),
              _NavItem(
                tr('나만의 다과 추천', 'Find Your Dagwa'),
                '/ai',
                currentRoute,
                onTap: () => _navigate(context, '/ai'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _navigate(BuildContext context, String route) {
  Navigator.pushReplacementNamed(context, route);
}

void _goHome(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/');
}

void _showDemoNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF534344),
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
    builder: (ctx) {
      return Padding(
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
                    Navigator.pushReplacementNamed(context, '/custom');
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
      );
    },
  );
}

class _LogoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, '/'),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const HaenggungBrandLogo(height: 42),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
    this.label,
    this.route,
    this.currentRoute, {
    required this.onTap,
  });

  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  bool get _isActive => route.isNotEmpty && currentRoute == route;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        minimumSize: const Size(0, 52),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: SizedBox(
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: _isActive
                        ? const Color(0xFF995959)
                        : route.isEmpty
                        ? Colors.black
                        : const Color(0xFF837777),
                    fontFamily: 'Inter',
                    fontFamilyFallback: _sansFallback,
                    fontSize: 17,
                    fontWeight: _isActive ? FontWeight.w500 : FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: _isActive ? label.length * 10.5 + 21 : 0,
              height: 2,
              color: const Color(0xFF995959),
            ),
          ],
        ),
      ),
    );
  }
}
