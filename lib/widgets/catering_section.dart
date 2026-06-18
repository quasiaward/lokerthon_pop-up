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
      Offset(0.315, 0.305),
      Offset(0.685, 0.305),
      Offset(0.315, 0.670),
      Offset(0.685, 0.670),
    ],
    scales: [0.335, 0.335, 0.340, 0.340],
  ),
  _BoxConfig(
    count: 6,
    asset: 'assets/figma/catering_box_6_ver1.png',
    aspectRatio: 1402 / 1122,
    centers: [
      Offset(0.235, 0.305),
      Offset(0.500, 0.305),
      Offset(0.765, 0.305),
      Offset(0.235, 0.655),
      Offset(0.500, 0.655),
      Offset(0.765, 0.655),
    ],
    scales: [0.245, 0.245, 0.245, 0.250, 0.250, 0.250],
  ),
  _BoxConfig(
    count: 9,
    asset: 'assets/figma/catering_box_9_ver1.png',
    aspectRatio: 1,
    centers: [
      Offset(0.240, 0.245),
      Offset(0.500, 0.245),
      Offset(0.760, 0.245),
      Offset(0.240, 0.475),
      Offset(0.500, 0.475),
      Offset(0.760, 0.475),
      Offset(0.240, 0.708),
      Offset(0.500, 0.708),
      Offset(0.760, 0.708),
    ],
    scales: [0.195, 0.195, 0.195, 0.198, 0.198, 0.198, 0.200, 0.200, 0.200],
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

enum _Stage { box, select, form, complete }

// ── 메인 위젯 ─────────────────────────────────────────────────────────────────

class CateringSection extends StatefulWidget {
  const CateringSection({super.key});

  @override
  State<CateringSection> createState() => _CateringSectionState();
}

class _CateringSectionState extends State<CateringSection> {
  _Stage _stage = _Stage.box;
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
    if (_boxSizeIndex == index) return;
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

  void _decrementQuantity() {
    if (_quantity <= 1) return;
    setState(() => _quantity--);
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _setPickupTime(String time) {
    setState(() => _pickupTime = time);
  }

  void _goToBoxChoice() {
    setState(() => _stage = _Stage.box);
    _scrollStageToTop();
  }

  void _goToSelect() {
    setState(() => _stage = _Stage.select);
    _scrollStageToTop();
  }

  void _goToForm() {
    setState(() => _stage = _Stage.form);
    _scrollStageToTop();
  }

  void _backToSelect() {
    setState(() => _stage = _Stage.select);
    _scrollStageToTop();
  }

  void _scrollStageToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0,
      );
    });
  }

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
        _Stage.box => _BoxChoiceView(key: const ValueKey('box'), state: this),
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
                            padding: EdgeInsets.all(size * 0.02),
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

class _BoxChoiceView extends StatelessWidget {
  const _BoxChoiceView({super.key, required this.state});

  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1040;
    final compact = width < 720;
    final deco = decoScaleOf(context, designWidth: 1409);

    return Container(
      color: const Color(0xFFFFF9F6),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -44 * deco,
            top: 104 * deco,
            child: WatercolorDeco(decoClusterSoft, width: 470 * deco),
          ),
          Positioned(
            right: -18 * deco,
            bottom: 0,
            child: WatercolorDeco(decoBlossomYellowPage, width: 470 * deco),
          ),
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1152),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    compact ? 54 : 78,
                    24,
                    compact ? 64 : 92,
                  ),
                  child: Column(
                    children: [
                      Text(
                        tr('나만의 다과 상자 주문하기', 'Build Your Own Dagwa Box'),
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
                      const SizedBox(height: 16),
                      Text(
                        tr(
                          '취향에 맞는 다과를 담아 나만의 다과상자를 구성해보세요',
                          'Choose a box size and fill it with your favorite dagwa.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF534344),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 20,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: compact ? 34 : 58),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < _boxSizes.length; i++) ...[
                              Expanded(
                                child: _BoxChoiceCard(
                                  size: _boxSizes[i],
                                  selected: state._boxSizeIndex == i,
                                  popular: i == 1,
                                  onTap: () => state._changeBoxSize(i),
                                ),
                              ),
                              if (i != _boxSizes.length - 1)
                                const SizedBox(width: 24),
                            ],
                          ],
                        )
                      else
                        Column(
                          children: [
                            for (var i = 0; i < _boxSizes.length; i++) ...[
                              _BoxChoiceCard(
                                size: _boxSizes[i],
                                selected: state._boxSizeIndex == i,
                                popular: i == 1,
                                onTap: () => state._changeBoxSize(i),
                              ),
                              if (i != _boxSizes.length - 1)
                                const SizedBox(height: 18),
                            ],
                          ],
                        ),
                      SizedBox(height: compact ? 34 : 46),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: state._goToSelect,
                          child: Container(
                            width: compact ? double.infinity : 286,
                            height: compact ? 58 : 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF934753),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                tr('다과 담으러 가기', 'Start Filling'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Gowun Batang',
                                  fontFamilyFallback: _serifFallback,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 34 : 54),
                      const _BoxChoiceNotice(),
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

class _BoxChoiceCard extends StatefulWidget {
  const _BoxChoiceCard({
    required this.size,
    required this.selected,
    required this.popular,
    required this.onTap,
  });

  final _BoxSize size;
  final bool selected;
  final bool popular;
  final VoidCallback onTap;

  @override
  State<_BoxChoiceCard> createState() => _BoxChoiceCardState();
}

class _BoxChoiceCardState extends State<_BoxChoiceCard> {
  bool _hovered = false;

  String get _descriptionKo => switch (widget.size.slots) {
    4 => '가볍게 선물하기 좋은 소형 구성',
    6 => '가장 균형 잡힌 인기 구성',
    _ => '넉넉하게 나누기 좋은 풍성한 구성',
  };

  String get _descriptionEn => switch (widget.size.slots) {
    4 => 'A small box for a thoughtful gift',
    6 => 'A balanced and popular selection',
    _ => 'A generous box for sharing',
  };

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;
    final config = _boxConfigForSlots(widget.size.slots);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          constraints: const BoxConstraints(minHeight: 445),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFF934753)
                  : active
                  ? const Color(0xFFE0B8BC)
                  : const Color(0xFFE8DCD8),
              width: widget.selected ? 2.4 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFC89C9C,
                ).withValues(alpha: active ? 0.28 : 0.14),
                blurRadius: active ? 26 : 16,
                spreadRadius: active ? -2 : -6,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: widget.popular ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEF1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF934753)),
                    ),
                    child: Text(
                      tr('가장 인기 있는 구성', 'Most popular'),
                      style: const TextStyle(
                        color: Color(0xFF934753),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 206,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Image.asset(
                    config.asset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tr('${widget.size.label} 구성', '${widget.size.slots}-piece box'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF534344),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr(_descriptionKo, _descriptionEn),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8C7E7B),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tr(
                  '${_won(widget.size.price)}부터',
                  'From ${_won(widget.size.price).replaceAll('원', ' KRW')}',
                ),
                style: const TextStyle(
                  color: Color(0xFF934753),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoxChoiceNotice extends StatelessWidget {
  const _BoxChoiceNotice();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        tr('환불 규정', 'Refund Policy'),
        tr(
          '픽업 48시간 전까지 100% 환불 가능합니다. 당일 노쇼는 환불이 불가합니다.',
          'Full refund is available up to 48 hours before pickup. Same-day no-shows are non-refundable.',
        ),
      ),
      (
        tr('포장 비용 안내', 'Packaging Fee'),
        tr(
          '모든 다과 상자에는 포장 비용 1,500원이 추가됩니다.',
          'A 1,500 KRW packaging fee is added to every dagwa box.',
        ),
      ),
      (
        tr('예약 문의', 'Reservation Notes'),
        tr(
          '매장 상황에 따라 다과 종류 및 갯수는 변동 사항이 생길 수 있습니다.',
          'Items and quantities may vary depending on store availability.',
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEADDD9)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          final itemWidth = isWide
              ? (constraints.maxWidth - 56) / 3
              : constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('예약 안내 사항', 'Reservation Guide'),
                style: const TextStyle(
                  color: Color(0xFF534344),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 28,
                runSpacing: 18,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: itemWidth,
                      child: _BoxNoticeColumn(title: item.$1, body: item.$2),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BoxNoticeColumn extends StatelessWidget {
  const _BoxNoticeColumn({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF934753),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: Color(0xFF6B5B5A),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 15,
            height: 1.55,
          ),
        ),
      ],
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
                      OutlinedButton(
                        onPressed: state._goToBoxChoice,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF934753),
                          side: const BorderSide(color: Color(0xFF934753)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          tr('상자 크기 다시 고르기', 'Choose another box size'),
                          style: const TextStyle(
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
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

    return _OrderFormLayout(
      state: s,
      dateLabel: dateLabel,
      onPickDate: _pickDate,
    );
  }
}

class _OrderFormLayout extends StatelessWidget {
  const _OrderFormLayout({
    required this.state,
    required this.dateLabel,
    required this.onPickDate,
  });

  final _CateringSectionState state;
  final String dateLabel;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 720;
    final previewSize = compact ? 340.0 : 640.0;

    return Container(
      color: const Color(0xFFFFF9F6),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1164),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                compact ? 52 : 72,
                24,
                compact ? 64 : 92,
              ),
              child: Column(
                children: [
                  Text(
                    tr(
                      '${state._box.label} 다과 상자 예약하기',
                      '${state._box.label} Dagwa Box Reservation',
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
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      '구성된 상자의 픽업 날짜 및 상세 정보를 기입해주세요.',
                      'Enter pickup details for your custom dagwa box.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B5B5A),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 20,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: compact ? 34 : 48),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _BoxPreview(
                        slots: state._slots,
                        onRemove: null,
                        size: previewSize,
                      ),
                      Positioned(
                        right: compact ? 0 : 18,
                        bottom: compact ? -18 : -10,
                        child: OutlinedButton(
                          onPressed: state._backToSelect,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF934753),
                            backgroundColor: const Color(0xFFFFFDFB),
                            side: const BorderSide(color: Color(0xFF934753)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            tr('다과 상자 수정하기', 'Edit Box'),
                            style: const TextStyle(
                              fontFamily: 'Gowun Batang',
                              fontFamilyFallback: _serifFallback,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 48 : 66),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      compact ? 22 : 42,
                      compact ? 28 : 40,
                      compact ? 22 : 42,
                      compact ? 28 : 40,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDFB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEADDD9)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFC89C9C,
                          ).withValues(alpha: 0.12),
                          blurRadius: 24,
                          spreadRadius: -8,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('다과 상자 예약하기', 'Dagwa Box Reservation'),
                          style: TextStyle(
                            color: const Color(0xFF534344),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: compact ? 30 : 36,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          tr('예약자 정보', 'Reservation Details'),
                          style: const TextStyle(
                            color: Color(0xFF534344),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final twoColumn = constraints.maxWidth >= 860;
                            const gap = 28.0;
                            final fieldWidth = twoColumn
                                ? (constraints.maxWidth - gap) / 2
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: gap,
                              runSpacing: 24,
                              children: [
                                SizedBox(
                                  width: fieldWidth,
                                  child: _FormField(
                                    label: tr('성함', 'Name'),
                                    child: SizedBox(
                                      height: 80,
                                      child: TextField(
                                        controller: state._nameCtrl,
                                        style: const TextStyle(
                                          color: Color(0xFF534344),
                                          fontFamily: 'Gowun Batang',
                                          fontFamilyFallback: _serifFallback,
                                          fontSize: 20,
                                        ),
                                        decoration: _inputDeco(
                                          tr('성함을 입력해주세요.', 'Enter your name'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _FormField(
                                    label: tr('연락처', 'Phone'),
                                    child: SizedBox(
                                      height: 80,
                                      child: TextField(
                                        controller: state._phoneCtrl,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(
                                          color: Color(0xFF534344),
                                          fontFamily: 'Gowun Batang',
                                          fontFamilyFallback: _serifFallback,
                                          fontSize: 20,
                                        ),
                                        decoration: _inputDeco(
                                          tr(
                                            '연락처를 입력해주세요.',
                                            'Enter your phone number',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _FormField(
                                    label: tr('다과 상자 갯수', 'Quantity'),
                                    child: _QuantityBox(state: state),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _FormField(
                                    label: tr('가격', 'Price'),
                                    child: _PriceBox(total: state._totalPrice),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _FormField(
                                    label: tr('희망 픽업 날짜', 'Pickup Date'),
                                    child: _PickerBox(
                                      label: dateLabel,
                                      active: state._pickupDate != null,
                                      onTap: onPickDate,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: _FormField(
                                    label: tr('희망 픽업 시간', 'Pickup Time'),
                                    child: _TimeSlotWrap(state: state),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 34),
                        SizedBox(
                          width: double.infinity,
                          height: compact ? 70 : 88,
                          child: FilledButton(
                            onPressed: state._isSubmitting
                                ? null
                                : state._submitOrder,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF934753),
                              disabledBackgroundColor: const Color(0xFFD9CCC8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: state._isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    tr('다과 상자 예약하기', 'Reserve Dagwa Box'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gowun Batang',
                                      fontFamilyFallback: _serifFallback,
                                      fontSize: compact ? 23 : 30,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

class _PickerBox extends StatelessWidget {
  const _PickerBox({
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
        child: Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5DDD9)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? const Color(0xFF534344)
                    : const Color(0xFFAAA09D),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 20,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityBox extends StatelessWidget {
  const _QuantityBox({required this.state});

  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DDD9)),
      ),
      child: Row(
        children: [
          Text(
            '${state._quantity}${tr('개', ' box(es)')}',
            style: const TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _CountBtn(icon: Icons.remove, onTap: state._decrementQuantity),
          const SizedBox(width: 12),
          _CountBtn(icon: Icons.add, onTap: state._incrementQuantity),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DDD9)),
      ),
      child: Row(
        children: [
          Text(
            _won(total),
            style: const TextStyle(
              color: Color(0xFF934753),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            tr('포장비 1,500원 포함', 'Includes 1,500 KRW packaging'),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF9D918E),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 13,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotWrap extends StatelessWidget {
  const _TimeSlotWrap({required this.state});

  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final time in _timeSlots)
          _TimeSlotPill(
            label: time,
            selected: state._pickupTime == time,
            onTap: () => state._setPickupTime(time),
          ),
      ],
    );
  }
}

class _TimeSlotPill extends StatelessWidget {
  const _TimeSlotPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 112,
          height: 60,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF934753) : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF934753)
                  : const Color(0xFFE5DDD9),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1,
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
    color: Color(0xFFAAA09D),
    fontFamily: 'Gowun Batang',
    fontFamilyFallback: _serifFallback,
    fontSize: 20,
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
  filled: true,
  fillColor: Color(0xFFF7F7F7),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: Color(0xFFE5DDD9)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: Color(0xFFE5DDD9)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: const BorderSide(color: Color(0xFF934753), width: 1.4),
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
            color: Color(0xFF534344),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDFB),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE0CBCB)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF934753)),
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

    return _CompleteLayout(state: s, dateStr: dateStr);
  }
}

class _CompleteLayout extends StatelessWidget {
  const _CompleteLayout({required this.state, required this.dateStr});

  final _CateringSectionState state;
  final String dateStr;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 980;
    final compact = width < 720;
    final pickupLabel = '$dateStr ${state._pickupTime ?? ''}'.trim();

    return Container(
      color: const Color(0xFFFFF9F6),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                compact ? 48 : 74,
                24,
                compact ? 64 : 86,
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _CompletePreviewColumn(
                            state: state,
                            previewSize: 650,
                          ),
                        ),
                        const SizedBox(width: 46),
                        SizedBox(
                          width: 455,
                          child: _CompletePanel(
                            state: state,
                            pickupLabel: pickupLabel,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _CompletePreviewColumn(
                          state: state,
                          previewSize: compact ? 350 : 560,
                        ),
                        const SizedBox(height: 30),
                        _CompletePanel(state: state, pickupLabel: pickupLabel),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletePreviewColumn extends StatelessWidget {
  const _CompletePreviewColumn({
    required this.state,
    required this.previewSize,
  });

  final _CateringSectionState state;
  final double previewSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _BoxPreview(
            slots: state._slots,
            onRemove: null,
            size: previewSize,
          ),
        ),
        const SizedBox(height: 26),
        _CompletionNotice(
          text: tr(
            '매장에서 일정 및 다과 재고 확인 후 <행궁다과> 카카오톡 채널을 통해 자세한 안내가 전송됩니다.',
            'After the store checks schedule and stock, details will be sent through the Haenggung Dagwa KakaoTalk channel.',
          ),
        ),
        const SizedBox(height: 12),
        _CompletionNotice(
          text: tr(
            '다과의 재고 현황 및 현장 상황에 따라 다과 종류 및 갯수 추가 또는 변경이 있을 수 있습니다.',
            'Items and quantities may be adjusted depending on stock and store conditions.',
          ),
        ),
        const SizedBox(height: 12),
        _CompletionNotice(
          text: tr(
            '위 이미지는 예시 이미지이므로, 실제 다과 상자와 갯수, 모양, 크기 등이 달라질 수 있습니다.',
            'The preview is illustrative, so the actual box may differ in item count, shape, and size.',
          ),
        ),
      ],
    );
  }
}

class _CompletePanel extends StatelessWidget {
  const _CompletePanel({required this.state, required this.pickupLabel});

  final _CateringSectionState state;
  final String pickupLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 34, 30, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEADDD9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC89C9C).withValues(alpha: 0.16),
            blurRadius: 28,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFF934753),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr(
              '나만의 다과 상자 (${state._box.label}) 예약 주문이 완료되었습니다.',
              'Your custom ${state._box.label} Dagwa Box reservation is complete.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3F1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: tr('상품명', 'Product'),
                  value: tr(
                    '[나만의 다과 상자 (${state._box.label})]',
                    '[Custom Dagwa Box (${state._box.label})]',
                  ),
                ),
                _SummaryRow(
                  label: tr('예약자 성함', 'Name'),
                  value: state._nameCtrl.text,
                ),
                _SummaryRow(
                  label: tr('예약자 전화번호', 'Phone'),
                  value: state._phoneCtrl.text,
                ),
                _SummaryRow(
                  label: tr('다과상자 갯수', 'Quantity'),
                  value: '${state._quantity}${tr('개', ' box(es)')}',
                ),
                _SummaryRow(
                  label: tr('희망 픽업 날짜 및 시간', 'Pickup'),
                  value: pickupLabel,
                ),
                _SummaryRow(
                  label: tr('가격', 'Price'),
                  value: _won(state._totalPrice),
                  highlight: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _CompletionNotice(
            text: tr(
              '결제는 매장에서 주문 확인 후 진행됩니다.',
              'Payment is completed after the store confirms your order.',
            ),
            iconOnlyCheck: true,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: FilledButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF934753),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                tr('홈 화면으로 돌아가기', 'Back to Home'),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionNotice extends StatelessWidget {
  const _CompletionNotice({required this.text, this.iconOnlyCheck = false});

  final String text;
  final bool iconOnlyCheck;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(
            iconOnlyCheck ? Icons.check_rounded : Icons.info_outline_rounded,
            size: iconOnlyCheck ? 20 : 18,
            color: const Color(0xFF934753),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B5B5A),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8C7E7B),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: highlight
                    ? const Color(0xFF934753)
                    : const Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: highlight ? 18 : 14,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
