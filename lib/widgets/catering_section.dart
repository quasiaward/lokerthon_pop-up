import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../l10n/lang.dart';
import 'watercolor_deco.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

const _packagingFee = 1500;
const _apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

// ── 상자 크기 ──────────────────────────────────────────────────────────────────

class _BoxSize {
  const _BoxSize({
    required this.slots,
    required this.price,
    required this.label,
  });
  final int slots;
  final int price;
  final String label;
}

const _boxSizes = [
  _BoxSize(slots: 4, price: 8000, label: '4구'),
  _BoxSize(slots: 6, price: 12000, label: '6구'),
  _BoxSize(slots: 9, price: 18000, label: '9구'),
];

class _BoxConfig {
  const _BoxConfig({
    required this.count,
    required this.asset,
    required this.aspectRatio,
    required this.centers,
    required this.scales,
  });

  final int count;
  final String asset;
  final double aspectRatio;
  final List<Offset> centers;
  final List<double> scales;
}

const _boxConfigs = <_BoxConfig>[
  _BoxConfig(
    count: 4,
    asset: 'assets/figma/catering_box_4_ver1.png',
    aspectRatio: 1,
    centers: [
      Offset(0.315, 0.375),
      Offset(0.685, 0.375),
      Offset(0.315, 0.665),
      Offset(0.685, 0.665),
    ],
    scales: [0.225, 0.225, 0.235, 0.235],
  ),
  _BoxConfig(
    count: 6,
    asset: 'assets/figma/catering_box_6_ver1.png',
    aspectRatio: 1402 / 1122,
    centers: [
      Offset(0.245, 0.390),
      Offset(0.500, 0.390),
      Offset(0.755, 0.390),
      Offset(0.245, 0.665),
      Offset(0.500, 0.665),
      Offset(0.755, 0.665),
    ],
    scales: [0.142, 0.142, 0.142, 0.152, 0.152, 0.152],
  ),
  _BoxConfig(
    count: 9,
    asset: 'assets/figma/catering_box_9_ver1.png',
    aspectRatio: 1,
    centers: [
      Offset(0.245, 0.315),
      Offset(0.500, 0.315),
      Offset(0.755, 0.315),
      Offset(0.245, 0.525),
      Offset(0.500, 0.525),
      Offset(0.755, 0.525),
      Offset(0.245, 0.735),
      Offset(0.500, 0.735),
      Offset(0.755, 0.735),
    ],
    scales: [0.125, 0.125, 0.125, 0.132, 0.132, 0.132, 0.138, 0.138, 0.138],
  ),
];

_BoxConfig _boxConfigForSlots(int slots) =>
    _boxConfigs.firstWhere((box) => box.count == slots);

// ── 다과 목록 ──────────────────────────────────────────────────────────────────

class _DagwaItem {
  const _DagwaItem({
    required this.name,
    required this.nameEn,
    required this.price,
    required this.imagePath,
  });
  final String name;
  final String nameEn;
  final int price;
  final String imagePath;
}

const _dagwaItems = [
  _DagwaItem(
    name: '오븐에 구운 찰떡',
    nameEn: 'Oven-baked Chapssal-tteok',
    price: 3000,
    imagePath: 'assets/figma/recommend/nutrition_rice_cake.png',
  ),
  _DagwaItem(
    name: '도라지정과',
    nameEn: 'Bellflower Jeonggwa',
    price: 2500,
    imagePath: 'assets/figma/recommend/bellflower_jeonggwa.png',
  ),
  _DagwaItem(
    name: '행궁약과',
    nameEn: 'Haenggung Yakgwa',
    price: 2500,
    imagePath: 'assets/figma/recommend/suwon_yakgwa.png',
  ),
  _DagwaItem(
    name: '흑임자다식',
    nameEn: 'Black Sesame Dasik',
    price: 3000,
    imagePath: 'assets/figma/recommend/black_sesame_dasik.png',
  ),
  _DagwaItem(
    name: '곶감호두말이',
    nameEn: 'Persimmon Walnut Roll',
    price: 1500,
    imagePath: 'assets/figma/recommend/persimmon_walnut_roll.png',
  ),
  _DagwaItem(
    name: '육포다식',
    nameEn: 'Yukpo Dasik',
    price: 3000,
    imagePath: 'assets/figma/recommend/yukpo_jeonggwa.png',
  ),
  _DagwaItem(
    name: '콩고물도라지정과',
    nameEn: 'Soybean Bellflower Jeonggwa',
    price: 2000,
    imagePath: 'assets/figma/recommend/soybean_bellflower_jeonggwa.png',
  ),
  _DagwaItem(
    name: '금귤정과',
    nameEn: 'Kumquat Jeonggwa',
    price: 2000,
    imagePath: 'assets/figma/recommend/kumquat_jeonggwa.png',
  ),
  _DagwaItem(
    name: '양갱',
    nameEn: 'Yanggaeng',
    price: 2000,
    imagePath: 'assets/figma/recommend/yanggaeng.png',
  ),
  _DagwaItem(
    name: '견과류',
    nameEn: 'Mixed Nuts',
    price: 1500,
    imagePath: 'assets/figma/recommend/roasted_nuts.png',
  ),
  _DagwaItem(
    name: '매작과',
    nameEn: 'Maejakgwa',
    price: 2000,
    imagePath: 'assets/figma/recommend/maejakgwa.png',
  ),
  _DagwaItem(
    name: '깨강정',
    nameEn: 'Sesame Gangjeong',
    price: 2000,
    imagePath: 'assets/figma/recommend/sesame_crunch.png',
  ),
];

const _timeSlots = [
  '11:00',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
  '17:00',
  '18:00',
  '19:00',
  '20:00',
];

// ── 단계 ──────────────────────────────────────────────────────────────────────

enum _Stage { select, form, complete }

// ── 메인 위젯 ─────────────────────────────────────────────────────────────────

class CateringSection extends StatefulWidget {
  const CateringSection({super.key});

  @override
  State<CateringSection> createState() => _CateringSectionState();
}

class _CateringSectionState extends State<CateringSection> {
  _Stage _stage = _Stage.select;
  int _boxSizeIndex = 0;
  late List<_DagwaItem?> _slots;

  // 주문 폼
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _pickupDate;
  String? _pickupTime;
  int _quantity = 1;
  bool _isSubmitting = false;

  _BoxSize get _box => _boxSizes[_boxSizeIndex];
  int get _totalPrice => _box.price * _quantity + _packagingFee;
  bool get _isFull => _slots.whereType<_DagwaItem>().length == _box.slots;

  @override
  void initState() {
    super.initState();
    _slots = List.filled(_boxSizes[0].slots, null);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _changeBoxSize(int index) {
    setState(() {
      _boxSizeIndex = index;
      _slots = List.filled(_boxSizes[index].slots, null);
    });
  }

  void _addDagwa(_DagwaItem item) {
    final idx = _slots.indexWhere((s) => s == null);
    if (idx == -1) return;
    setState(() => _slots[idx] = item);
  }

  void _removeSlot(int idx) {
    setState(() => _slots[idx] = null);
  }

  void _goToForm() => setState(() => _stage = _Stage.form);
  void _backToSelect() => setState(() => _stage = _Stage.select);

  Future<void> _submitOrder() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _pickupDate == null ||
        _pickupTime == null) {
      _showSnack(tr('모든 항목을 입력해 주세요.', 'Please fill in all fields.'));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final dateStr =
          '${_pickupDate!.year}/${_pickupDate!.month.toString().padLeft(2, '0')}/${_pickupDate!.day.toString().padLeft(2, '0')}';
      final res = await http.post(
        Uri.parse('$_apiBase/email/custom'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'box_size': _box.slots,
          'quantity': _quantity,
          'items': _slots.whereType<_DagwaItem>().map((d) => d.name).toList(),
          'pickup_date': dateStr,
          'pickup_time': _pickupTime,
          'total_price': _totalPrice,
        }),
      );
      if (res.statusCode == 200) {
        setState(() => _stage = _Stage.complete);
      } else {
        _showSnack(
          tr('전송에 실패했습니다. 다시 시도해 주세요.', 'Submission failed. Please try again.'),
        );
      }
    } catch (_) {
      _showSnack(tr('네트워크 오류가 발생했습니다.', 'A network error occurred.'));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF7A3B47),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: switch (_stage) {
        _Stage.select => _SelectView(
          key: const ValueKey('select'),
          state: this,
        ),
        _Stage.form => _FormView(key: const ValueKey('form'), state: this),
        _Stage.complete => _CompleteView(
          key: const ValueKey('complete'),
          state: this,
        ),
      },
    );
  }
}

// ── 헬퍼: 가격 포맷 ────────────────────────────────────────────────────────────

String _won(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${buf.toString()}원';
}

// ── 상자 미리보기 위젯 ────────────────────────────────────────────────────────

class _BoxPreview extends StatelessWidget {
  const _BoxPreview({
    required this.slots,
    required this.onRemove,
    this.size = 300,
  });
  final List<_DagwaItem?> slots;
  final void Function(int)? onRemove;
  final double size;

  @override
  Widget build(BuildContext context) {
    final box = _boxConfigForSlots(slots.length);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size),
        child: AspectRatio(
          aspectRatio: box.aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: width * 0.12,
                    right: width * 0.12,
                    bottom: height * 0.02,
                    height: height * 0.16,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(400, 60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4AC89C9C),
                            blurRadius: 60,
                            spreadRadius: 6,
                            offset: Offset(0, 28),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Image.asset(box.asset, fit: BoxFit.contain),
                  ),
                  for (var i = 0; i < slots.length; i++)
                    _BoxSlot(
                      item: slots[i],
                      center: Offset(
                        width * box.centers[i].dx,
                        height * box.centers[i].dy,
                      ),
                      itemSize: width * box.scales[i],
                      onRemove: onRemove == null ? null : () => onRemove!(i),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BoxSlot extends StatefulWidget {
  const _BoxSlot({
    required this.item,
    required this.center,
    required this.itemSize,
    required this.onRemove,
  });

  final _DagwaItem? item;
  final Offset center;
  final double itemSize;
  final VoidCallback? onRemove;

  @override
  State<_BoxSlot> createState() => _BoxSlotState();
}

class _BoxSlotState extends State<_BoxSlot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final size = widget.itemSize;

    if (item == null) {
      return const SizedBox.shrink();
    }

    final badge = (size * 0.26).clamp(22.0, 28.0);

    return Positioned(
      left: widget.center.dx - size / 2,
      top: widget.center.dy - size / 2,
      width: size,
      height: size,
      child: MouseRegion(
        cursor: widget.onRemove == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onRemove,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(item.imagePath),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 440),
                  curve: Curves.easeOutBack,
                  builder: (context, t, child) => Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.62 + 0.38 * t,
                      child: child,
                    ),
                  ),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    scale: _hovered && widget.onRemove != null ? 1.05 : 1,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 하단 그림자
                        Positioned(
                          bottom: 0,
                          left: size * 0.14,
                          right: size * 0.14,
                          height: size * 0.10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(size * 0.30, size * 0.05),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF5A4632,
                                  ).withValues(alpha: _hovered ? 0.26 : 0.18),
                                  blurRadius: _hovered ? 20 : 14,
                                  spreadRadius: -2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 이미지: 슬롯 중앙 정렬
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(size * 0.07),
                            child: Image.asset(
                              item.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.onRemove != null)
                Positioned(
                  top: -badge * 0.32,
                  right: -badge * 0.32,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    offset: _hovered ? Offset.zero : const Offset(0, 0.2),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: _hovered ? 1 : 0,
                      child: _RemoveBadge(diameter: badge),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveBadge extends StatelessWidget {
  const _RemoveBadge({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE7D8D2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A3A30).withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(diameter * 0.36, diameter * 0.36),
          painter: const _ThinCrossPainter(Color(0xFF97636B)),
        ),
      ),
    );
  }
}

class _ThinCrossPainter extends CustomPainter {
  const _ThinCrossPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ThinCrossPainter old) => old.color != color;
}

// ── 0단계: 상자 크기 선택 ────────────────────────────────────────────────────

class _BoxSizeSelector extends StatelessWidget {
  const _BoxSizeSelector({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        for (var i = 0; i < _boxSizes.length; i++)
          _SizeChip(
            label: tr(_boxSizes[i].label, '${_boxSizes[i].slots}-pc'),
            active: i == selected,
            onTap: () => onSelect(i),
          ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF934753) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? const Color(0xFF934753) : const Color(0xFFE5D6D0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF7A6A6A),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 1단계: 다과 선택 ──────────────────────────────────────────────────────────

class _SelectView extends StatelessWidget {
  const _SelectView({super.key, required this.state});
  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 720;
    final boxPreviewSize = screenWidth < 520 ? 340.0 : 520.0;
    final deco = decoScaleOf(context, designWidth: 1409);

    return Container(
      color: const Color(0xFFFFF9F6),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 0,
            top: 360 * deco,
            child: WatercolorDeco(decoClusterSoft, width: 560 * deco),
          ),
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1054),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    compact ? 52 : 84,
                    24,
                    compact ? 64 : 92,
                  ),
                  child: Column(
                    children: [
                      Text(
                        tr(
                          '${state._box.label} 다과 상자',
                          '${state._box.label} Dagwa Box',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF534344),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: compact ? 34 : 50,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      Text(
                        tr(
                          '원하는 다과로 상자를 구성해주세요.',
                          'Compose your box with the dagwa you like.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF534344),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 18,
                          height: 1.55,
                        ),
                      ),
                      SizedBox(height: compact ? 22 : 30),
                      _BoxSizeSelector(
                        selected: state._boxSizeIndex,
                        onSelect: state._changeBoxSize,
                      ),
                      SizedBox(height: compact ? 24 : 36),
                      _BoxPreview(
                        slots: state._slots,
                        onRemove: state._removeSlot,
                        size: boxPreviewSize,
                      ),
                      SizedBox(height: compact ? 36 : 60),
                      _DagwaGrid(
                        items: _dagwaItems,
                        isFull: state._isFull,
                        onSelected: state._addDagwa,
                      ),
                      SizedBox(height: compact ? 28 : 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: MouseRegion(
                          cursor: state._isFull
                              ? SystemMouseCursors.click
                              : SystemMouseCursors.basic,
                          child: GestureDetector(
                            onTap: state._isFull
                                ? state._goToForm
                                : () => state._showSnack(
                                    tr(
                                      '상자를 모두 채워주세요.',
                                      'Please fill every slot first.',
                                    ),
                                  ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              height: compact ? 58 : 68,
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 32 : 44,
                              ),
                              decoration: BoxDecoration(
                                color: state._isFull
                                    ? const Color(0xFF934753)
                                    : const Color(0xFFE4DCDA),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: state._isFull ? 0.15 : 0.07,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  tr('구매하러 가기', 'Proceed to Order'),
                                  style: TextStyle(
                                    color: state._isFull
                                        ? Colors.white
                                        : const Color(0xFFB0A0A0),
                                    fontFamily: 'Gowun Batang',
                                    fontFamilyFallback: _serifFallback,
                                    fontSize: compact ? 20 : 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DagwaGrid extends StatelessWidget {
  const _DagwaGrid({
    required this.items,
    required this.isFull,
    required this.onSelected,
  });

  final List<_DagwaItem> items;
  final bool isFull;
  final ValueChanged<_DagwaItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 2;
        final gap = columns == 3 ? 32.0 : 16.0;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _DagwaCard(
                  item: item,
                  isFull: isFull,
                  onTap: () => onSelected(item),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DagwaCard extends StatefulWidget {
  const _DagwaCard({
    required this.item,
    required this.isFull,
    required this.onTap,
  });

  final _DagwaItem item;
  final bool isFull;
  final VoidCallback onTap;

  @override
  State<_DagwaCard> createState() => _DagwaCardState();
}

class _DagwaCardState extends State<_DagwaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isFull
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isFull ? null : widget.onTap,
        child: Opacity(
          opacity: widget.isFull ? 0.42 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 256,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered && !widget.isFull
                    ? const Color(0xFF934753).withValues(alpha: 0.28)
                    : const Color(0xFFEBDAD5),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFC89C9C,
                  ).withValues(alpha: _hovered && !widget.isFull ? 0.24 : 0.12),
                  blurRadius: _hovered && !widget.isFull ? 20 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 150),
                    scale: _hovered && !widget.isFull ? 1.04 : 1,
                    child: Image.asset(
                      widget.item.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr(widget.item.name, widget.item.nameEn),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _hovered && !widget.isFull
                        ? const Color(0xFF934753)
                        : const Color(0xFF1C1C18),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr(
                    _won(widget.item.price),
                    _won(widget.item.price).replaceAll('원', ' KRW'),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF8C7E7B),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 14,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 2단계: 주문 폼 ────────────────────────────────────────────────────────────

class _FormView extends StatefulWidget {
  const _FormView({super.key, required this.state});
  final _CateringSectionState state;

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  _CateringSectionState get s => widget.state;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: s._pickupDate ?? now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      locale: const Locale('ko', 'KR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF7A3B47),
            onPrimary: Colors.white,
            surface: Color(0xFFFFF9F6),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    s.setState(() => s._pickupDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = s._pickupDate == null
        ? tr('날짜를 선택해주세요', 'Select a date')
        : '${s._pickupDate!.year}/${s._pickupDate!.month.toString().padLeft(2, '0')}/${s._pickupDate!.day.toString().padLeft(2, '0')}';

    return Container(
      color: const Color(0xFFFFF9F6),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀
                  Center(
                    child: Text(
                      tr(
                        '${s._box.label} 다과 상자 예약하기',
                        '${s._box.label} Dagwa Box Order',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF534344),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      tr(
                        '구성한 상자의 아래 날짜 및 상자 정보를 기입해주세요.',
                        'Please fill in the pickup date and order information.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8C7E7B),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 상자 미리보기 + 수정 버튼
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _BoxPreview(slots: s._slots, onRemove: null, size: 260),
                        Positioned(
                          right: -16,
                          bottom: -16,
                          child: OutlinedButton(
                            onPressed: s._backToSelect,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF7A3B47),
                              side: const BorderSide(color: Color(0xFF7A3B47)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              tr('다과 상자 수정하기', 'Edit box'),
                              style: const TextStyle(
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 폼
                  _FormField(
                    label: tr('성함', 'Name'),
                    child: TextField(
                      controller: s._nameCtrl,
                      decoration: _inputDeco(
                        tr('성함을 입력해주세요.', 'Enter your name'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormField(
                    label: tr('연락처', 'Phone'),
                    child: TextField(
                      controller: s._phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDeco(
                        tr('연락처를 입력해주세요.', 'Enter your phone number'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormField(
                    label: tr('희망 픽업 날짜', 'Pickup Date'),
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD9CCC8)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            color: s._pickupDate == null
                                ? const Color(0xFFBBAFAC)
                                : const Color(0xFF534344),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormField(
                    label: tr('희망 픽업 시간', 'Pickup Time'),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeSlots.map((t) {
                        final sel = s._pickupTime == t;
                        return GestureDetector(
                          onTap: () => s.setState(() => s._pickupTime = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFF7A3B47)
                                  : Colors.white,
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFF7A3B47)
                                    : const Color(0xFFD9CCC8),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF6B5B5A),
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FormField(
                    label: tr('다과 상자 수량', 'Quantity'),
                    child: Row(
                      children: [
                        _CountBtn(
                          icon: Icons.remove,
                          onTap: () {
                            if (s._quantity > 1) {
                              s.setState(() => s._quantity--);
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${s._quantity} ${tr('개', 'box(es)')}',
                          style: const TextStyle(
                            color: Color(0xFF534344),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _CountBtn(
                          icon: Icons.add,
                          onTap: () => s.setState(() => s._quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 가격
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        tr('총 금액', 'Total'),
                        style: const TextStyle(
                          color: Color(0xFF8C7E7B),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _won(s._totalPrice),
                        style: const TextStyle(
                          color: Color(0xFF7A3B47),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      tr('(포장비 1,500원 포함)', '(incl. packaging ₩1,500)'),
                      style: const TextStyle(
                        color: Color(0xFFAA9A96),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 예약하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      onPressed: s._isSubmitting ? null : s._submitOrder,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7A3B47),
                        disabledBackgroundColor: const Color(0xFFD9CCC8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: s._isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              tr('다과 상자 예약하기', 'Place Order'),
                              style: const TextStyle(
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(
    color: Color(0xFFBBAFAC),
    fontFamily: 'Gowun Batang',
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFD9CCC8)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFD9CCC8)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFF7A3B47)),
  ),
);

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B5B5A),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CountBtn extends StatelessWidget {
  const _CountBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF0E8E5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF7A3B47)),
      ),
    );
  }
}

// ── 3단계: 완료 ───────────────────────────────────────────────────────────────

class _CompleteView extends StatelessWidget {
  const _CompleteView({super.key, required this.state});
  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final dateStr = s._pickupDate == null
        ? '-'
        : '${s._pickupDate!.year}/${s._pickupDate!.month.toString().padLeft(2, '0')}/${s._pickupDate!.day.toString().padLeft(2, '0')}';

    return Container(
      color: const Color(0xFFFFF9F6),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
              child: Column(
                children: [
                  // 상자 미리보기
                  _BoxPreview(slots: s._slots, onRemove: null, size: 260),
                  const SizedBox(height: 32),

                  // 체크 아이콘
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A3B47),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    tr(
                      '나만의 다과 상자 (${s._box.label})\n예약 주문이 완료되었습니다.',
                      'Your ${s._box.label} Dagwa Box\norder has been placed.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 주문 요약
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEDE4E0)),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: tr('예약 성함', 'Name'),
                          value: s._nameCtrl.text,
                        ),
                        _SummaryRow(
                          label: tr('연락처', 'Phone'),
                          value: s._phoneCtrl.text,
                        ),
                        _SummaryRow(
                          label: tr('다과상자 수량', 'Qty'),
                          value: '${s._quantity}${tr('개', ' box(es)')}',
                        ),
                        _SummaryRow(
                          label: tr('희망 픽업 날짜 및 시간', 'Pickup'),
                          value: '$dateStr ${s._pickupTime ?? ''}',
                        ),
                        _SummaryRow(
                          label: tr('가격', 'Total'),
                          value: _won(s._totalPrice),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(
                      '접수 후 연락처로 안내드립니다.\n픽업 당일 매장을 방문해 주세요.',
                      'We will contact you after receiving your request.\nPlease visit the store on the pickup day.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFAA9A96),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 13,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7A3B47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        tr('홈 화면으로 돌아가기', 'Back to Home'),
                        style: const TextStyle(
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C7E7B),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight
                  ? const Color(0xFF7A3B47)
                  : const Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: highlight ? 18 : 14,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
