import 'package:flutter/material.dart';

import '../../data/dagwa_tones.dart';
import '../../theme/app_colors.dart';

class DangwaImage extends StatelessWidget {
  const DangwaImage({
    super.key,
    required this.assetPath,
    required this.tone,
    this.aspectRatio = 1,
    this.padding = 0.12,
  });

  final String assetPath;
  final DagwaTone tone;
  final double aspectRatio;
  final double padding;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: LayoutBuilder(
      builder: (context, constraints) => RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.asset),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.76),
                Color.lerp(
                  tone.soft,
                  AppColors.champagneSoft,
                  0.35,
                )!.withValues(alpha: 0.66),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
            boxShadow: [
              BoxShadow(
                color: tone.deep.withValues(alpha: 0.13),
                blurRadius: 44,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          padding: EdgeInsets.all(constraints.maxWidth * padding),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    ),
  );
}
