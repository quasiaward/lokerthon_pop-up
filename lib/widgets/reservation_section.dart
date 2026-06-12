import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common.dart';
import 'watercolor_deco.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

const _unitPrice = 50000;

const _programs = [
  _Program(
    title: '아름다운 우리 떡 만들기',
    shortTitle: '떡 만들기',
    description: '바람떡, 꽃산병, 사탕절편, 꼬리절편을 직접 빚어보는 체험입니다.',
    detail: '약 1시간 30분 동안 색과 모양을 고르며 전통 떡을 완성합니다.',
    badge: '인기',
    image: 'assets/figma/experience_rice_cake_class.png',
    color: Color(0xFF779D3B),
  ),
  _Program(
    title: '전통 다식 만들기',
    shortTitle: '다식 만들기',
    description: '다식판을 사용해 흑임자와 곡물 가루로 차과자를 빚어봅니다.',
    detail: '차와 함께 어울리는 전통 다식을 구성하고 포장까지 경험합니다.',
    badge: '신규',
    image: 'assets/figma/experience_dasik_class.png',
    color: Color(0xFFD56779),
  ),
];

enum _ReservationStage { select, detail, confirm }

class ReservationSection extends StatefulWidget {
  const ReservationSection({super.key});

  @override
  State<ReservationSection> createState() => _ReservationSectionState();
}

class _ReservationSectionState extends State<ReservationSection> {
  final _contactController = TextEditingController();

  _ReservationStage _stage = _ReservationStage.select;
  int _programIndex = 0;
  bool _hasProgramSelection = false;
  String _type = '개인';
  int _adultCount = 4;
  int _childCount = 0;
  DateTime? _date;
  String _time = '11:30';

  _Program get _program => _programs[_programIndex];
  int get _totalPeople => math.max(1, _adultCount + _childCount);
  String get _feeLabel => '${_formatWon(_unitPrice * _totalPeople)}원';

  String get _dateLabel {
    final date = _date;
    if (date == null) return '날짜를 선택해주세요.';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String get _summaryDateTime {
    final date = _dateLabel == '날짜를 선택해주세요.' ? '날짜 미선택' : _dateLabel;
    return '$date, $_time';
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _selectProgram(int index) {
    _openProgram(index);
  }

  void _openProgram(int index) {
    setState(() {
      _programIndex = index;
      _hasProgramSelection = true;
      _stage = _ReservationStage.detail;
    });
  }

  void _setType(String type) {
    setState(() {
      _type = type;
      if (type == '개인') {
        _childCount = 0;
        _adultCount = math.max(1, _adultCount);
      } else {
        _adultCount = math.max(4, _adultCount);
      }
    });
  }

  void _changeAdult(int delta) {
    setState(() {
      final min = _type == '단체' ? 4 : 1;
      _adultCount = math.max(min, _adultCount + delta);
    });
  }

  void _changeChild(int delta) {
    setState(() => _childCount = math.max(0, _childCount + delta));
  }

  void _setTime(String time) {
    setState(() => _time = time);
  }

  void _editReservation() {
    setState(() => _stage = _ReservationStage.detail);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 180)),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF9B4A59),
            onPrimary: Colors.white,
            surface: Color(0xFFFFFEF8),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _submit() {
    if (_contactController.text.trim().isEmpty) {
      _showSnack('연락처를 입력해 주세요.');
      return;
    }
    if (_date == null) {
      _showSnack('희망 체험 날짜를 선택해 주세요.');
      return;
    }
    setState(() => _stage = _ReservationStage.confirm);
  }

  void _complete() {
    _showSnack('체험 문의가 접수되었습니다. 매장 확인 후 연락드립니다.');
    setState(() {
      _stage = _ReservationStage.select;
      _hasProgramSelection = false;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF934753),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFEF8),
      child: Column(
        children: [
          if (_stage != _ReservationStage.select)
            _ExperienceHero(program: _program),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (_stage) {
              _ReservationStage.select => _ProgramSelectView(
                key: const ValueKey('select'),
                selectedIndex: _hasProgramSelection ? _programIndex : null,
                onSelect: _selectProgram,
                onOpen: _openProgram,
              ),
              _ReservationStage.detail => _ReservationDetailView(
                key: const ValueKey('detail'),
                state: this,
              ),
              _ReservationStage.confirm => _ReservationConfirmView(
                key: const ValueKey('confirm'),
                state: this,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _ExperienceHero extends StatelessWidget {
  const _ExperienceHero({required this.program});

  final _Program program;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return SizedBox(
      height: isWide ? 252 : 230,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(program.image, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
          SectionShell(
            maxWidth: 1180,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: isWide ? 18 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '<${program.title}> 체험 예약',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: isWide ? 42 : 30,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${program.detail} 간단하게 만들 수 있는 체험입니다.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: isWide ? 19 : 15,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramSelectView extends StatelessWidget {
  const _ProgramSelectView({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onOpen,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final deco = decoScaleOf(context, designWidth: 1409);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          right: 0,
          bottom: 3 * deco,
          child: WatercolorDeco(decoCluster, width: 706 * deco),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            isWide ? 100 : 58,
            0,
            isWide ? 96 : 64,
          ),
          child: SectionShell(
            child: Column(
              children: [
                Text(
                  '행궁다과 체험 예약',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF534344),
                    fontFamily: 'Gowun Batang',
                    fontFamilyFallback: _serifFallback,
                    fontSize: isWide ? 50 : 36,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '현재 진행되는 클래스',
                    style: TextStyle(
                      color: const Color(0xFF675C4F),
                      fontFamily: 'Noto Serif KR',
                      fontFamilyFallback: _serifFallback,
                      fontSize: isWide ? 32 : 25,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (isWide)
                  Row(
                    children: [
                      for (
                        var index = 0;
                        index < _programs.length;
                        index++
                      ) ...[
                        Expanded(
                          child: _ProgramCard(
                            program: _programs[index],
                            selected: selectedIndex == index,
                            onTap: () => onSelect(index),
                            onDoubleTap: () => onOpen(index),
                          ),
                        ),
                        if (index != _programs.length - 1)
                          const SizedBox(width: 26),
                      ],
                    ],
                  )
                else
                  Column(
                    children: [
                      for (
                        var index = 0;
                        index < _programs.length;
                        index++
                      ) ...[
                        _ProgramCard(
                          program: _programs[index],
                          selected: selectedIndex == index,
                          onTap: () => onSelect(index),
                          onDoubleTap: () => onOpen(index),
                        ),
                        if (index != _programs.length - 1)
                          const SizedBox(height: 20),
                      ],
                    ],
                  ),
                const SizedBox(height: 28),
                const _ReservationNotice(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatefulWidget {
  const _ProgramCard({
    required this.program,
    required this.selected,
    required this.onTap,
    required this.onDoubleTap,
  });

  final _Program program;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  State<_ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<_ProgramCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        child: AnimatedScale(
          scale: active ? 1.018 : 1,
          duration: const Duration(milliseconds: 160),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: widget.selected ? const Color(0xFFFFF8F8) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.selected
                    ? const Color(0xFF995959)
                    : _hovered
                    ? const Color(0xFFE6C7C9)
                    : Colors.transparent,
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (active
                              ? const Color(0xFFD2A7A7)
                              : const Color(0xFFD2CAB3))
                          .withValues(alpha: active ? 0.34 : 0.80),
                  blurRadius: active ? 22 : 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 192,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(widget.program.image, fit: BoxFit.cover),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.program.color,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              widget.program.badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ),
                        if (widget.selected)
                          const Positioned(
                            top: 15,
                            right: 15,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF9B4A59),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.program.title,
                          style: const TextStyle(
                            color: Color(0xFF1C1C18),
                            fontFamily: 'Noto Serif KR',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 32 / 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.program.description,
                          style: const TextStyle(
                            color: Color(0xFF665C58),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 16,
                            height: 24 / 16,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Text(
                              '상시 운영',
                              style: TextStyle(
                                color: Color(0xFF566341),
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 20 / 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_formatWon(_unitPrice)}원',
                              style: const TextStyle(
                                color: Color(0xFF1C1C18),
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 20 / 14,
                              ),
                            ),
                          ],
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

class _ReservationNotice extends StatelessWidget {
  const _ReservationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEE8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 3),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final itemWidth = wide
              ? (constraints.maxWidth - 48) / 3
              : constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_rounded, color: Color(0xFF9B4A59), size: 21),
                  SizedBox(width: 10),
                  Text(
                    '예약 안내 사항',
                    style: TextStyle(
                      color: Color(0xFF1C1C18),
                      fontFamily: 'Noto Serif KR',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      height: 32 / 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 24,
                runSpacing: 18,
                children:
                    const [
                          _NoticeItem(
                            title: '환불 규정',
                            body:
                                '체험 48시간 전까지 100% 환불 가능합니다. 당일 노쇼는 환불이 불가합니다.',
                          ),
                          _NoticeItem(
                            title: '준비물 안내',
                            body: '모든 재료와 앞치마가 제공됩니다. 수업 시작 10분 전까지 도착해주세요.',
                          ),
                          _NoticeItem(
                            title: '예약 문의',
                            body: '4인 이상만 예약 가능하며, 개인은 받고 있지 않습니다.',
                          ),
                        ]
                        .map((item) => SizedBox(width: itemWidth, child: item))
                        .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NoticeItem extends StatelessWidget {
  const _NoticeItem({required this.title, required this.body});

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
            color: Color(0xFF9B4A59),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            color: Color(0xFF534344),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 16,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }
}

class _ReservationDetailView extends StatelessWidget {
  const _ReservationDetailView({super.key, required this.state});

  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final deco = decoScaleOf(context, designWidth: 1409);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          right: 0,
          bottom: 16 * deco,
          child: WatercolorDeco(decoCluster, width: 706 * deco),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 46),
          child: SectionShell(
            maxWidth: 1040,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isWide ? 26 : 18,
                isWide ? 26 : 20,
                isWide ? 26 : 18,
                isWide ? 34 : 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    spreadRadius: -4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '체험 문의',
                    style: TextStyle(
                      color: Color(0xFF1C1C18),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _ReservationLeftForm(state: state)),
                        const SizedBox(width: 40),
                        Expanded(child: _ReservationRightForm(state: state)),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ReservationLeftForm(state: state),
                        const SizedBox(height: 26),
                        _ReservationRightForm(state: state),
                      ],
                    ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: FilledButton(
                      onPressed: state._submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF9B4A59),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '체험 문의 접수하기',
                        style: TextStyle(
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReservationLeftForm extends StatelessWidget {
  const _ReservationLeftForm({required this.state});

  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('유형'),
        const SizedBox(height: 8),
        Row(
          children: [
            _TypeChip(
              label: '개인',
              selected: state._type == '개인',
              onTap: () => state._setType('개인'),
            ),
            const SizedBox(width: 10),
            _TypeChip(
              label: '단체',
              selected: state._type == '단체',
              onTap: () => state._setType('단체'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _FieldLabel('인원 수'),
        const SizedBox(height: 8),
        _PeopleBox(
          adultCount: state._adultCount,
          childCount: state._childCount,
          onAdultDown: () => state._changeAdult(-1),
          onAdultUp: () => state._changeAdult(1),
          onChildDown: () => state._changeChild(-1),
          onChildUp: () => state._changeChild(1),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const _FieldLabel('체험비'),
            const Spacer(),
            Text(
              state._feeLabel,
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _FieldLabel('연락처'),
        const SizedBox(height: 8),
        TextField(
          controller: state._contactController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
          ],
          style: const TextStyle(
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 19,
          ),
          decoration: const InputDecoration(hintText: '연락처를 입력해주세요.'),
        ),
      ],
    );
  }
}

class _ReservationRightForm extends StatelessWidget {
  const _ReservationRightForm({required this.state});

  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('희망 체험 날짜'),
        const SizedBox(height: 8),
        InkWell(
          onTap: state._pickDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 76,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              state._dateLabel,
              style: TextStyle(
                color: state._date == null
                    ? const Color(0xFFB5B3B3)
                    : const Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const _FieldLabel('희망 체험 시간'),
        const SizedBox(height: 12),
        _TimeGrid(selected: state._time, onSelect: state._setTime),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFC3C4) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFC8C8C8)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1C1C18),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PeopleBox extends StatelessWidget {
  const _PeopleBox({
    required this.adultCount,
    required this.childCount,
    required this.onAdultDown,
    required this.onAdultUp,
    required this.onChildDown,
    required this.onChildUp,
  });

  final int adultCount;
  final int childCount;
  final VoidCallback onAdultDown;
  final VoidCallback onAdultUp;
  final VoidCallback onChildDown;
  final VoidCallback onChildUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CountControl(
              label: '성인',
              value: adultCount,
              onDown: onAdultDown,
              onUp: onAdultUp,
            ),
          ),
          Container(width: 1, height: 56, color: const Color(0xFFD7D7D7)),
          Expanded(
            child: _CountControl(
              label: '어린이',
              value: childCount,
              onDown: onChildDown,
              onUp: onChildUp,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountControl extends StatelessWidget {
  const _CountControl({
    required this.label,
    required this.value,
    required this.onDown,
    required this.onUp,
  });

  final String label;
  final int value;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            Text(
              '$label   ',
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFFFF3E47),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              '   명',
              style: TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TinyIconButton(
                  icon: Icons.keyboard_arrow_up_rounded,
                  onTap: onUp,
                ),
                _TinyIconButton(
                  icon: Icons.keyboard_arrow_down_rounded,
                  onTap: onDown,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  const _TinyIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 26,
        height: 24,
        child: Icon(icon, color: const Color(0xFFC5C5C5), size: 28),
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  static const _slots = [
    ('10:00', false),
    ('10:30', false),
    ('11:00', true),
    ('11:30', true),
    ('12:00', true),
    ('12:30', true),
    ('13:00', false),
    ('13:30', false),
    ('14:00', false),
    ('14:30', false),
    ('15:00', false),
    ('15:30', false),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = (width - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final slot in _slots)
              SizedBox(
                width: itemWidth,
                child: _TimeSlot(
                  label: slot.$1,
                  enabled: slot.$2,
                  selected: selected == slot.$1,
                  onTap: () => onSelect(slot.$1),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TimeSlot extends StatefulWidget {
  const _TimeSlot({
    required this.label,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<_TimeSlot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.enabled;
    final active = widget.selected && interactive;
    final bg = !interactive
        ? const Color(0xFFE9E9E9)
        : active
        ? const Color(0xFFFDEAEA)
        : _hovered
        ? const Color(0xFFF7E8E8)
        : const Color(0xFFF4E7E7);
    final borderColor = active || _hovered
        ? const Color(0xFFF17D83)
        : Colors.transparent;
    final textColor = !interactive
        ? const Color(0xFFCFCFCF)
        : active
        ? const Color(0xFFF17D83)
        : const Color(0xFFA0A0A0);

    return MouseRegion(
      cursor: interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = interactive),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: interactive ? widget.onTap : null,
        child: AnimatedScale(
          scale: _hovered || active ? 1.02 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReservationConfirmView extends StatelessWidget {
  const _ReservationConfirmView({super.key, required this.state});

  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    final deco = decoScaleOf(context, designWidth: 1409);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          right: 0,
          bottom: 16 * deco,
          child: WatercolorDeco(decoCluster, width: 706 * deco),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: SectionShell(
            maxWidth: 920,
            child: Container(
              padding: const EdgeInsets.fromLTRB(52, 40, 52, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    spreadRadius: -4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '체험 문의 확인',
                    style: TextStyle(
                      color: Color(0xFF1C1C18),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SummaryRow(
                    label: '인원 수',
                    value:
                        '${state._type}, 성인 ${state._adultCount}명${state._childCount > 0 ? ', 어린이 ${state._childCount}명' : ''}',
                  ),
                  _SummaryRow(
                    label: '희망 날짜 및 시간',
                    value: state._summaryDateTime,
                  ),
                  _SummaryRow(label: '체험 구성', value: state._program.shortTitle),
                  _SummaryRow(
                    label: '비용',
                    value: '${state._feeLabel} (상담을 통해 변경될 수 있습니다.)',
                  ),
                  _SummaryRow(
                    label: '연락처',
                    value: state._contactController.text.trim(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 70,
                          child: FilledButton(
                            onPressed: state._editReservation,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F0F0),
                              foregroundColor: const Color(0xFF534344),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '문의 변경 및 취소',
                              style: TextStyle(
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: SizedBox(
                          height: 70,
                          child: FilledButton(
                            onPressed: state._complete,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF9B4A59),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '확인',
                              style: TextStyle(
                                fontFamily: 'Gowun Batang',
                                fontFamilyFallback: _serifFallback,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '매장에서 일정 및 인원 수 확인 후 카카오톡을 통해 안내가 전송됩니다.',
                    style: TextStyle(
                      color: Color(0xFFB5B3B3),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A6B63),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1C1C18),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6E6258),
        fontFamily: 'Gowun Batang',
        fontFamilyFallback: _serifFallback,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Program {
  const _Program({
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.detail,
    required this.badge,
    required this.image,
    required this.color,
  });

  final String title;
  final String shortTitle;
  final String description;
  final String detail;
  final String badge;
  final String image;
  final Color color;
}

String _formatWon(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
