import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false, this.light = false});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 54.0;
    final color = light ? AppColors.surface : AppColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.champagne.withValues(alpha: 0.75),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentDeep.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/branding/app_icon.png',
            fit: BoxFit.cover,
            cacheWidth: compact ? 84 : 108,
            excludeFromSemantics: true,
          ),
        ),
        SizedBox(width: compact ? 12 : 16),
        Text(
          // 브랜드명. 영어·일본어 화면에서는 읽을 수 있게 표기를 바꾼다.
          tr('행궁다과', 'Haenggung Dagwa', 'ヘングン茶菓'),
          style: Type.section.copyWith(
            fontSize: compact ? 24 : 29,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
