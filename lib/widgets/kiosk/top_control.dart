import 'package:flutter/material.dart';

import '../../l10n/lang.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// 상단 컨트롤 — 이전 / 처음으로.
/// 전역 내비게이션은 두지 않는다. 흐름을 방해하지 않을 만큼만 존재한다.
class TopControl extends StatelessWidget {
  const TopControl({super.key, this.onBack, this.onHome});

  final VoidCallback? onBack;
  final VoidCallback? onHome;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onBack != null)
          _Control(
            label: tr('이전', 'Back'),
            color: AppColors.muted,
            onTap: onBack!,
            leading: const Icon(
              Icons.chevron_left_rounded,
              size: 22,
              color: AppColors.muted,
            ),
          ),
        if (onBack != null && onHome != null) const SizedBox(width: Space.lg),
        if (onHome != null)
          _Control(
            label: tr('처음으로', 'Start over'),
            color: AppColors.faint,
            onTap: onHome!,
          ),
      ],
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.label,
    required this.color,
    required this.onTap,
    this.leading,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // 최소 터치 영역 48px을 확보하되 시각적으로는 텍스트만 보이게 한다.
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?leading,
            Text(
              label,
              style: Type.caption.copyWith(fontSize: 17, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
