import 'package:flutter/material.dart';

import '../l10n/lang.dart';
import 'brand_logo.dart';
import 'lang_toggle.dart';

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
            _NavItem(
              tr('홈', 'Home'),
              '/',
              currentRoute,
              onTap: () => _goHome(context),
            ),
            _NavItem(
              tr('메뉴', 'Menu'),
              '/menu',
              currentRoute,
              onTap: () => _navigate(context, '/menu'),
            ),
            _NavItem(
              tr('원데이 클래스', 'One-day Class'),
              '/experience',
              currentRoute,
              onTap: () => _navigate(context, '/experience'),
            ),
            _NavItem(
              tr('퍼스널 다과 추천', 'Personal Picks'),
              '/ai',
              currentRoute,
              onTap: () => _navigate(context, '/ai'),
            ),
            _NavItem(
              tr('다과 상자 주문', 'Gift Box Order'),
              '/custom',
              currentRoute,
              onTap: () => _navigate(context, '/custom'),
            ),
            const Spacer(),
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
            children: [_LogoButton(), const Spacer(), const LangToggle()],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Row(
            children: [
              _NavItem(
                tr('홈', 'Home'),
                '/',
                currentRoute,
                onTap: () => _goHome(context),
              ),
              _NavItem(
                tr('메뉴', 'Menu'),
                '/menu',
                currentRoute,
                onTap: () => _navigate(context, '/menu'),
              ),
              _NavItem(
                tr('원데이 클래스', 'One-day Class'),
                '/experience',
                currentRoute,
                onTap: () => _navigate(context, '/experience'),
              ),
              _NavItem(
                tr('퍼스널 다과 추천', 'Personal Picks'),
                '/ai',
                currentRoute,
                onTap: () => _navigate(context, '/ai'),
              ),
              _NavItem(
                tr('다과 상자 주문', 'Gift Box Order'),
                '/custom',
                currentRoute,
                onTap: () => _navigate(context, '/custom'),
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
