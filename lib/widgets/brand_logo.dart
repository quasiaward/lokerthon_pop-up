import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HaenggungBrandLogo extends StatelessWidget {
  const HaenggungBrandLogo({super.key, this.light = false, this.height = 42});

  final bool light;
  final double height;

  @override
  Widget build(BuildContext context) {
    final first = light
        ? 'assets/figma/logo/logo_part_haenggung.svg'
        : 'assets/figma/logo/logo_part_haenggung_dark.svg';
    final second = light
        ? 'assets/figma/logo/logo_part_dagwa.svg'
        : 'assets/figma/logo/logo_part_dagwa_dark.svg';

    return SizedBox(
      height: height,
      width: height * 4.28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(first, width: height * 1.92, height: height),
          SizedBox(width: height * 0.05),
          SvgPicture.asset(second, width: height * 2.18, height: height),
        ],
      ),
    );
  }
}
