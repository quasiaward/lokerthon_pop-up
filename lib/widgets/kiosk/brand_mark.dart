import 'package:flutter/material.dart';

import '../../l10n/lang.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 132.0 : 208.0;
    final height = compact ? 58.0 : 91.0;

    return Semantics(
      image: true,
      label: tr('행궁다과', 'Haenggung Dagwa', 'ヘングン茶菓'),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          'assets/branding/brand_wordmark.png',
          fit: BoxFit.contain,
          cacheWidth: compact ? 264 : 416,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
