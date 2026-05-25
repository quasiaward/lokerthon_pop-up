import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionShell extends StatelessWidget {
  const SectionShell({super.key, required this.child, this.maxWidth = 1180});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 420 ? 18.0 : 24.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.center = true,
    this.inverse = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final bool center;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final textAlign = center ? TextAlign.center : TextAlign.start;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            textAlign: textAlign,
            style: TextStyle(
              color: inverse ? AppColors.gold : AppColors.cinnabar,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: MediaQuery.sizeOf(context).width < 420 ? 2.6 : 4.0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: textAlign,
            style: TextStyle(
              color: inverse ? AppColors.paper : AppColors.deep,
              fontSize: _responsiveFont(context, 27, 40),
              height: 1.22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Serif KR',
              fontFamilyFallback: const ['AppleMyungjo', 'serif'],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: textAlign,
            style: TextStyle(
              color: inverse
                  ? AppColors.hanji.withValues(alpha: 0.85)
                  : AppColors.muted,
              fontSize: 16,
              height: 1.82,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  static double _responsiveFont(
    BuildContext context,
    double mobile,
    double desktop,
  ) {
    return MediaQuery.sizeOf(context).width >= 760 ? desktop : mobile;
  }
}

/// 부드러운 카드
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding, this.color});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: color ?? AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat.withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 22,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 부드러운 태그 (pill 형태)
class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.brown,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// React 스타일 코너 브래킷 장식 (히어로 전용)
class CornerBrackets extends StatelessWidget {
  const CornerBrackets({
    super.key,
    required this.child,
    this.size = 28,
    this.strokeWidth = 1.5,
    this.color = AppColors.gold,
    this.inset = 20,
  });

  final Widget child;
  final double size;
  final double strokeWidth;
  final Color color;
  final double inset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: inset,
          left: inset,
          child: _Bracket(
            size: size,
            strokeWidth: strokeWidth,
            color: color,
            corner: _Corner.topLeft,
          ),
        ),
        Positioned(
          top: inset,
          right: inset,
          child: _Bracket(
            size: size,
            strokeWidth: strokeWidth,
            color: color,
            corner: _Corner.topRight,
          ),
        ),
        Positioned(
          bottom: inset,
          left: inset,
          child: _Bracket(
            size: size,
            strokeWidth: strokeWidth,
            color: color,
            corner: _Corner.bottomLeft,
          ),
        ),
        Positioned(
          bottom: inset,
          right: inset,
          child: _Bracket(
            size: size,
            strokeWidth: strokeWidth,
            color: color,
            corner: _Corner.bottomRight,
          ),
        ),
      ],
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _Bracket extends StatelessWidget {
  const _Bracket({
    required this.size,
    required this.strokeWidth,
    required this.color,
    required this.corner,
  });

  final double size;
  final double strokeWidth;
  final Color color;
  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BracketPainter(
          strokeWidth: strokeWidth,
          color: color,
          corner: corner,
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({
    required this.strokeWidth,
    required this.color,
    required this.corner,
  });

  final double strokeWidth;
  final Color color;
  final _Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    switch (corner) {
      case _Corner.topLeft:
        canvas.drawLine(Offset(0, h), Offset(0, 0), paint);
        canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      case _Corner.topRight:
        canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
        canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      case _Corner.bottomLeft:
        canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
        canvas.drawLine(Offset(0, h), Offset(w, h), paint);
      case _Corner.bottomRight:
        canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
        canvas.drawLine(Offset(w, h), Offset(0, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BracketPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.corner != corner;
}

/// 페이드 업 애니메이션
class FadeInUp extends StatelessWidget {
  const FadeInUp({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final t = delay == Duration.zero
            ? value
            : ((value * (700 + delay.inMilliseconds) - delay.inMilliseconds) /
                      700)
                  .clamp(0.0, 1.0);

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 약과 메달리온
class YakgwaMedallion extends StatelessWidget {
  const YakgwaMedallion({super.key, this.size = 260});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            AppColors.gold,
            Color(0xFFE5CAA1),
            AppColors.gold,
            AppColors.cinnabar,
            AppColors.gold,
          ],
        ),
        border: Border.all(
          color: AppColors.paper.withValues(alpha: 0.7),
          width: 10,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deep.withValues(alpha: 0.14),
            blurRadius: 38,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.42,
          height: size * 0.42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brown.withValues(alpha: 0.7),
            border: Border.all(
              color: AppColors.paper.withValues(alpha: 0.55),
              width: 6,
            ),
          ),
          child: Center(
            child: Text(
              '藥',
              style: TextStyle(
                color: AppColors.paper,
                fontSize: size * 0.18,
                fontWeight: FontWeight.w800,
                fontFamily: 'AppleMyungjo',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
