import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 반투명 유리 표면.
///
/// 뒤의 ambient 색이 비쳐 깊이가 생긴다. 깊이를 그림자로 만들지 않기 위해
/// 위쪽 specular 하이라이트와 1px 테두리만으로 입체감을 표현한다.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = Radii.card,
    this.accented = false,
    this.strong = false,
    this.accentColor = AppColors.accent,
  });

  final Widget child;
  final double radius;

  /// 선택된 상태. accent 톤으로 바탕이 옮겨가고 테두리가 또렷해진다.
  final bool accented;

  /// 시트처럼 내용을 확실히 가려야 하는 표면.
  final bool strong;

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(radius);

    final gradient = accented
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentSoft.withValues(alpha: 0.78),
              accentColor.withValues(alpha: 0.10),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: strong
                ? [
                    const Color(0xFFFFFDF8).withValues(alpha: 0.92),
                    const Color(0xFFF7F1E7).withValues(alpha: 0.82),
                  ]
                : [
                    const Color(0xFFFFFDF8).withValues(alpha: 0.62),
                    const Color(0xFFFAF5EC).withValues(alpha: 0.38),
                  ],
          );

    return ClipRRect(
      borderRadius: border,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: strong ? 30 : 16,
          sigmaY: strong ? 30 : 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: border,
            border: Border.all(
              color: accented
                  ? accentColor.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.42),
              width: accented ? 1.4 : 1,
            ),
          ),
          child: Stack(
            children: [
              // 위쪽 모서리의 가는 하이라이트 — 유리 두께를 만든다.
              Positioned(
                left: radius * 0.6,
                right: radius * 0.6,
                top: 0,
                child: Container(
                  height: 1.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
