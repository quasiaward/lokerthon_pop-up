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
  const _BoxSize({required this.slots, required this.price, required this.label});
  final int slots;
  final int price;
  final String label;
}

const _boxSizes = [
  _BoxSize(slots: 4, price: 8000, label: '4구'),
  _BoxSize(slots: 6, price: 12000, label: '6구'),
  _BoxSize(slots: 9, price: 18000, label: '9구'),
];

// ── 다과 목록 ──────────────────────────────────────────────────────────────────

class _DagwaItem {
  const _DagwaItem({required this.name, required this.imagePath});
  final String name;
  final String imagePath;
}

const _dagwaItems = [
  _DagwaItem(name: '영양찰떡', imagePath: 'assets/figma/result_영양찰떡.png'),
  _DagwaItem(name: '도라지정과', imagePath: 'assets/figma/result_도라지정과.png'),
  _DagwaItem(name: '수원약과', imagePath: 'assets/figma/result_행궁약과.png'),
  _DagwaItem(name: '흑임자다식', imagePath: 'assets/figma/result_흑임자다식.png'),
  _DagwaItem(name: '곶감 호두말이', imagePath: 'assets/figma/result_곶감호두말이.png'),
  _DagwaItem(name: '육포다식', imagePath: 'assets/figma/result_육포다식.png'),
  _DagwaItem(name: '콩고물 도라지정과', imagePath: 'assets/figma/result_콩고물도라지정과.png'),
  _DagwaItem(name: '금귤정과', imagePath: 'assets/figma/result_금귤정과.png'),
  _DagwaItem(name: '양갱', imagePath: 'assets/figma/result_양갱.png'),
  _DagwaItem(name: '구움 견과 강정', imagePath: 'assets/figma/result_견과류.png'),
  _DagwaItem(name: '매작과', imagePath: 'assets/figma/result_매작과.png'),
  _DagwaItem(name: '깨강정', imagePath: 'assets/figma/result_깨강정.png'),
];

const _timeSlots = [
  '11:00', '12:00', '13:00', '14:00',
  '15:00', '16:00', '17:00', '18:00',
  '19:00', '20:00',
];

// ── 단계 ──────────────────────────────────────────────────────────────────────

enum _Stage { sizeSelect, select, form, complete }

// ── 메인 위젯 ─────────────────────────────────────────────────────────────────

class CateringSection extends StatefulWidget {
  const CateringSection({super.key});

  @override
  State<CateringSection> createState() => _CateringSectionState();
}

class _CateringSectionState extends State<CateringSection> {
  _Stage _stage = _Stage.sizeSelect;
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

  void _goToSizeSelect() => setState(() => _stage = _Stage.sizeSelect);
  void _goToSelect() => setState(() => _stage = _Stage.select);
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
        _showSnack(tr('전송에 실패했습니다. 다시 시도해 주세요.', 'Submission failed. Please try again.'));
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
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF7A3B47),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: switch (_stage) {
        _Stage.sizeSelect => _SizeSelectView(
            key: const ValueKey('sizeSelect'),
            state: this,
          ),
        _Stage.select => _SelectView(
            key: const ValueKey('select'),
            state: this,
          ),
        _Stage.form => _FormView(
            key: const ValueKey('form'),
            state: this,
          ),
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
  const _BoxPreview({required this.slots, required this.onRemove, this.size = 300});
  final List<_DagwaItem?> slots;
  final void Function(int)? onRemove;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cols = slots.length <= 4 ? 2 : 3;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0D5D0), width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: slots.length,
          itemBuilder: (_, i) {
            final item = slots[i];
            return GestureDetector(
              onTap: onRemove != null && item != null ? () => onRemove!(i) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: item != null
                      ? const Color(0xFFFFF5F0)
                      : const Color(0xFFF5F0ED),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE8DDD8)),
                ),
                child: item != null
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(item.imagePath, fit: BoxFit.contain),
                      )
                    : const Icon(Icons.add, color: Color(0xFFCFC4C0), size: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── 0단계: 상자 크기 선택 ────────────────────────────────────────────────────

class _SizeSelectView extends StatelessWidget {
  const _SizeSelectView({super.key, required this.state});
  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9F6),
      child: Stack(children: [
        Positioned(
          right: 0,
          top: 200,
          child: WatercolorDeco(decoClusterSoft, width: 380),
        ),
        SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
                child: Column(children: [
                  // 타이틀
                  Text(
                    tr('나만의 다과 상자 주문하기', 'Order My Own Dagwa Box'),
                    style: const TextStyle(
                      color: Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr(
                      '원하는 다과를 담아 나만의 다과상자를 구성해보세요.',
                      'Fill your box with your favourite dagwa.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF8C7E7B),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 52),

                  // 3개 상자 카드
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: List.generate(_boxSizes.length, (i) {
                      final box = _boxSizes[i];
                      final selected = state._boxSizeIndex == i;
                      return GestureDetector(
                        onTap: () => state._changeBoxSize(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 260,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF7A3B47)
                                  : const Color(0xFFE0D5D0),
                              width: selected ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: selected
                                    ? const Color(0xFF7A3B47).withValues(alpha: 0.12)
                                    : Colors.black.withValues(alpha: 0.06),
                                blurRadius: selected ? 24 : 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(children: [
                            _BoxPreview(
                              slots: List.filled(box.slots, null),
                              onRemove: null,
                              size: 180,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tr('${box.label} 다과 상자', '${box.label} Box'),
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF7A3B47)
                                    : const Color(0xFF534344),
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _won(box.price),
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF7A3B47)
                                    : const Color(0xFF8C7E7B),
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 52),

                  // 다과 담으러 가기 버튼
                  SizedBox(
                    width: 280,
                    height: 56,
                    child: FilledButton(
                      onPressed: state._goToSelect,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7A3B47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        tr('다과 담으러 가기', 'Fill My Box'),
                        style: const TextStyle(
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 64),

                  // 예약 안내 사항
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEDE4E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('예약 안내 사항', 'Ordering Guide'),
                          style: const TextStyle(
                            color: Color(0xFF534344),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...[
                          tr(
                            '주문 가능 상자  4구 (8,000원) / 6구 (12,000원) / 9구 (18,000원)',
                            'Box sizes: 4-slot (₩8,000) / 6-slot (₩12,000) / 9-slot (₩18,000)',
                          ),
                          tr(
                            '포장비  1,500원 고정',
                            'Packaging fee: ₩1,500 (fixed)',
                          ),
                          tr(
                            '같은 구수의 상자만 복수 주문 가능하며, 혼합 주문은 불가합니다.',
                            'Multiple boxes of the same size only. Mixed sizes are not available.',
                          ),
                          tr(
                            '주문 접수 후 매장에서 확인 연락을 드립니다.',
                            'We will contact you to confirm your order after receipt.',
                          ),
                          tr(
                            '픽업 당일 매장을 방문해 결제 및 수령해주세요.',
                            'Please visit the store on the pickup day to pay and collect.',
                          ),
                        ].map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                        color: Color(0xFF7A3B47),
                                        fontFamily: 'Gowun Batang',
                                        fontSize: 14,
                                      )),
                                  Expanded(
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        color: Color(0xFF6B5B5A),
                                        fontFamily: 'Gowun Batang',
                                        fontFamilyFallback: _serifFallback,
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── 1단계: 다과 선택 ──────────────────────────────────────────────────────────

class _SelectView extends StatelessWidget {
  const _SelectView({super.key, required this.state});
  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    final filled = state._slots.whereType<_DagwaItem>().length;
    final total = state._box.slots;
    final isWide = MediaQuery.sizeOf(context).width >= 860;

    return Container(
      color: const Color(0xFFFFF9F6),
      child: Stack(children: [
        Positioned(
          right: 0,
          top: 300,
          child: WatercolorDeco(decoClusterSoft, width: 420),
        ),
        SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
                child: Column(children: [
                  // 뒤로 가기
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: state._goToSizeSelect,
                      icon: const Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF8C7E7B)),
                      label: Text(
                        tr('상자 크기 다시 선택', 'Change box size'),
                        style: const TextStyle(
                          color: Color(0xFF8C7E7B),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 타이틀
                  Text(
                    tr('${state._box.label} 다과 상자', '${state._box.label} Dagwa Box'),
                    style: const TextStyle(
                      color: Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('원하는 다과를 선택해 상자를 구성해보세요.',
                        'Select dagwa to compose your box.'),
                    style: const TextStyle(
                      color: Color(0xFF8C7E7B),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 상자 크기 탭
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_boxSizes.length, (i) {
                      final selected = state._boxSizeIndex == i;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => state._changeBoxSize(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF7A3B47) : Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: selected ? const Color(0xFF7A3B47) : const Color(0xFFD9CCC8),
                              ),
                            ),
                            child: Text(
                              '${_boxSizes[i].label} · ${_won(_boxSizes[i].price)}',
                              style: TextStyle(
                                color: selected ? Colors.white : const Color(0xFF6B5B5A),
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 36),

                  // 상자 미리보기
                  _BoxPreview(
                    slots: state._slots,
                    onRemove: state._removeSlot,
                    size: isWide ? 280 : 220,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr('$filled / $total 선택됨  (슬롯을 눌러 제거)',
                        '$filled / $total selected  (tap slot to remove)'),
                    style: const TextStyle(
                      color: Color(0xFFAA9A96),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 다과 그리드
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 4 : 3,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _dagwaItems.length,
                    itemBuilder: (_, i) => _DagwaCard(
                      item: _dagwaItems[i],
                      isFull: state._isFull,
                      onTap: () => state._addDagwa(_dagwaItems[i]),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 구매하러 가기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      onPressed: state._isFull ? state._goToForm : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7A3B47),
                        disabledBackgroundColor: const Color(0xFFD9CCC8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        tr('구매하러 가기', 'Proceed to Order'),
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
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _DagwaCard extends StatelessWidget {
  const _DagwaCard({required this.item, required this.isFull, required this.onTap});
  final _DagwaItem item;
  final bool isFull;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isFull ? null : onTap,
      child: Opacity(
        opacity: isFull ? 0.4 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEDE4E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                  child: Image.asset(item.imagePath, fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF534344),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 타이틀
                Center(
                  child: Text(
                    tr('${s._box.label} 다과 상자 예약하기',
                        '${s._box.label} Dagwa Box Order'),
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
                    tr('구성한 상자의 아래 날짜 및 상자 정보를 기입해주세요.',
                        'Please fill in the pickup date and order information.'),
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
                    decoration: _inputDeco(tr('성함을 입력해주세요.', 'Enter your name')),
                  ),
                ),
                const SizedBox(height: 20),
                _FormField(
                  label: tr('연락처', 'Phone'),
                  child: TextField(
                    controller: s._phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDeco(tr('연락처를 입력해주세요.', 'Enter your phone number')),
                  ),
                ),
                const SizedBox(height: 20),
                _FormField(
                  label: tr('희망 픽업 날짜', 'Pickup Date'),
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF7A3B47) : Colors.white,
                            border: Border.all(
                              color: sel ? const Color(0xFF7A3B47) : const Color(0xFFD9CCC8),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: sel ? Colors.white : const Color(0xFF6B5B5A),
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
                  child: Row(children: [
                    _CountBtn(icon: Icons.remove, onTap: () {
                      if (s._quantity > 1) s.setState(() => s._quantity--);
                    }),
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
                    _CountBtn(icon: Icons.add, onTap: () => s.setState(() => s._quantity++)),
                  ]),
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
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBAFAC), fontFamily: 'Gowun Batang'),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
    ]);
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
              child: Column(children: [
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
                  child: const Icon(Icons.check, color: Colors.white, size: 30),
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
                  child: Column(children: [
                    _SummaryRow(label: tr('예약 성함', 'Name'), value: s._nameCtrl.text),
                    _SummaryRow(label: tr('연락처', 'Phone'), value: s._phoneCtrl.text),
                    _SummaryRow(label: tr('다과상자 수량', 'Qty'), value: '${s._quantity}${tr('개', ' box(es)')}'),
                    _SummaryRow(
                      label: tr('희망 픽업 날짜 및 시간', 'Pickup'),
                      value: '$dateStr ${s._pickupTime ?? ''}',
                    ),
                    _SummaryRow(label: tr('가격', 'Total'), value: _won(s._totalPrice), highlight: true),
                  ]),
                ),
                const SizedBox(height: 16),
                Text(
                  tr(
                    '예약 확인 후 연락처로 안내드립니다.\n픽업 당일 매장을 방문해 주세요.',
                    'We will contact you after confirming.\nPlease visit the store on the pickup day.',
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
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
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
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.highlight = false});
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
              color: highlight ? const Color(0xFF7A3B47) : const Color(0xFF534344),
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
