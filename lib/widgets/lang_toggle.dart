import 'package:flutter/material.dart';

import '../l10n/lang.dart';

/// KO / EN 언어 토글. [light] = true면 히어로 이미지 위(밝은 글자)용.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key, this.light = false});

  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Segment(label: 'KO', target: Lang.ko, light: light),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '/',
            style: TextStyle(
              color: (light ? Colors.white : const Color(0xFF8A8172))
                  .withValues(alpha: 0.5),
              fontFamily: 'Pretendard',
              fontSize: 15,
            ),
          ),
        ),
        _Segment(label: 'EN', target: Lang.en, light: light),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.target,
    required this.light,
  });

  final String label;
  final Lang target;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final active = appLang.value == target;
    final Color color;
    if (active) {
      color = light ? Colors.white : const Color(0xFF6D1F2B);
    } else {
      color = light
          ? Colors.white.withValues(alpha: 0.6)
          : const Color(0xFF8A8172);
    }

    return InkWell(
      onTap: () => appLang.value = target,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            height: 1,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
