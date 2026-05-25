import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'common.dart';

// ── 진행 단계 데이터 ────────────────────────────────
class _Step {
  const _Step({required this.icon, required this.label, required this.desc});
  final IconData icon;
  final String label;
  final String desc;
}

const _processSteps = [
  _Step(
    icon: Icons.edit_note_outlined,
    label: '문의 내용 작성',
    desc: '정확한 인원, 예산, 수령 방식, 필요한 다과를 선택해 주세요.',
  ),
  _Step(
    icon: Icons.phone_in_talk_outlined,
    label: '전화 확인',
    desc: '매장 상황과 수량 가능 여부를 전화로 한 번 더 확인합니다.',
  ),
  _Step(
    icon: Icons.handshake_outlined,
    label: '구성 협의',
    desc: '다과상, 약과, 정과류, 전통차 구성을 목적에 맞게 조율합니다.',
  ),
  _Step(
    icon: Icons.storefront_outlined,
    label: '방문·픽업',
    desc: '확정한 일정에 맞춰 매장 방문 또는 픽업으로 진행합니다.',
  ),
];

// ── 패키지 예시 데이터 ──────────────────────────────
class _Package {
  const _Package({
    required this.name,
    required this.people,
    required this.price,
    required this.items,
  });
  final String name;
  final String people;
  final String price;
  final String items;
}

const _packages = [
  _Package(name: '포장 다과', people: '소량~', price: '매장 문의', items: '행궁약과·정과류'),
  _Package(
    name: '단체 방문',
    people: '4~20인',
    price: '메뉴별 결제',
    items: '다과상·전통차·빙수',
  ),
  _Package(
    name: '행사 다과상',
    people: '협의',
    price: '전화 문의',
    items: '다과상·전통차·포장 구성',
  ),
];

// ── State ───────────────────────────────────────────
class CateringSection extends StatefulWidget {
  const CateringSection({super.key});

  @override
  State<CateringSection> createState() => _CateringSectionState();
}

class _CateringSectionState extends State<CateringSection> {
  final _peopleController = TextEditingController(text: '8');
  final _memoController = TextEditingController();
  final _requestController = TextEditingController();
  int _people = 8;
  String _budget = '5만원';
  String _delivery = '픽업';
  final Set<String> _items = {'다과상', '행궁약과', '전통차'};
  bool _submitted = false;

  @override
  void dispose() {
    _peopleController.dispose();
    _memoController.dispose();
    _requestController.dispose();
    super.dispose();
  }

  void _toggleItem(String item) {
    setState(() {
      if (_items.contains(item)) {
        _items.remove(item);
      } else {
        _items.add(item);
      }
    });
  }

  void _setPeopleFromText(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    setState(() => _people = parsed.clamp(1, 300));
  }

  void _setBudget(String v) => setState(() => _budget = v);
  void _setDelivery(String v) => setState(() => _delivery = v);

  void _submit() {
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('케이터링 문의가 접수되었습니다. 매장 확인 후 연락드립니다.'),
        backgroundColor: AppColors.jade,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    return Container(
      color: AppColors.paper,
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: SectionShell(
        child: Column(
          children: [
            const SectionHeading(
              eyebrow: 'Catering',
              title: '케이터링 문의',
              description: '인원, 예산, 수령 방식만 남겨 주세요. 매장 확인 후 가능 여부를 안내합니다.',
            ),
            const SizedBox(height: 48),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 11, child: _CateringForm(state: this)),
                      const SizedBox(width: 24),
                      Expanded(flex: 10, child: _CateringGuide(state: this)),
                    ],
                  )
                : Column(
                    children: [
                      _CateringForm(state: this),
                      const SizedBox(height: 20),
                      _CateringGuide(state: this),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// ── 왼쪽: 주문서 폼 ────────────────────────────────
class _CateringForm extends StatelessWidget {
  const _CateringForm({required this.state});
  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.inventory_2_outlined,
            title: '케이터링 문의서',
          ),
          const SizedBox(height: 24),
          _PeopleCounter(
            controller: state._peopleController,
            onTextChanged: state._setPeopleFromText,
          ),
          _ChipSelector(
            label: '예산',
            options: const ['3만원', '5만원', '10만원', '15만원', '20만원 이상', '협의'],
            value: state._budget,
            onChanged: state._setBudget,
          ),
          _ChipSelector(
            label: '수령 방식',
            options: const ['매장 이용', '픽업', '협의'],
            value: state._delivery,
            onChanged: state._setDelivery,
          ),
          const Text(
            '다과 구성',
            style: TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in const [
                '다과상',
                '행궁약과',
                '진달래화전',
                '빙수',
                '정과류',
                '전통차',
              ])
                _ToggleChip(
                  label: item,
                  selected: state._items.contains(item),
                  onTap: () => state._toggleItem(item),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _CompactTextArea(
            label: '희망 일정·픽업 메모',
            hintText: '예: 6월 8일 오후 2시 픽업, 보냉 포장 필요',
            controller: state._memoController,
            minLines: 3,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _CompactTextArea(
            label: '기타 요청 사항 (선택)',
            hintText: '알레르기, 연령대, 포장 톤, 행사 목적 등을 남겨 주세요.',
            controller: state._requestController,
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state._submitted ? null : state._submit,
              icon: state._submitted
                  ? const Icon(Icons.check_rounded, size: 18)
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(state._submitted ? '접수 완료' : '케이터링 문의 접수'),
              style: ElevatedButton.styleFrom(
                backgroundColor: state._submitted
                    ? AppColors.jade
                    : AppColors.deep,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 오른쪽: 진행 안내 + 패키지 예시 ─────────────────
class _CateringGuide extends StatelessWidget {
  const _CateringGuide({required this.state});
  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 다크 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.deep,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              Icon(Icons.route_outlined, color: AppColors.gold, size: 18),
              SizedBox(width: 10),
              Text(
                '케이터링 진행 안내',
                style: TextStyle(
                  color: AppColors.paper,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        // 본문
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 진행 단계
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
                child: Column(
                  children: [
                    for (var i = 0; i < _processSteps.length; i++) ...[
                      _ProcessStep(step: _processSteps[i], index: i + 1),
                      if (i < _processSteps.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 19),
                          child: Container(
                            width: 1,
                            height: 20,
                            color: AppColors.wheat,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              Divider(
                height: 32,
                color: AppColors.wheat.withValues(alpha: 0.6),
                indent: 20,
                endIndent: 20,
              ),
              // 패키지 예시
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InquirySummary(state: state),
                    const SizedBox(height: 20),
                    const Text(
                      '패키지 예시',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final pkg in _packages) _PackageRow(pkg: pkg),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 안내 배너 or 접수 완료
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state._submitted
              ? Container(
                  key: const ValueKey('submitted'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.jade.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.jade.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.jade,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '케이터링 문의가 접수되었습니다.\n매장 확인 후 연락드리겠습니다.',
                          style: TextStyle(
                            color: AppColors.jade,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  key: const ValueKey('tip'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '예산과 일정을 남겨주시면 매장 상황에 맞춰 가능 여부를 확인합니다.',
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
        ),
      ],
    );
  }
}

// ── 진행 단계 위젯 ──────────────────────────────────
class _ProcessStep extends StatelessWidget {
  const _ProcessStep({required this.step, required this.index});
  final _Step step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 번호 원형
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cinnabar.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.cinnabar.withValues(alpha: 0.25),
            ),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: AppColors.cinnabar,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Icon(step.icon, size: 15, color: AppColors.gold),
                    Text(
                      step.label,
                      style: const TextStyle(
                        color: AppColors.deep,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  step.desc,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 패키지 행 위젯 ──────────────────────────────────
class _PackageRow extends StatelessWidget {
  const _PackageRow({required this.pkg});
  final _Package pkg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.hanji.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.name,
                  style: const TextStyle(
                    color: AppColors.deep,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pkg.items,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pkg.people,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                pkg.price,
                style: const TextStyle(
                  color: AppColors.cinnabar,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InquirySummary extends StatelessWidget {
  const _InquirySummary({required this.state});

  final _CateringSectionState state;

  @override
  Widget build(BuildContext context) {
    final selectedItems = state._items.isEmpty
        ? '선택 없음'
        : state._items.join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '문의 요약',
            style: TextStyle(
              color: AppColors.cinnabar,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryLine(label: '인원', value: '${state._people}명'),
          _SummaryLine(label: '예산', value: state._budget),
          _SummaryLine(label: '수령', value: state._delivery),
          _SummaryLine(label: '구성', value: selectedItems),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
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
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공용 위젯 ───────────────────────────────────────
class _CompactTextArea extends StatelessWidget {
  const _CompactTextArea({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.minLines,
    required this.maxLines,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.brown,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          style: const TextStyle(
            color: AppColors.deep,
            fontSize: 14,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.muted.withValues(alpha: 0.54),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cinnabar, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.deep,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Noto Serif KR',
            fontFamilyFallback: ['AppleMyungjo', 'serif'],
          ),
        ),
      ],
    );
  }
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                _SelectChip(
                  label: option,
                  selected: option == value,
                  onTap: () => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeopleCounter extends StatelessWidget {
  const _PeopleCounter({required this.controller, required this.onTextChanged});

  final TextEditingController controller;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '인원',
            style: TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.hanji.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.wheat),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_2_outlined,
                  color: AppColors.cinnabar,
                  size: 18,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 96,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: onTextChanged,
                    style: const TextStyle(
                      color: AppColors.deep,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      suffixText: '명',
                      filled: true,
                      fillColor: AppColors.paper,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '정확한 인원만 입력해 주세요.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
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
          color: selected ? AppColors.deep : AppColors.paper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.deep : AppColors.wheat,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.deep.withValues(alpha: 0.12),
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

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, color: AppColors.paper, size: 13),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.paper : AppColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
