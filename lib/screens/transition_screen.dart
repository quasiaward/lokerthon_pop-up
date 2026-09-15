import 'dart:async';

import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/brand_mark.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/glass_surface.dart';

class TransitionScreen extends StatefulWidget {
  const TransitionScreen({
    super.key,
    required this.menuName,
    required this.onDone,
  });

  final String menuName;
  final VoidCallback onDone;
  static const duration = Duration(milliseconds: 1600);

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _timer = Timer(TransitionScreen.duration, widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandMark(compact: true),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Transform.scale(
            scale: 0.985 + (_pulse.value * 0.025),
            child: child,
          ),
          child: GlassSurface(
            radius: 48,
            blurBackdrop: true,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SizedBox(
                width: 250,
                child: DangwaImage(
                  assetPath: dagwaResults[widget.menuName]!.imagePath,
                  tone: toneFor(widget.menuName),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 34),
        Text(
          tr(
            '당신의 취향을 담아\n다과를 고르고 있어요.',
            'Choosing a dagwa\nthat matches your taste.',
            'あなたの好みに合わせて\n茶菓を選んでいます。',
          ),
          textAlign: TextAlign.center,
          style: Type.section.copyWith(fontSize: 32, height: 1.42),
        ),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.gold],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    ),
  );
}
