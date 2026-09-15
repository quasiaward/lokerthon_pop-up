import 'dart:async';
import 'package:flutter/material.dart';
import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';

class TransitionScreen extends StatefulWidget {
  const TransitionScreen({
    super.key,
    required this.menuName,
    required this.onDone,
  });
  final String menuName;
  final VoidCallback onDone;
  static const duration = Duration(milliseconds: 1400);
  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(TransitionScreen.duration, widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 260,
          child: DangwaImage(
            assetPath: dagwaResults[widget.menuName]!.imagePath,
            tone: toneFor(widget.menuName),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          tr(
            '당신의 취향을 담아\n다과를 고르고 있어요.',
            'Choosing a dagwa\nthat matches your taste.',
          ),
          textAlign: TextAlign.center,
          style: Type.section.copyWith(fontSize: 34, height: 1.4),
        ),
      ],
    ),
  );
}
