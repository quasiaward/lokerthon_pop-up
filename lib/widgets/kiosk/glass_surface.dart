import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// 행궁다과 색을 머금는 절제된 유리 표면.
/// 실제 blur는 주요 조작과 시트에만 사용하고 반복 카드에서는 끈다.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = Radii.card,
    this.accented = false,
    this.strong = false,
    this.accentColor = AppColors.accent,
    this.blurBackdrop = false,
  });

  final Widget child;
  final double radius;

  /// 선택된 상태. accent 톤으로 바탕이 옮겨가고 테두리가 또렷해진다.
  final bool accented;

  /// 시트처럼 내용을 확실히 가려야 하는 표면.
  final bool strong;

  final Color accentColor;

  /// 뒤 화면을 실제로 흐리게 할지. 비싸므로 꼭 필요한 곳에서만 켠다.
  final bool blurBackdrop;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(radius);

    final gradient = accented
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: strong ? 0.94 : 0.86),
              AppColors.accentDeep.withValues(alpha: strong ? 0.96 : 0.88),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              strong ? AppColors.glassStrong : AppColors.glass,
              AppColors.goldSoft.withValues(alpha: strong ? 0.46 : 0.24),
            ],
          );

    final surface = Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: border,
        border: Border.all(
          color: accented
              ? AppColors.gold.withValues(alpha: 0.54)
              : Colors.white.withValues(alpha: 0.72),
          width: accented ? 1.2 : 1,
        ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
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
                    Colors.white.withValues(alpha: accented ? 0.48 : 0.92),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDeep.withValues(alpha: strong ? 0.15 : 0.08),
            blurRadius: strong ? 34 : 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: border,
        child: blurBackdrop
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: strong ? 28 : 18,
                  sigmaY: strong ? 28 : 18,
                ),
                child: surface,
              )
            : surface,
      ),
    );
  }
}
