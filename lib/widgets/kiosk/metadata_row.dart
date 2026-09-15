import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// 부가 정보. 각 항목을 카드에 넣지 않고 editorial 텍스트 조판으로 둔다.
class MetadataRow extends StatelessWidget {
  const MetadataRow({super.key, required this.items, required this.tone});

  final List<({String label, String value, bool latin})> items;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Space.x3,
      runSpacing: Space.lg,
      children: [
        for (final m in items)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                m.label,
                style: Type.eyebrow(tone, latin: m.latin, size: 13),
              ),
              const SizedBox(height: 6),
              Text(
                m.value,
                style: Type.body.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
