import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/place_info.dart';
import '../theme/app_colors.dart';
import 'common.dart';

const _experienceTypes = ['개인', '소규모', '단체'];

// ── State ───────────────────────────────────────────
class ReservationSection extends StatefulWidget {
  const ReservationSection({super.key});

  @override
  State<ReservationSection> createState() => _ReservationSectionState();
}

class _ReservationSectionState extends State<ReservationSection> {
  String _experienceType = '개인';
  DateTime? _date;
  String _time = '오후 1시';
  int _people = 1;
  final _contactController = TextEditingController();
  final _requestController = TextEditingController();
  bool _submitted = false;

  bool get _needsPeopleSelection => _experienceType != '개인';

  int get _minPeople => _experienceType == '소규모' ? 2 : 10;

  int get _maxPeople => _experienceType == '소규모' ? 10 : 50;

  String get _peopleGuide {
    if (_experienceType == '개인') return '1인';
    if (_experienceType == '소규모') return '2~10인';
    return '10인 이상';
  }

  @override
  void dispose() {
    _contactController.dispose();
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 3)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 180)),
      locale: const Locale('ko'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.cinnabar,
            onPrimary: AppColors.paper,
            surface: AppColors.paper,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _incrementPeople() {
    final max = _maxPeople;
    setState(() => _people = math.min(max, _people + 1));
  }

  void _decrementPeople() {
    final min = _minPeople;
    setState(() => _people = math.max(min, _people - 1));
  }

  void _setTime(String v) => setState(() => _time = v);

  void _selectExperienceType(String type) {
    setState(() {
      _experienceType = type;
      if (type == '개인') {
        _people = 1;
      } else if (type == '소규모') {
        _people = _people.clamp(2, 10);
      } else {
        _people = math.max(10, _people);
      }
    });
  }

  void _submit() {
    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('연락처를 입력해 주세요.'),
          backgroundColor: AppColors.cinnabar,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('체험 문의가 접수되었습니다. 매장 확인 후 연락드립니다.'),
        backgroundColor: AppColors.jade,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String get _dateLabel {
    if (_date == null) return '날짜를 선택해 주세요';
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final wd = weekdays[_date!.weekday - 1];
    return '${_date!.year}년 ${_date!.month}월 ${_date!.day}일 ($wd)';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;

    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: SectionShell(
        child: Column(
          children: [
            const SectionHeading(
              eyebrow: 'Experience',
              title: '떡 만들기 체험 예약',
              description: '개인·소규모·단체 일정을 확인합니다. 희망 날짜와 연락처를 남겨 주세요.',
            ),
            const SizedBox(height: 52),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 10, child: _FormPanel(state: this)),
                      const SizedBox(width: 26),
                      Expanded(flex: 9, child: _ProgramInfoPanel(state: this)),
                    ],
                  )
                : Column(
                    children: [
                      _FormPanel(state: this),
                      const SizedBox(height: 22),
                      _ProgramInfoPanel(state: this),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// ── 왼쪽: 문의 폼 ──────────────────────────────────
class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.state});
  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.event_available_outlined,
            title: '체험 문의',
          ),
          const SizedBox(height: 26),

          // 1. 유형
          _FieldLabel('유형'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in _experienceTypes)
                _SoftChip(
                  label: type,
                  selected: state._experienceType == type,
                  onTap: () => state._selectExperienceType(type),
                ),
            ],
          ),
          const SizedBox(height: 22),

          // 2. 희망 날짜
          _FieldLabel('희망 체험 날짜'),
          const SizedBox(height: 8),
          InkWell(
            onTap: state._pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.hanji.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state._date != null ? AppColors.gold : AppColors.wheat,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: state._date != null
                        ? AppColors.cinnabar
                        : AppColors.muted.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    state._dateLabel,
                    style: TextStyle(
                      color: state._date != null
                          ? AppColors.deep
                          : AppColors.muted.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: state._date != null
                          ? FontWeight.w600
                          : FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 3. 시간대
          _FieldLabel('시간대'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in const [
                '오전 10시',
                '오전 11시',
                '오후 1시',
                '오후 2시',
                '오후 3시',
                '오후 4시',
                '오후 5시',
              ])
                _SoftChip(
                  label: t,
                  selected: state._time == t,
                  onTap: () => state._setTime(t),
                ),
            ],
          ),
          const SizedBox(height: 22),

          // 4. 인원 (개인은 숨김)
          if (state._needsPeopleSelection) ...[
            _FieldLabel('인원'),
            const SizedBox(height: 8),
            _PeopleStepper(
              value: state._people,
              min: state._minPeople,
              max: state._maxPeople,
              guide: state._peopleGuide,
              onDecrement: state._decrementPeople,
              onIncrement: state._incrementPeople,
            ),
            const SizedBox(height: 22),
          ],

          // 5. 연락처
          _FieldLabel('연락처'),
          const SizedBox(height: 8),
          TextField(
            controller: state._contactController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            ],
            decoration: const InputDecoration(
              hintText: '010-0000-0000',
              prefixIcon: Icon(
                Icons.phone_outlined,
                size: 18,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 6. 특별 요청사항 (optional)
          _FieldLabel('특별 요청사항 (선택)'),
          const SizedBox(height: 8),
          TextField(
            controller: state._requestController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '알레르기, 연령대, 행사 목적 등 미리 알려주시면 더 잘 준비합니다.',
            ),
          ),
          const SizedBox(height: 26),

          // 신청 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state._submitted ? null : state._submit,
              icon: state._submitted
                  ? const Icon(Icons.check_rounded, size: 18)
                  : const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(state._submitted ? '접수 완료' : '체험 문의 접수'),
              style: ElevatedButton.styleFrom(
                backgroundColor: state._submitted
                    ? AppColors.jade
                    : AppColors.deep,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (state._submitted) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.jade.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.jade.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.jade,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '입력하신 연락처로 매장 확인 후 연락드리겠습니다.',
                      style: TextStyle(
                        color: AppColors.jade,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 오른쪽: 체험 안내 카드 ─────────────────
class _ProgramInfoPanel extends StatelessWidget {
  const _ProgramInfoPanel({required this.state});
  final _ReservationSectionState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.deep,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.gold,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                '체험 문의 안내',
                style: TextStyle(
                  color: AppColors.paper,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
            border: Border.all(color: AppColors.wheat.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: AppColors.deep.withValues(alpha: 0.05),
                blurRadius: 24,
                spreadRadius: -2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '떡 만들기 체험',
                  style: TextStyle(
                    color: AppColors.deep,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Noto Serif KR',
                    fontFamilyFallback: ['AppleMyungjo', 'serif'],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '체험 프로그램은 하나로 고정하고, 참여 규모만 확인합니다. 희망 날짜와 연락처를 남기면 매장 일정 확인 후 안내받는 흐름입니다.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.7,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 18),
                _ExperienceInfoLine(
                  icon: Icons.group_outlined,
                  label: '선택 유형',
                  value: '${state._experienceType} · ${state._peopleGuide}',
                ),
                const _ExperienceInfoLine(
                  icon: Icons.timer_outlined,
                  label: '진행 시간',
                  value: '일정 협의',
                ),
                const _ExperienceInfoLine(
                  icon: Icons.local_florist_outlined,
                  label: '체험 구성',
                  value: '떡 만들기 중심',
                ),
                const _ExperienceInfoLine(
                  icon: Icons.payments_outlined,
                  label: '비용',
                  value: '매장 확인 후 안내',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 안내 배너
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '단체 체험과 케이터링 구성은 전화($placePhone)로 한 번 더 확인하면 가장 정확합니다.',
                  style: TextStyle(
                    color: AppColors.brown,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExperienceInfoLine extends StatelessWidget {
  const _ExperienceInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.hanji.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.cinnabar),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.brown,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.deep,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 인원 스테퍼 ─────────────────────────────────────
class _PeopleStepper extends StatelessWidget {
  const _PeopleStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.guide,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final int min;
  final int max;
  final String guide;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.hanji.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat),
      ),
      child: Row(
        children: [
          // 감소 버튼
          _StepperBtn(
            icon: Icons.remove_rounded,
            onTap: value > min ? onDecrement : null,
          ),
          // 값 표시
          Expanded(
            child: Column(
              children: [
                Text(
                  '$value명',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.deep,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  guide,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          // 증가 버튼
          _StepperBtn(
            icon: Icons.add_rounded,
            onTap: value < max ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Icon(
          icon,
          size: 22,
          color: enabled
              ? AppColors.cinnabar
              : AppColors.muted.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ── 공용 소형 위젯 ──────────────────────────────────
class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cinnabar, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.deep,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Noto Serif KR',
            fontFamilyFallback: ['AppleMyungjo', 'serif'],
          ),
        ),
      ],
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
        color: AppColors.brown,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.cinnabar : AppColors.paper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.cinnabar : AppColors.wheat,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.cinnabar.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.paper : AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
