import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/admin_settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'glass_surface.dart';
import 'kiosk_modal.dart';

enum AdminPinMode {
  /// 관리자 설정에 들어가기 전 암호 확인.
  verify,

  /// 새 암호를 두 번 입력받아 바꾼다.
  change,
}

/// 관리자 암호 입력 패드. 운영자용 화면이라 한국어만 쓴다.
class AdminPinPad extends StatefulWidget {
  const AdminPinPad({
    super.key,
    required this.settings,
    required this.onCancel,
    required this.onDone,
    this.mode = AdminPinMode.verify,
  });

  final AdminSettings settings;
  final VoidCallback onCancel;

  /// 확인 모드에서는 암호가 맞았을 때, 변경 모드에서는 저장이 끝났을 때 부른다.
  final VoidCallback onDone;
  final AdminPinMode mode;

  @override
  State<AdminPinPad> createState() => _AdminPinPadState();
}

class _AdminPinPadState extends State<AdminPinPad>
    with SingleTickerProviderStateMixin {
  String _input = '';
  String? _firstEntry;
  String? _message;
  bool _busy = false;
  Timer? _lockTicker;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  bool get _isChange => widget.mode == AdminPinMode.change;

  @override
  void initState() {
    super.initState();
    _syncLock();
  }

  @override
  void dispose() {
    _lockTicker?.cancel();
    _shake.dispose();
    super.dispose();
  }

  /// 잠겨 있는 동안 남은 초를 1초마다 갱신한다.
  void _syncLock() {
    _lockTicker?.cancel();
    final left = widget.settings.lockRemaining;
    if (left == null) return;
    _message = _lockMessage(left);
    _lockTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      final remaining = widget.settings.lockRemaining;
      setState(() {
        if (remaining == null) {
          timer.cancel();
          _message = null;
        } else {
          _message = _lockMessage(remaining);
        }
      });
    });
  }

  String _lockMessage(Duration left) =>
      '여러 번 틀려 잠시 잠겼어요. ${(left.inMilliseconds / 1000).ceil()}초 뒤 다시 시도해 주세요.';

  bool get _locked => !_isChange && widget.settings.lockRemaining != null;

  void _press(String digit) {
    if (_busy || _locked || _input.length >= AdminSettings.pinLength) return;
    setState(() {
      _input += digit;
      if (_input.length == 1 && _firstEntry == null) _message = null;
    });
    if (_input.length == AdminSettings.pinLength) _submit();
  }

  void _delete() {
    if (_busy || _input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _submit() async {
    final entry = _input;
    if (!_isChange) {
      switch (widget.settings.checkPin(entry)) {
        case PinCheck.ok:
          widget.onDone();
        case PinCheck.wrong:
          _reject('암호가 올바르지 않아요.');
        case PinCheck.locked:
          _reject(null);
          _syncLock();
      }
      return;
    }

    if (_firstEntry == null) {
      setState(() {
        _firstEntry = entry;
        _input = '';
        _message = null;
      });
      return;
    }
    if (_firstEntry != entry) {
      _firstEntry = null;
      _reject('두 암호가 달라요. 처음부터 다시 입력해 주세요.');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.settings.changePin(entry);
      if (mounted) widget.onDone();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _firstEntry = null;
      _reject('암호를 저장하지 못했어요. 다시 시도해 주세요.');
    }
  }

  void _reject(String? message) {
    if (!MediaQuery.disableAnimationsOf(context)) _shake.forward(from: 0);
    setState(() {
      _input = '';
      if (message != null) _message = message;
    });
  }

  String get _title {
    if (!_isChange) return '관리자 암호';
    return _firstEntry == null ? '새 암호 입력' : '새 암호 확인';
  }

  String get _subtitle {
    if (!_isChange) return '숫자 4자리를 입력해 주세요.';
    return _firstEntry == null
        ? '새로 쓸 숫자 4자리를 입력해 주세요.'
        : '같은 암호를 한 번 더 입력해 주세요.';
  }

  @override
  Widget build(BuildContext context) => KioskModal(
    opacity: kAlwaysCompleteAnimation,
    onDismiss: widget.onCancel,
    dismissLabel: '암호 입력 닫기',
    child: Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: _title,
      child: Center(
        child: GlassSurface(
          radius: Radii.sheet,
          strong: true,
          blurBackdrop: true,
          child: SizedBox(
            key: const ValueKey('admin-pin-pad'),
            width: 460,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.xxl,
                  Space.xl,
                  Space.xxl,
                  Space.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    Text(_title, style: Type.section.copyWith(fontSize: 28)),
                    const SizedBox(height: Space.xs),
                    Text(
                      _subtitle,
                      style: Type.bodyMuted.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: Space.lg),
                    AnimatedBuilder(
                      animation: _shake,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          math.sin(_shake.value * math.pi * 6) *
                              12 *
                              (1 - _shake.value),
                          0,
                        ),
                        child: child,
                      ),
                      child: _Dots(filled: _input.length),
                    ),
                    const SizedBox(height: Space.sm),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Center(
                        child: Text(
                          _message ?? '',
                          textAlign: TextAlign.center,
                          style: Type.caption.copyWith(
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    _Keypad(
                      enabled: !_busy && !_locked,
                      onDigit: _press,
                      onDelete: _delete,
                      onCancel: widget.onCancel,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < AdminSettings.pinLength; i++) ...[
        if (i > 0) const SizedBox(width: Space.md),
        AnimatedContainer(
          duration: Motion.fast,
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < filled ? AppColors.accent : Colors.transparent,
            border: Border.all(
              color: i < filled ? AppColors.accent : AppColors.lineStrong,
              width: 1.5,
            ),
          ),
        ),
      ],
    ],
  );
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.enabled,
    required this.onDigit,
    required this.onDelete,
    required this.onCancel,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    Widget digit(String d) => _Key(
      key: ValueKey('pin-key-$d'),
      onTap: enabled ? () => onDigit(d) : null,
      child: Text(d, style: Type.section.copyWith(fontSize: 28)),
    );
    Widget row(List<Widget> keys) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: Space.sm),
          keys[i],
        ],
      ],
    );
    return Column(
      children: [
        row([digit('1'), digit('2'), digit('3')]),
        const SizedBox(height: Space.sm),
        row([digit('4'), digit('5'), digit('6')]),
        const SizedBox(height: Space.sm),
        row([digit('7'), digit('8'), digit('9')]),
        const SizedBox(height: Space.sm),
        row([
          _Key(
            key: const ValueKey('pin-cancel'),
            filled: false,
            onTap: onCancel,
            child: Text(
              '취소',
              style: Type.body.copyWith(fontSize: 20, color: AppColors.muted),
            ),
          ),
          digit('0'),
          _Key(
            key: const ValueKey('pin-delete'),
            filled: false,
            onTap: enabled ? onDelete : null,
            semanticLabel: '지우기',
            child: const Icon(
              Icons.backspace_rounded,
              size: 24,
              color: AppColors.muted,
            ),
          ),
        ]),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    super.key,
    required this.child,
    required this.onTap,
    this.filled = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool filled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: Material(
      color: filled
          ? Colors.white.withValues(alpha: onTap == null ? 0.35 : 0.72)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.button),
        child: SizedBox(width: 112, height: 72, child: Center(child: child)),
      ),
    ),
  );
}
