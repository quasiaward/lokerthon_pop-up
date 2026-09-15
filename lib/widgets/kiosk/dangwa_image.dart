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
            color: Color.lerp(tone.soft, AppColors.ground, 0.65),
            borderRadius: BorderRadius.circular(Radii.asset),
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
