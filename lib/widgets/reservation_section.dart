import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/place_info.dart';
import '../theme/app_colors.dart';
import 'common.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

const _programs = [
  _Program(
    title: '아름다운 우리 떡 만들기',
    description: '바람떡, 꽃산병, 사탕절편, 꼬리절편 네 가지 종류의 아름다운 떡을 만들어봅니다.',
    badge: '인기',
    image: 'assets/figma/experience_rice_cake_class.png',
    price: '₩50,000',
    color: Color(0xFF779D3B),
  ),
  _Program(
    title: '전통 다식 만들기',
    description: '전통 다식판을 사용하여 곡물 가루로 정교한 차과자를 빚어봅니다.',
    badge: '신규',
    image: 'assets/figma/experience_dasik_class.png',
    price: '₩50,000',
    color: Color(0xFFD56779),
  ),
];

class ReservationSection extends StatefulWidget {
  const ReservationSection({super.key});

  @override
  State<ReservationSection> createState() => _ReservationSectionState();
}

class _ReservationSectionState extends State<ReservationSection> {
  final _contactController = TextEditingController();
  final _memoController = TextEditingController();
  int _programIndex = 0;
  String _type = '단체';
  int _adultCount = 4;
  int _childCount = 0;
  DateTime? _date;
  String _time = '오전 10:00';
  bool _submitted = false;

  _Program get _program => _programs[_programIndex];
  int get _totalPeople => _adultCount + _childCount;

  @override
  void dispose() {
    _contactController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _selectProgram(int index) {
    setState(() {
      _programIndex = index;
      _submitted = false;
    });
  }

  void _setType(String type) {
    setState(() {
      _type = type;
      if (type == '개인') {
        _adultCount = math.max(1, _adultCount);
        _childCount = 0;
      } else {
        _adultCount = math.max(4, _adultCount);
      }
      _submitted = false;
    });
  }

  void _changeAdult(int delta) {
    setState(() {
      final min = _type == '단체' ? 4 : 1;
      _adultCount = math.max(min, _adultCount + delta);
      _submitted = false;
    });
  }

  void _changeChild(int delta) {
    setState(() {
      _childCount = math.max(0, _childCount + delta);
      _submitted = false;
    });
  }

  void _setTime(String time) {
    setState(() {
      _time = time;
      _submitted = false;
    });
  }

  void _resetSubmission() {
    setState(() => _submitted = false);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 180)),
      locale: const Locale('ko'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF934753),
            onPrimary: Colors.white,
            surface: Color(0xFFFFFEF8),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _submitted = false;
    });
  }

  void _submit() {
    if (_contactController.text.trim().isEmpty) {
      _showSnack('연락처를 입력해 주세요.', AppColors.cinnabar);
      return;
    }
    if (_date == null) {
      _showSnack('희망 체험 날짜를 선택해 주세요.', AppColors.cinnabar);
      return;
    }
    if (_type == '단체' && _totalPeople < 4) {
      _showSnack('단체 예약은 4인 이상만 가능합니다.', AppColors.cinnabar);
      return;
    }

    setState(() => _submitted = true);
    _showSnack('체험 문의가 접수되었습니다. 매장 확인 후 연락드립니다.', AppColors.jade);
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  String get _dateLabel {
    final date = _date;
    if (date == null) return '날짜를 선택해주세요.';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    return Container(
      color: const Color(0xFFFFFEF8),
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: SectionShell(
        child: Column(
          children: [
            const Text(
              '행궁다과 체험 예약',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 50,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 54),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '현재 진행되는 클래스',
                style: TextStyle(
                  color: const Color(0xFF675C4F),
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: isWide ? 32 : 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            isWide
                ? Row(
                    children: [
                      for (var i = 0; i < _programs.length; i++) ...[
                        Expanded(
                          child: _ProgramCard(
                            program: _programs[i],
                            selected: i == _programIndex,
                            onTap: () => _selectProgram(i),
                          ),
                        ),
                        if (i != _programs.length - 1)
                          const SizedBox(width: 24),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      for (var i = 0; i < _programs.length; i++) ...[
                        _ProgramCard(
                          program: _programs[i],
                          selected: i == _programIndex,
                          onTap: () => _selectProgram(i),
                        ),
                        if (i != _programs.length - 1)
                          const SizedBox(height: 20),
                      ],
                    ],
                  ),
            const SizedBox(height: 28),
            const _ReservationNotice(),
            const SizedBox(height: 28),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 8, child: _ReservationForm(state: this)),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 7,
                        child: _ReservationSummary(state: this),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _ReservationForm(state: this),
                      const SizedBox(height: 20),
                      _ReservationSummary(state: this),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.selected,
    required this.onTap,
  });

  final _Program program;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF934753) : Colors.transparent,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD2CAB3).withValues(alpha: 0.8),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 192,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(program.image, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: program.color,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            program.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gowun Batang',
                              fontFamilyFallback: _serifFallback,
                              fontSize: 14,
                            ),
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
                        program.title,
                        style: const TextStyle(
                          color: Color(0xFF1C1C18),
                          fontFamily: 'Noto Serif KR',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        program.description,
                        style: const TextStyle(
                          color: Color(0xFF534344),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text(
                            '상시 운영',
                            style: TextStyle(
                              color: Color(0xFF566341),
                              fontFamily: 'Gowun Batang',
                              fontFamilyFallback: _serifFallback,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            program.price,
                            style: const TextStyle(
                              color: Color(0xFF1C1C18),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 1.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_rounded, color: Color(0xFF76303C), size: 20),
              SizedBox(width: 12),
              Text(
                '예약 안내 사항',
                style: TextStyle(
                  color: Color(0xFF1C1C18),
                  fontFamily: 'Noto Serif KR',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 820;
              final itemWidth = wide
                  ? (constraints.maxWidth - 48) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 24,
                runSpacing: 18,
                children:
                    const [
                          _NoticeItem(
                            title: '환불 규정',
                            body:
                                '체험 48시간 전까지 100% 환불 가능합니다.\n당일 노쇼는 환불이 불가합니다.',
                          ),
                          _NoticeItem(
                            title: '준비물 안내',
                            body: '모든 재료와 앞치마가 제공됩니다.\n수업 시작 10분 전까지 도착해주세요.',
                          ),
                          _NoticeItem(
                            title: '예약 문의',
                            body: '4인 이상만 예약 가능하며,\n개인은 받고 있지 않습니다.',
                          ),
                        ]
                        .map((item) => SizedBox(width: itemWidth, child: item))
                        .toList(),
              );
            },
          ),
        ],
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
            color: Color(0xFF76303C),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 14,
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
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ReservationForm extends StatelessWidget {
  const _ReservationForm({required this.state});

  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '체험 문의',
            style: TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Noto Serif KR',
              fontFamilyFallback: _serifFallback,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          const _FieldLabel('유형'),
          const SizedBox(height: 8),
          Row(
            children: [
              _ChoiceChipButton(
                label: '개인',
                selected: state._type == '개인',
                onTap: () => state._setType('개인'),
              ),
              const SizedBox(width: 10),
              _ChoiceChipButton(
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
          const SizedBox(height: 22),
          const _FieldLabel('희망 체험 날짜'),
          const SizedBox(height: 8),
          InkWell(
            onTap: state._pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8D8C0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF934753),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state._dateLabel,
                      style: const TextStyle(
                        color: Color(0xFF534344),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const _FieldLabel('희망 시간'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final time in const ['오전 10:00', '오전 10:30', '오전 11:00'])
                _ChoiceChipButton(
                  label: time,
                  selected: state._time == time,
                  onTap: () => state._setTime(time),
                ),
            ],
          ),
          const SizedBox(height: 22),
          const _FieldLabel('연락처'),
          const SizedBox(height: 8),
          TextField(
            controller: state._contactController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\\-]')),
            ],
            decoration: const InputDecoration(hintText: '010-0000-0000'),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('요청 사항 (선택)'),
          const SizedBox(height: 8),
          TextField(
            controller: state._memoController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '알레르기, 연령대, 방문 목적 등을 알려주세요.',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state._submitted ? null : state._submit,
              icon: state._submitted
                  ? const Icon(Icons.check_rounded, size: 18)
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(state._submitted ? '접수 완료' : '체험 문의 접수'),
              style: ElevatedButton.styleFrom(
                backgroundColor: state._submitted
                    ? AppColors.jade
                    : const Color(0xFF934753),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationSummary extends StatelessWidget {
  const _ReservationSummary({required this.state});

  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFFFFCF7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '체험 문의 확인',
            style: TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Noto Serif KR',
              fontFamilyFallback: _serifFallback,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          _SummaryRow(label: '클래스', value: state._program.title),
          _SummaryRow(
            label: '인원 수',
            value:
                '${state._type}, 성인 ${state._adultCount}명${state._childCount > 0 ? ', 어린이 ${state._childCount}명' : ''}',
          ),
          _SummaryRow(
            label: '희망 날짜 및 시간',
            value: '${state._dateLabel}, ${state._time}',
          ),
          const _SummaryRow(label: '체험 구성', value: '떡·다식 만들기'),
          const _SummaryRow(label: '비용', value: '50,000원 (상담을 통해 변경될 수 있습니다.)'),
          _SummaryRow(
            label: '연락처',
            value: state._contactController.text.trim().isEmpty
                ? '010-0000-0000'
                : state._contactController.text.trim(),
          ),
          const SizedBox(height: 22),
          Text(
            state._submitted
                ? '매장에서 일정 및 인원 수 확인 후 카카오톡을 통해 안내가 전송됩니다.'
                : '입력한 내용을 확인한 뒤 문의를 접수해 주세요. 전화 문의: $placePhone',
            style: const TextStyle(
              color: Color(0xFF6F625B),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state._resetSubmission,
                  child: const Text('문의 변경 및 취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: state._submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF934753),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ],
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8D8C0)),
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
          Container(width: 1, height: 54, color: const Color(0xFFE8D8C0)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$label  $value명',
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 10),
            Column(
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
        width: 24,
        height: 24,
        child: Icon(icon, color: const Color(0xFF934753), size: 22),
      ),
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF934753) : const Color(0xFFF0EEE8),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
        color: Color(0xFF76303C),
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8D8C0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Program {
  const _Program({
    required this.title,
    required this.description,
    required this.badge,
    required this.image,
    required this.price,
    required this.color,
  });

  final String title;
  final String description;
  final String badge;
  final String image;
  final String price;
  final Color color;
}
