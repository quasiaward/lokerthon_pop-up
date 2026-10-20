import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/dangwa_catalog.dart';
import '../../data/dagwa_results.dart';
import '../../data/dagwa_tones.dart';
import '../../services/admin_settings.dart';
import '../../services/dangwa_inventory.dart';
import '../../services/local_recommendation_engine.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'admin_pin_pad.dart';
import 'dangwa_image.dart';
import 'glass_surface.dart';
import 'kiosk_button.dart';

class AdminInventorySheet extends StatefulWidget {
  const AdminInventorySheet({
    super.key,
    required this.inventory,
    required this.settings,
    required this.onClose,
  });

  final DagwaInventory inventory;
  final AdminSettings settings;
  final VoidCallback onClose;

  @override
  State<AdminInventorySheet> createState() => _AdminInventorySheetState();
}

enum _Tab { inventory, simple, advanced }

class _AdminInventorySheetState extends State<AdminInventorySheet> {
  String? _message;
  bool _saving = false;
  _Tab _tab = _Tab.inventory;
  bool _changingPin = false;
  String? _notice;

  void _selectTab(_Tab tab) => setState(() {
    _tab = tab;
    _message = null;
    _notice = null;
  });

  Future<void> _setWeight(String menu, double value) async {
    try {
      await widget.settings.setWeight(menu, value);
    } catch (_) {
      if (mounted) setState(() => _message = '설정을 저장하지 못했어요. 다시 시도해 주세요.');
    }
  }

  Future<void> _resetWeights() async {
    setState(() {
      _message = null;
      _notice = null;
    });
    try {
      await widget.settings.resetWeights();
    } catch (_) {
      if (mounted) setState(() => _message = '설정을 저장하지 못했어요. 다시 시도해 주세요.');
    }
  }

  Future<void> _setStock(String menu, bool inStock) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final changed = await widget.inventory.setInStock(menu, inStock);
      if (!changed && mounted) {
        setState(() => _message = '최소 1개의 다과는 재고 있음으로 유지해 주세요.');
      }
    } catch (_) {
      if (mounted) setState(() => _message = '설정을 저장하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _restoreAll() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await widget.inventory.restoreAll();
    } catch (_) {
      if (mounted) setState(() => _message = '설정을 저장하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    scopesRoute: true,
    namesRoute: true,
    explicitChildNodes: true,
    label: '관리자 재고 설정',
    child: Stack(
      children: [
        Positioned.fill(
          child: ModalBarrier(
            color: AppColors.accentDeep.withValues(alpha: 0.38),
            dismissible: true,
            onDismiss: widget.onClose,
            semanticsLabel: '관리자 설정 닫기',
          ),
        ),
        Center(
          child: GlassSurface(
            radius: Radii.sheet,
            strong: true,
            blurBackdrop: true,
            child: SizedBox(
              key: const ValueKey('admin-inventory-sheet'),
              width: 1080,
              height: 790,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(46, 34, 46, 38),
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    widget.inventory,
                    widget.settings,
                  ]),
                  builder: (context, _) => _buildContent(),
                ),
              ),
            ),
          ),
        ),
        if (_changingPin)
          Positioned.fill(
            child: AdminPinPad(
              settings: widget.settings,
              mode: AdminPinMode.change,
              onCancel: () => setState(() => _changingPin = false),
              onDone: () => setState(() {
                _changingPin = false;
                _message = null;
                _notice = '관리자 암호를 바꿨어요.';
              }),
            ),
          ),
      ],
    ),
  );

  Widget _buildContent() {
    final inStock = widget.inventory.value;
    final advanced = _tab == _Tab.advanced;
    final weightsTab = _tab != _Tab.inventory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                weightsTab ? Icons.tune_rounded : Icons.inventory_2_rounded,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(switch (_tab) {
                    _Tab.inventory => '관리자 재고 설정',
                    _Tab.simple => '간단 설정',
                    _Tab.advanced => '고급 설정',
                  }, style: Type.section.copyWith(fontSize: 32)),
                  const SizedBox(height: 5),
                  Text(switch (_tab) {
                    _Tab.inventory => '품절된 다과를 끄면 다음 추천부터 바로 제외됩니다.',
                    _Tab.simple => '재고가 많으면 높음, 적으면 낮음으로 추천 확률을 바꿔 주세요.',
                    _Tab.advanced => '다과별 추천 비중을 0.01 단위로 조절합니다.',
                  }, style: Type.bodyMuted.copyWith(fontSize: 18)),
                ],
              ),
            ),
            _CountBadge(count: inStock.length),
            const SizedBox(width: 14),
            IconButton(
              onPressed: widget.onClose,
              tooltip: '닫기',
              icon: const Icon(Icons.close_rounded, size: 24),
              style: IconButton.styleFrom(
                minimumSize: const Size(52, 52),
                backgroundColor: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Tabs(selected: _tab, onSelect: _selectTab),
        const SizedBox(height: 20),
        Expanded(
          child: weightsTab
              ? _WeightPanel(
                  simple: !advanced,
                  inStock: inStock,
                  settings: widget.settings,
                  onChanged: _setWeight,
                )
              : _InventoryGrid(
                  inStock: inStock,
                  enabled: !_saving,
                  onChanged: _setStock,
                ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 30),
          child: _message != null
              ? Row(
                  children: [
                    Icon(
                      Icons.error_rounded,
                      size: 20,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _message!,
                        style: Type.caption.copyWith(
                          fontSize: 17,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                )
              : _notice != null
              ? Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: AppColors.celadon,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _notice!,
                        style: Type.caption.copyWith(
                          fontSize: 17,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (weightsTab)
              Expanded(
                child: KioskButton(
                  label: '비중 초기화',
                  variant: KioskButtonVariant.secondary,
                  onPressed: widget.settings.hasCustomWeights
                      ? _resetWeights
                      : null,
                  fullWidth: true,
                ),
              ),
            if (advanced) ...[
              const SizedBox(width: 14),
              Expanded(
                child: KioskButton(
                  label: '암호 변경',
                  variant: KioskButtonVariant.secondary,
                  onPressed: () => setState(() {
                    _notice = null;
                    _changingPin = true;
                  }),
                  fullWidth: true,
                ),
              ),
            ],
            if (!weightsTab)
              Expanded(
                child: KioskButton(
                  label: '전체 재고 있음',
                  variant: KioskButtonVariant.secondary,
                  onPressed: _saving ? null : _restoreAll,
                  fullWidth: true,
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: KioskButton(
                label: '설정 완료',
                onPressed: _saving ? null : widget.onClose,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onSelect});

  final _Tab selected;
  final ValueChanged<_Tab> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget tab(_Tab tab, String label) {
      final active = tab == selected;
      return Semantics(
        button: true,
        selected: active,
        child: GestureDetector(
          key: ValueKey('admin-tab-${tab.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelect(tab),
          child: AnimatedContainer(
            duration: Motion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              label,
              style: Type.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.charcoal,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab(_Tab.inventory, '재고 관리'),
          tab(_Tab.simple, '간단 설정'),
          tab(_Tab.advanced, '고급 설정'),
        ],
      ),
    );
  }
}

/// 다과별 추천 비중 조절. 옆에 모든 답변 조합 기준의 예상 추천 비율을 보여 준다.
class _WeightPanel extends StatefulWidget {
  const _WeightPanel({
    required this.simple,
    required this.inStock,
    required this.settings,
    required this.onChanged,
  });

  /// true면 낮음·보통·높음 버튼, false면 슬라이더.
  final bool simple;
  final Set<String> inStock;
  final AdminSettings settings;
  final void Function(String menu, double value) onChanged;

  @override
  State<_WeightPanel> createState() => _WeightPanelState();
}

class _WeightPanelState extends State<_WeightPanel> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// 슬라이더를 끄는 동안 보여 줄 값. 손을 떼면 저장한다.
  final Map<String, double> _dragging = {};

  Map<String, double> get _weights => {
    for (final menu in activeDagwaMenus)
      menu: _dragging[menu] ?? widget.settings.weightOf(menu),
  };

  String _subtitle(String menu, double weight) {
    if (!widget.inStock.contains(menu)) return '품절 · 추천 제외';
    final multiplier = '×${weight.toStringAsFixed(2)}';
    if (!widget.simple) return '비중 $multiplier';
    final level = widget.settings.levelOf(menu);
    return level == null
        ? '고급 설정 값 $multiplier'
        : '${level.label} · 비중 $multiplier';
  }

  @override
  Widget build(BuildContext context) {
    final weights = _weights;
    final shares = LocalRecommendationEngine.expectedShares(
      availableMenus: widget.inStock,
      weights: weights,
    );
    final baseline = LocalRecommendationEngine.expectedShares(
      availableMenus: widget.inStock,
    );
    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      child: ListView(
        controller: _scroll,
        key: const PageStorageKey('admin-weights-scroll'),
        padding: const EdgeInsets.only(right: 12),
        children: [
          for (final menu in activeDagwaMenus) ...[
            if (menu != activeDagwaMenus.first) const SizedBox(height: 10),
            _WeightRow(
              menu: menu,
              inStock: widget.inStock.contains(menu),
              weight: weights[menu]!,
              share: shares[menu] ?? 0,
              baselineShare: baseline[menu] ?? 0,
              subtitle: _subtitle(menu, weights[menu]!),
              control: widget.simple
                  ? _LevelButtons(
                      key: ValueKey('level-$menu'),
                      selected: widget.settings.levelOf(menu),
                      enabled: widget.inStock.contains(menu),
                      onSelect: (level) => widget.onChanged(menu, level.weight),
                    )
                  : _WeightSlider(
                      key: ValueKey('weight-$menu'),
                      weight: weights[menu]!,
                      enabled: widget.inStock.contains(menu),
                      onChanged: (value) => setState(
                        () => _dragging[menu] = AdminSettings.normalizeWeight(
                          value,
                        ),
                      ),
                      onChangeEnd: (value) {
                        final normalized = AdminSettings.normalizeWeight(value);
                        widget.onChanged(menu, normalized);
                        setState(() => _dragging.remove(menu));
                      },
                    ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '예상 추천 비율은 4,096가지 답변 조합이 고르게 나온다고 보고 계산한 값이에요. '
            '품절 다과는 0%입니다.',
            style: Type.caption.copyWith(fontSize: 15, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({
    required this.menu,
    required this.inStock,
    required this.weight,
    required this.share,
    required this.baselineShare,
    required this.subtitle,
    required this.control,
  });

  final String menu;
  final bool inStock;
  final double weight;
  final double share;
  final double baselineShare;
  final String subtitle;
  final Widget control;

  String _percent(double v) => '${(v * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final result = dagwaResults[menu]!;
    final changed = (share - baselineShare).abs() >= 0.005;
    final stacked = MediaQuery.textScalerOf(context).scale(20) > 22;
    final details = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result.name.ko, style: Type.section.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Type.caption.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: inStock ? AppColors.muted : AppColors.faint,
          ),
        ),
      ],
    );
    final shareLabel = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _percent(share),
          key: ValueKey('share-$menu'),
          style: Type.section.copyWith(fontSize: 24, color: AppColors.accent),
        ),
        Text(
          changed ? '기본 ${_percent(baselineShare)}' : '예상 추천 비율',
          style: Type.caption.copyWith(fontSize: 14, color: AppColors.muted),
        ),
      ],
    );
    return AnimatedOpacity(
      opacity: inStock ? 1 : 0.55,
      duration: Motion.fast,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: stacked ? 12 : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: inStock ? 0.68 : 0.38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: DangwaImage(
                    assetPath: result.imagePath,
                    tone: toneFor(menu),
                    padding: 0.08,
                  ),
                ),
                const SizedBox(width: 14),
                if (stacked)
                  Expanded(child: details)
                else
                  SizedBox(width: 190, child: details),
                if (!stacked) Expanded(child: control),
                const SizedBox(width: 18),
                SizedBox(width: stacked ? 200 : 150, child: shareLabel),
              ],
            ),
            if (stacked) ...[const SizedBox(height: 12), control],
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.celadonSoft,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      '재고 있음 $count / ${activeDagwaMenus.length}',
      style: Type.caption.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      ),
    ),
  );
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({
    super.key,
    required this.menu,
    required this.inStock,
    required this.enabled,
    required this.onChanged,
  });

  final String menu;
  final bool inStock;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final result = dagwaResults[menu]!;
    return AnimatedOpacity(
      opacity: inStock ? 1 : 0.62,
      duration: Motion.fast,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: inStock ? 0.68 : 0.38),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: inStock
                ? Colors.white.withValues(alpha: 0.92)
                : AppColors.line.withValues(alpha: 0.52),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: DangwaImage(
                assetPath: result.imagePath,
                tone: toneFor(menu),
                padding: 0.08,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name.ko,
                    style: Type.section.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inStock ? '추천 가능' : '추천에서 제외',
                    style: Type.caption.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: inStock ? AppColors.celadon : AppColors.faint,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: inStock,
              onChanged: enabled ? onChanged : null,
              activeTrackColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightSlider extends StatelessWidget {
  const _WeightSlider({
    super.key,
    required this.weight,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double weight;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text('낮음', style: Type.caption.copyWith(fontSize: 15)),
      Expanded(
        child: Slider(
          value: weight,
          min: AdminSettings.minWeight,
          max: AdminSettings.maxWeight,
          divisions:
              ((AdminSettings.maxWeight - AdminSettings.minWeight) /
                      AdminSettings.weightStep)
                  .round(),
          activeColor: AppColors.accent,
          inactiveColor: AppColors.mist,
          onChanged: enabled ? onChanged : null,
          onChangeEnd: enabled ? onChangeEnd : null,
        ),
      ),
      Text('높음', style: Type.caption.copyWith(fontSize: 15)),
    ],
  );
}

/// 낮음·보통·높음 세 버튼. 고급 설정에서 다른 값을 골랐으면 아무것도 켜지지 않는다.
class _LevelButtons extends StatelessWidget {
  const _LevelButtons({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  final WeightLevel? selected;
  final bool enabled;
  final ValueChanged<WeightLevel> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (final level in WeightLevel.values) ...[
        if (level != WeightLevel.values.first) const SizedBox(width: 10),
        _LevelButton(
          key: ValueKey('level-${level.name}'),
          label: level.label,
          active: level == selected,
          onTap: enabled ? () => onSelect(level) : null,
        ),
      ],
    ],
  );
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: active,
    enabled: onTap != null,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        constraints: const BoxConstraints(minWidth: 104, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? AppColors.accent : AppColors.line),
        ),
        child: Text(
          label,
          style: Type.body.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.charcoal,
          ),
        ),
      ),
    ),
  );
}

/// 재고 타일 두 칸씩. 글자가 커지면 행 높이를 늘리고 스크롤한다.
class _InventoryGrid extends StatefulWidget {
  const _InventoryGrid({
    required this.inStock,
    required this.enabled,
    required this.onChanged,
  });

  final Set<String> inStock;
  final bool enabled;
  final void Function(String menu, bool inStock) onChanged;

  @override
  State<_InventoryGrid> createState() => _InventoryGridState();
}

class _InventoryGridState extends State<_InventoryGrid> {
  static const _columns = 2;
  static const _gap = 14.0;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (activeDagwaMenus.length / _columns).ceil();
        final rowHeight = math.max(
          (constraints.maxHeight - _gap * (rows - 1)) / rows,
          // 이름 두 줄과 재고 안내 한 줄, 카드 안쪽 여백을 확보한다.
          math.max(
            116.0,
            scaler.scale(22) * 1.25 * 2 + 8 + scaler.scale(16) * 1.6 + 24,
          ),
        );
        return Scrollbar(
          controller: _scroll,
          thumbVisibility: true,
          child: GridView.builder(
            controller: _scroll,
            key: const PageStorageKey('admin-inventory-scroll'),
            padding: const EdgeInsets.only(right: 12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columns,
              crossAxisSpacing: _gap,
              mainAxisSpacing: _gap,
              mainAxisExtent: rowHeight,
            ),
            itemCount: activeDagwaMenus.length,
            itemBuilder: (context, index) {
              final menu = activeDagwaMenus[index];
              return _InventoryTile(
                key: ValueKey('stock-$menu'),
                menu: menu,
                inStock: widget.inStock.contains(menu),
                enabled: widget.enabled,
                onChanged: (value) => widget.onChanged(menu, value),
              );
            },
          ),
        );
      },
    );
  }
}
