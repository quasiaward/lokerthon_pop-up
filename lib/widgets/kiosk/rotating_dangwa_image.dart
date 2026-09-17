import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/dagwa_results.dart';
import '../../data/dangwa_catalog.dart';
import '../../data/dagwa_tones.dart';
import '../../theme/app_colors.dart';
import 'dangwa_image.dart';

/// 여러 다과 이미지를 느린 크로스페이드로 보여 주는 히어로 이미지.
///
/// 현재 추천 가능한 다과만 순환하며, 이미지는 [KioskPage]가 미리 디코드해
/// 두었기 때문에 교체 순간에도 프레임이 끊기지 않는다.
///
/// [interval]은 화면마다 따로 지정하지 않는다. 시작 화면과 그다음 화면이 서로
/// 다른 주기로 돌면 넘어갈 때 사진이 어긋난 박자로 바뀌어 거슬린다.
class RotatingDangwaImage extends StatefulWidget {
  const RotatingDangwaImage({
    super.key,
    this.initialIndex = 0,
    this.interval = const Duration(seconds: 3),
    this.aspectRatio = 1,
    this.padding = 0.12,
    this.menus = activeDagwaMenus,
  });

  final int initialIndex;
  final Duration interval;
  final double aspectRatio;
  final double padding;
  final List<String> menus;

  @override
  State<RotatingDangwaImage> createState() => _RotatingDangwaImageState();
}

class _RotatingDangwaImageState extends State<RotatingDangwaImage> {
  late int _index = widget.initialIndex % widget.menus.length;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTimer();
  }

  @override
  void didUpdateWidget(covariant RotatingDangwaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval ||
        !listEquals(oldWidget.menus, widget.menus)) {
      _index %= widget.menus.length;
      _updateTimer();
    }
  }

  void _updateTimer() {
    _timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.menus.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuName = widget.menus[_index];
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
