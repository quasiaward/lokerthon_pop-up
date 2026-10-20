import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'kiosk_canvas.dart';

/// 덮개는 안전 영역까지 덮고, 실제 조작 요소만 안전 영역 안에 배치한다.
/// Portal은 호출 화면이 사라질 때 함께 제거되어 초기화 뒤 시트가 남지 않는다.
class KioskModal extends StatefulWidget {
  const KioskModal({
    super.key,
    required this.opacity,
    required this.onDismiss,
    required this.dismissLabel,
    required this.child,
  });

  final Animation<double> opacity;
  final VoidCallback onDismiss;
  final String dismissLabel;
  final Widget child;

  @override
  State<KioskModal> createState() => _KioskModalState();
}

class _KioskModalState extends State<KioskModal> {
  final _portal = OverlayPortalController()..show();

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayLocation: OverlayChildLocation.rootOverlay,
    overlayChildBuilder: (context) {
      // 호출한 본문의 SafeArea가 제거한 여백을 실제 화면 기준으로 복원한다.
      // 글자 확대·동작 줄이기 등 사용자가 선택한 나머지 설정은 유지한다.
      final view = MediaQueryData.fromView(View.of(context));
      return MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: view.padding, viewPadding: view.viewPadding),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: widget.opacity,
              child: ModalBarrier(
                color: AppColors.accentDeep.withValues(alpha: 0.38),
                dismissible: true,
                onDismiss: widget.onDismiss,
                semanticsLabel: widget.dismissLabel,
              ),
            ),
            KioskCanvasLayer(child: widget.child),
          ],
        ),
      );
    },
    child: const SizedBox.expand(),
  );
}
