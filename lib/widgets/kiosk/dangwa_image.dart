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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xEFFFFFFF), Color(0xBFFFFFFF)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
            boxShadow: [
              BoxShadow(
                color: tone.deep.withValues(alpha: 0.14),
                blurRadius: 52,
                spreadRadius: -4,
                offset: const Offset(0, 24),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.56),
                blurRadius: 2,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                width: constraints.maxWidth * 0.78,
                height: constraints.maxWidth * 0.78,
                right: -constraints.maxWidth * 0.18,
                top: -constraints.maxWidth * 0.24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        tone.soft.withValues(alpha: 0.82),
                        tone.soft.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 28,
                right: 28,
                top: 0,
                child: Container(
                  height: 1.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white,
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(constraints.maxWidth * padding),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
