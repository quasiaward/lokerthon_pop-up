import 'package:flutter/material.dart';

class HaenggungBrandLogo extends StatelessWidget {
  const HaenggungBrandLogo({super.key, this.light = false, this.height = 42});

  static const _assetPath =
      'assets/figma/logo/haenggung_logo_flutter_transparent.png';
  static const _lightAssetPath =
      'assets/figma/logo/haenggung_home_logo_light.png';
  static const _assetRatio = 1600 / 546;

  final bool light;
  final double height;

  @override
  Widget build(BuildContext context) {
    final assetPath = light ? _lightAssetPath : _assetPath;
    final innerHeight = height * 0.9;
    final horizontalSafety = height * 0.12;
    final logoWidth = innerHeight * _assetRatio + horizontalSafety * 2;

    return SizedBox(
      height: height,
      width: logoWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalSafety),
        child: Center(
          child: Image.asset(
            assetPath,
            height: innerHeight,
            width: innerHeight * _assetRatio,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
