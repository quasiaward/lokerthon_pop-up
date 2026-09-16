import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/dagwa_results.dart';
import '../../data/dagwa_tones.dart';
import '../../services/recommendation_engine.dart';
import '../../theme/app_colors.dart';
import 'dangwa_image.dart';

/// 여러 다과 이미지를 느린 크로스페이드로 보여 주는 히어로 이미지.
///
/// 추천에 쓰이는 12개 다과만 순환하며, 이미지는 [KioskPage]가 미리 디코드해
/// 두었기 때문에 교체 순간에도 프레임이 끊기지 않는다.
class RotatingDangwaImage extends StatefulWidget {
  const RotatingDangwaImage({
    super.key,
    this.initialIndex = 0,
    this.interval = const Duration(milliseconds: 4600),
    this.aspectRatio = 1,
    this.padding = 0.12,
  });

  final int initialIndex;
  final Duration interval;
  final double aspectRatio;
  final double padding;

  @override
  State<RotatingDangwaImage> createState() => _RotatingDangwaImageState();
}

class _RotatingDangwaImageState extends State<RotatingDangwaImage> {
  late int _index = widget.initialIndex % dagwaMenus.length;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTimer();
  }

  @override
  void didUpdateWidget(covariant RotatingDangwaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval) _updateTimer();
  }

  void _updateTimer() {
    _timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % dagwaMenus.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuName = dagwaMenus[_index];
    final result = dagwaResults[menuName]!;
    final reduced = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : Motion.reveal,
      reverseDuration: reduced ? Duration.zero : Motion.slow,
      switchInCurve: Motion.emphasized,
      switchOutCurve: Motion.exitCurve,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.center,
        children: [...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) {
        final eased = CurvedAnimation(
          parent: animation,
          curve: Motion.emphasized,
          reverseCurve: Motion.exitCurve,
        );
        return FadeTransition(
          opacity: eased,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.975, end: 1).animate(eased),
            child: child,
          ),
        );
      },
      child: DangwaImage(
        key: ValueKey(menuName),
        assetPath: result.imagePath,
        tone: toneFor(menuName),
        aspectRatio: widget.aspectRatio,
        padding: widget.padding,
      ),
    );
  }
}
