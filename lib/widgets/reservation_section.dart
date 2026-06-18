import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../l10n/lang.dart';
import 'common.dart';
import 'watercolor_deco.dart';

const _apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

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
    titleEn: 'Making Beautiful Korean Rice Cakes',
    shortTitle: '떡 만들기',
    shortTitleEn: 'Rice cake making',
    description: '바람떡, 꽃산병, 사탕절편, 꼬리절편 네가지 종류의\n아름다운 떡을 만들어봅니다.',
    descriptionEn:
        'Shape baramtteok, kkotsanbyeong, and jeolpyeon rice cakes by hand.',
    detail: '약 1시간 30분 동안 색과 모양을 고르며 전통 떡을 완성합니다.',
    detailEn:
        'Over about 90 minutes you choose colors and shapes to complete traditional rice cakes.',
    badge: '인기',
    badgeEn: 'Popular',
    image: 'assets/figma/experience_rice_cake_class.png',
    heroImage: 'assets/figma/experience_rice_hero_figma.png',
    color: Color(0xFF779D3B),
  ),
  _Program(
    title: '전통 다식 만들기',
    titleEn: 'Making Traditional Dasik',
    shortTitle: '다식 만들기',
    shortTitleEn: 'Dasik making',
    description: '전통 다식판을 사용하여\n곡물 가루로 정교한 차과자를 빚어봅니다.',
    descriptionEn:
        'Use a dasik mold to press tea sweets from black sesame and grain flours.',
    detail: '차와 함께 어울리는 전통 다식을 구성하고 포장까지 경험합니다.',
    detailEn:
        'Compose traditional dasik to pair with tea, and even box them to take home.',
    badge: '신규',
    badgeEn: 'New',
    image: 'assets/figma/experience_dasik_class.png',
    heroImage: 'assets/figma/experience_dasik_highres.png',
    color: Color(0xFFD56779),
  ),
];

enum _ReservationStage { select, detail, confirm, complete }

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
  bool _isSubmitting = false;
  bool _showCalendar = false;
  int _adultCount = 4;
  int _childCount = 0;
  DateTime? _date;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _time = '11:30';

  _Program get _program => _programs[_programIndex];
  int get _totalPeople => math.max(1, _adultCount + _childCount);
  bool get _hasMinimumPeople => _totalPeople >= 4;
  String get _feeLabel => tr(
    '${_formatWon(_unitPrice * _totalPeople)}원',
    '${_formatWon(_unitPrice * _totalPeople)} KRW',
  );

  String get _dateLabel {
    final date = _date;
    if (date == null) return tr('날짜를 선택해주세요.', 'Please select a date.');
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String get _summaryDateTime {
    final date = _date == null ? tr('날짜 미선택', 'No date') : _dateLabel;
    return '$date, $_time';
  }

  String get _peopleLabel => tr(
    '성인 $_adultCount명${_childCount > 0 ? ' / 어린이 $_childCount명' : ''}',
    '$_adultCount adults${_childCount > 0 ? ' / $_childCount children' : ''}',
  );

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
    _scrollStageToTop();
  }

  void _changeAdult(int delta) {
    setState(() {
      _adultCount = math.max(1, _adultCount + delta);
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
    _scrollStageToTop();
  }

  void _toggleCalendar() {
    setState(() {
      final base = _date ?? _calendarMonth;
      _calendarMonth = DateTime(base.year, base.month);
      _showCalendar = !_showCalendar;
    });
  }

  void _changeCalendarMonth(int delta) {
    setState(() {
      _calendarMonth = DateTime(
        _calendarMonth.year,
        _calendarMonth.month + delta,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _date = date;
      _showCalendar = false;
    });
  }

  void _submit() {
    if (!_hasMinimumPeople) {
      _showSnack(
        tr(
          '행궁다과의 체험은 4명 이상부터 예약이 가능합니다.',
          'Experience reservations are available for groups of 4 or more.',
        ),
      );
      return;
    }
    if (_contactController.text.trim().isEmpty) {
      _showSnack(tr('연락처를 입력해 주세요.', 'Please enter your contact.'));
      return;
    }
    if (_date == null) {
      _showSnack(
        tr('희망 체험 날짜를 선택해 주세요.', 'Please choose your preferred date.'),
      );
      return;
    }
    setState(() => _stage = _ReservationStage.confirm);
    _scrollStageToTop();
  }

  Future<void> _complete() async {
    setState(() => _isSubmitting = true);
    try {
      final res = await http.post(
        Uri.parse('$_apiBase/email/experience'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': _program.title,
          'phone': _contactController.text.trim(),
          'adults': _adultCount,
          'children': _childCount,
          'date': _dateLabel,
          'time': _time,
          'total_price': _unitPrice * _totalPeople,
        }),
      );
      if (res.statusCode == 200) {
        setState(() {
          _stage = _ReservationStage.complete;
          _hasProgramSelection = true;
        });
        _scrollStageToTop();
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

  void _goHome() {
    Navigator.pushReplacementNamed(context, '/');
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
              _ReservationStage.complete => _ReservationCompleteView(
                key: const ValueKey('complete'),
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
      height: isWide ? 288 : 250,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            program.heroImage,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.50),
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
                      tr(program.title, program.titleEn),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: isWide ? 50 : 32,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr(
                        '${program.title} 체험은 약 1시간 30분 정도 소요되며, 간단하게 만들 수 있는 체험입니다.',
                        '${program.titleEn} takes about 90 minutes and is easy to enjoy.',
                      ),
                      style: TextStyle(
                        color: const Color(0xFFECE7E0),
                        fontFamily: 'Pretendard',
                        fontFamilyFallback: _serifFallback,
                        fontSize: isWide ? 20 : 15,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
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
            maxWidth: 1324,
            child: Column(
              children: [
                Text(
                  tr('행궁다과 원데이 클래스', 'Haenggung Dagwa One-Day Class'),
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
                    tr('현재 진행되는 클래스', 'Current classes'),
                    style: TextStyle(
                      color: const Color(0xFF675C4F),
                      fontFamily: 'Noto Serif KR',
                      fontFamilyFallback: _serifFallback,
                      fontSize: isWide ? 24 : 25,
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
                        Image.asset(
                          widget.program.image,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
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
                              tr(widget.program.badge, widget.program.badgeEn),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(widget.program.title, widget.program.titleEn),
                          style: const TextStyle(
                            color: Color(0xFF1C1C18),
                            fontFamily: 'Noto Serif KR',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 32 / 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr(
                            widget.program.description,
                            widget.program.descriptionEn,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF534344),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 16,
                            height: 24 / 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              tr('상시 운영', 'Always open'),
                              style: const TextStyle(
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
                              tr(
                                '1인 ${_formatWon(_unitPrice)}₩',
                                '${_formatWon(_unitPrice)} KRW / person',
                              ),
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
              Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: Color(0xFF9B4A59),
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tr('예약 안내 사항', 'Booking information'),
                    style: const TextStyle(
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
                children: [
                  _NoticeItem(
                    title: tr('환불 규정', 'Refund policy'),
                    body: tr(
                      '체험 48시간 전까지 100% 환불 가능합니다. 당일 노쇼는 환불이 불가합니다.',
                      'Full refunds up to 48 hours before the class. Same-day no-shows are non-refundable.',
                    ),
                  ),
                  _NoticeItem(
                    title: tr('준비물 안내', 'What to bring'),
                    body: tr(
                      '모든 재료와 앞치마가 제공됩니다. 수업 시작 10분 전까지 도착해주세요.',
                      'All ingredients and aprons are provided. Please arrive 10 minutes before the class.',
                    ),
                  ),
                  _NoticeItem(
                    title: tr('예약 문의', 'Reservations'),
                    body: tr(
                      '4인 이상만 예약 가능하며, 개인은 받고 있지 않습니다.',
                      'Reservations are for groups of 4 or more; individual bookings are not accepted.',
                    ),
                  ),
                ].map((item) => SizedBox(width: itemWidth, child: item)).toList(),
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
    final canSubmit = state._hasMinimumPeople && !state._isSubmitting;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          right: 0,
          bottom: 16 * deco,
          child: WatercolorDeco(decoCluster, width: 706 * deco),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: SectionShell(
            maxWidth: 1163,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isWide ? 26 : 18,
                isWide ? 18 : 20,
                isWide ? 47 : 18,
                isWide ? 44 : 24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 7,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('체험 문의', 'Experience inquiry'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 30 / 25,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 88,
                    child: FilledButton(
                      onPressed: canSubmit ? state._submit : null,
                      style: FilledButton.styleFrom(
                        disabledBackgroundColor: const Color(0xFFD7D1D1),
                        backgroundColor: const Color(0xFF934753),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        tr('체험 문의 접수하기', 'Submit inquiry'),
                        style: const TextStyle(
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 20 / 24,
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
        _FieldLabel(tr('인원 수', 'Party size')),
        const SizedBox(height: 14),
        _PeopleBox(
          adultCount: state._adultCount,
          childCount: state._childCount,
          onAdultDown: () => state._changeAdult(-1),
          onAdultUp: () => state._changeAdult(1),
          onChildDown: () => state._changeChild(-1),
          onChildUp: () => state._changeChild(1),
        ),
        if (!state._hasMinimumPeople) ...[
          const SizedBox(height: 7),
          _MinimumPeopleNotice(
            text: tr(
              '행궁다과의 체험은 4명 이상부터 예약이 가능합니다.',
              'Experience reservations are available for groups of 4 or more.',
            ),
          ),
        ],
        const SizedBox(height: 20),
        _FieldLabel(tr('체험비', 'Fee')),
        const SizedBox(height: 12),
        _ReadOnlyField(value: state._feeLabel, alignRight: true),
        const SizedBox(height: 16),
        _FieldLabel(tr('연락처', 'Contact')),
        const SizedBox(height: 14),
        _ContactField(
          controller: state._contactController,
          hintText: tr('연락처를 입력해주세요.', 'Enter your contact number.'),
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
        _FieldLabel(tr('희망 체험 날짜', 'Preferred date')),
        const SizedBox(height: 14),
        _DateField(
          value: state._dateLabel,
          hasValue: state._date != null,
          onTap: state._toggleCalendar,
        ),
        if (state._showCalendar) ...[
          const SizedBox(height: 14),
          _InlineCalendar(
            month: state._calendarMonth,
            selectedDate: state._date,
            onMonthChanged: state._changeCalendarMonth,
            onDateSelected: state._selectDate,
          ),
        ],
        const SizedBox(height: 17),
        _FieldLabel(tr('희망 체험 시간', 'Preferred time')),
        const SizedBox(height: 12),
        _TimeGrid(selected: state._time, onSelect: state._setTime),
      ],
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
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CountControl(
              label: tr('성인', 'Adults'),
              value: adultCount,
              onDown: onAdultDown,
              onUp: onAdultUp,
            ),
          ),
          Container(width: 1, height: 55, color: const Color(0xFFC9C9C9)),
          Expanded(
            child: _CountControl(
              label: tr('어린이', 'Children'),
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

class _MinimumPeopleNotice extends StatelessWidget {
  const _MinimumPeopleNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFE06161),
          size: 22,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE06161),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.value, this.alignRight = false});

  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF534344),
          fontFamily: 'Gowun Batang',
          fontFamilyFallback: _serifFallback,
          fontSize: 23,
          fontWeight: FontWeight.w700,
          height: 20.251 / 23,
        ),
      ),
    );
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
        style: const TextStyle(
          color: Color(0xFF534344),
          fontFamily: 'Gowun Batang',
          fontFamilyFallback: _serifFallback,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFAFAFAF),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 27,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  final String value;
  final bool hasValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 80,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 38),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: hasValue ? const Color(0xFF534344) : const Color(0xFFAFAFAF),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 20.251 / 20,
          ),
        ),
      ),
    );
  }
}

class _InlineCalendar extends StatelessWidget {
  const _InlineCalendar({
    required this.month,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  final DateTime month;
  final DateTime? selectedDate;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = firstOfMonth.weekday % 7;
    final today = DateTime.now();
    final minDate = DateTime(today.year, today.month, today.day + 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E0DA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                tr(
                  '${month.year}년 ${month.month}월',
                  '${_monthName(month.month)} ${month.year}',
                ),
                style: const TextStyle(
                  color: Color(0xFF1C1C18),
                  fontFamily: 'Noto Serif KR',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _CalendarArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => onMonthChanged(-1),
              ),
              _CalendarArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => onMonthChanged(1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.92,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (final day in ['일', '월', '화', '수', '목', '금', '토'])
                Center(
                  child: Text(
                    tr(day, _weekdayEn(day)),
                    style: const TextStyle(
                      color: Color(0xFF8D8378),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              for (var i = 0; i < leading; i++) const SizedBox.shrink(),
              for (var day = 1; day <= daysInMonth; day++)
                _CalendarDay(
                  date: DateTime(month.year, month.month, day),
                  selectedDate: selectedDate,
                  minDate: minDate,
                  onTap: onDateSelected,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  static String _weekdayEn(String day) => switch (day) {
    '일' => 'Sun',
    '월' => 'Mon',
    '화' => 'Tue',
    '수' => 'Wed',
    '목' => 'Thu',
    '금' => 'Fri',
    _ => 'Sat',
  };
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, color: const Color(0xFF786E5C), size: 24),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.selectedDate,
    required this.minDate,
    required this.onTap,
  });

  final DateTime date;
  final DateTime? selectedDate;
  final DateTime minDate;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final selected =
        selectedDate != null &&
        selectedDate!.year == date.year &&
        selectedDate!.month == date.month &&
        selectedDate!.day == date.day;
    final enabled = !date.isBefore(minDate);

    return InkWell(
      onTap: enabled ? () => onTap(date) : null,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF9E5E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFE68C8C) : Colors.transparent,
          ),
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: enabled
                ? selected
                      ? const Color(0xFFD9808C)
                      : const Color(0xFF534344)
                : const Color(0xFFC7C2BD),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
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
            Text(
              tr('   명', ''),
              style: const TextStyle(
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
    ('10:00', true),
    ('10:30', true),
    ('11:00', true),
    ('11:30', true),
    ('12:00', true),
    ('12:30', true),
    ('13:00', true),
    ('13:30', true),
    ('14:00', true),
    ('14:30', true),
    ('15:00', true),
    ('15:30', true),
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
            maxWidth: 937,
            child: Container(
              constraints: const BoxConstraints(minHeight: 659),
              padding: const EdgeInsets.fromLTRB(48, 38, 48, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 7,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('체험 문의 확인', 'Confirm your inquiry'),
                    style: const TextStyle(
                      color: Color(0xFF1C1C18),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SummaryRow(
                    label: tr('인원 수', 'Party size'),
                    value: state._peopleLabel,
                  ),
                  _SummaryRow(
                    label: tr('희망 일시', 'Date/time'),
                    value: state._summaryDateTime,
                  ),
                  _SummaryRow(
                    label: tr('체험 구성', 'Class'),
                    value: tr(
                      state._program.shortTitle,
                      state._program.shortTitleEn,
                    ),
                  ),
                  _SummaryRow(
                    label: tr('비용', 'Fee'),
                    value: tr(
                      '${state._feeLabel} (상담을 통해 변경될 수 있습니다.)',
                      '${state._feeLabel} (subject to change after consultation)',
                    ),
                  ),
                  _SummaryRow(
                    label: tr('연락처', 'Contact'),
                    value: state._contactController.text.trim(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 88,
                          child: FilledButton(
                            onPressed: state._editReservation,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD7D1D1),
                              foregroundColor: const Color(0xFF534344),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              tr('뒤로가기', 'Back'),
                              style: const TextStyle(
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
                          height: 88,
                          child: FilledButton(
                            onPressed: state._isSubmitting
                                ? null
                                : state._complete,
                            style: FilledButton.styleFrom(
                              disabledBackgroundColor: const Color(0xFFD7D1D1),
                              backgroundColor: const Color(0xFF934753),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: state._isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    tr('확인', 'Confirm'),
                                    style: const TextStyle(
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
                  Text(
                    tr(
                      '매장에서 일정 및 인원 수 확인 후 카카오톡을 통해 안내가 전송됩니다.',
                      'After the shop confirms the schedule and party size, details will be sent via KakaoTalk.',
                    ),
                    style: const TextStyle(
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

class _ReservationCompleteView extends StatelessWidget {
  const _ReservationCompleteView({super.key, required this.state});

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
            maxWidth: 937,
            child: Container(
              constraints: const BoxConstraints(minHeight: 659),
              padding: const EdgeInsets.fromLTRB(48, 42, 48, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 7,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF934753),
                    size: 86,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr(
                      '[${state._program.title}] 체험 예약 접수가 완료되었습니다.',
                      '[${state._program.titleEn}] inquiry has been received.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF534344),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    tr(
                      '매장에서 일정 및 인원 수 확인 후 <행궁다과> 카카오톡 채널을 통해 자세한 안내가 전송됩니다.',
                      'After the shop confirms the schedule and party size, details will be sent through the Haenggung Dagwa KakaoTalk channel.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFB5B3B3),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SummaryRow(
                    label: tr('체험 구성', 'Class'),
                    value: tr(
                      state._program.shortTitle,
                      state._program.shortTitleEn,
                    ),
                  ),
                  _SummaryRow(
                    label: tr('인원 수', 'Party size'),
                    value: state._peopleLabel,
                  ),
                  _SummaryRow(
                    label: tr('희망 일시', 'Date/time'),
                    value: state._summaryDateTime,
                  ),
                  _SummaryRow(label: tr('비용', 'Fee'), value: state._feeLabel),
                  _SummaryRow(
                    label: tr('연락처', 'Contact'),
                    value: state._contactController.text.trim(),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 88,
                    child: FilledButton(
                      onPressed: state._goHome,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF934753),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        tr('홈 화면으로 돌아가기', 'Return home'),
                        style: const TextStyle(
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 540;

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: _summaryLabelStyle),
                    const SizedBox(height: 8),
                    Text(value, style: _summaryValueStyle),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 155,
                      child: Text(label, style: _summaryLabelStyle),
                    ),
                    Expanded(child: Text(value, style: _summaryValueStyle)),
                  ],
                ),
        );
      },
    );
  }

  static const _summaryLabelStyle = TextStyle(
    color: Color(0xFF786E5C),
    fontFamily: 'Gowun Batang',
    fontFamilyFallback: _serifFallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const _summaryValueStyle = TextStyle(
    color: Color(0xFF534344),
    fontFamily: 'Gowun Batang',
    fontFamilyFallback: _serifFallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF786E5C),
        fontFamily: 'Gowun Batang',
        fontFamilyFallback: _serifFallback,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

class _Program {
  const _Program({
    required this.title,
    required this.titleEn,
    required this.shortTitle,
    required this.shortTitleEn,
    required this.description,
    required this.descriptionEn,
    required this.detail,
    required this.detailEn,
    required this.badge,
    required this.badgeEn,
    required this.image,
    required this.heroImage,
    required this.color,
  });

  final String title;
  final String titleEn;
  final String shortTitle;
  final String shortTitleEn;
  final String description;
  final String descriptionEn;
  final String detail;
  final String detailEn;
  final String badge;
  final String badgeEn;
  final String image;
  final String heroImage;
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
