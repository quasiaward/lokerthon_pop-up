import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'common.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

const _trayAsset = 'assets/figma/catering_figma_tray_6_display.png';
const _decoAsset = 'assets/figma/catering_figma_deco.png';

const _yakgwa = _DagwaOption(
  name: '행궁약과',
  price: '5,000',
  priceValue: 5000,
  image: 'assets/figma/catering_figma_yakgwa.png',
  trayScale: 0.23,
  cardImageSize: 228,
);

const _hwajeon = _DagwaOption(
  name: '진달래 화전',
  price: '5,000',
  priceValue: 5000,
  image: 'assets/figma/catering_figma_hwajeon.png',
  trayScale: 0.29,
  cardImageSize: 225,
);

const _songpyeon = _DagwaOption(
  name: '송편',
  price: '5,000',
  priceValue: 5000,
  image: 'assets/figma/catering_figma_songpyeon.png',
  trayScale: 0.25,
  cardImageSize: 190,
);

const _osakgyeongdan = _DagwaOption(
  name: '오색경단',
  price: '5,000',
  priceValue: 5000,
  image: 'assets/figma/catering_figma_osakgyeongdan.png',
  trayScale: 0.26,
  cardImageSize: 198,
);

const _selectorOptions = [_yakgwa, _hwajeon, _songpyeon, _osakgyeongdan];

class CateringSection extends StatefulWidget {
  const CateringSection({super.key});

  @override
  State<CateringSection> createState() => _CateringSectionState();
}

class _CateringSectionState extends State<CateringSection> {
  late final List<_DagwaOption?> _slots;
  int? _activeSlot;

  int get _filledCount => _slots.whereType<_DagwaOption>().length;
  int get _totalPrice => _slots.whereType<_DagwaOption>().fold(
    0,
    (sum, item) => sum + item.priceValue,
  );

  @override
  void initState() {
    super.initState();
    _slots = List<_DagwaOption?>.filled(6, null);
    _activeSlot = 0;
  }

  void _selectSlot(int index) {
    setState(() => _activeSlot = index);
  }

  void _addDagwa(_DagwaOption option) {
    setState(() {
      final targetIndex =
          _activeSlot ?? _slots.indexWhere((slot) => slot == null);
      final resolvedIndex = targetIndex == -1 ? 0 : targetIndex;
      _slots[resolvedIndex] = option;

      final nextEmpty = _slots.indexWhere((slot) => slot == null);
      _activeSlot = nextEmpty == -1 ? resolvedIndex : nextEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;

        return Container(
          color: const Color(0xFFFFF9F6),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (!compact)
                Positioned(
                  right: -520,
                  top: 228,
                  width: 920,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.092,
                      child: Transform.rotate(
                        angle: -14 * math.pi / 180,
                        child: Image.asset(_decoAsset, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              if (!compact)
                Positioned(
                  left: -520,
                  bottom: 124,
                  width: 920,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.034,
                      child: Transform.rotate(
                        angle: 14 * math.pi / 180,
                        child: Transform.scale(
                          scaleX: -1,
                          child: Image.asset(_decoAsset, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                ),
              SectionShell(
                maxWidth: 1040,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    compact ? 58 : 97,
                    0,
                    compact ? 72 : 96,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '6구 다과 상자',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF534344),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: compact ? 36 : 50,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '원하는 다과로 상자를 구성해주세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF534344),
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          fontSize: compact ? 16 : 18,
                          height: 1.55,
                        ),
                      ),
                      SizedBox(height: compact ? 22 : 28),
                      _CompositionStatus(
                        slots: _slots,
                        activeSlot: _activeSlot,
                        filledCount: _filledCount,
                        totalPrice: _totalPrice,
                        onSlotTap: _selectSlot,
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      const _UsageGuideCard(),
                      SizedBox(height: compact ? 24 : 32),
                      _TrayBuilder(
                        slots: _slots,
                        activeSlot: _activeSlot,
                        onSlotTap: _selectSlot,
                      ),
                      SizedBox(height: compact ? 34 : 54),
                      const _SelectorHeading(),
                      const SizedBox(height: 18),
                      _DagwaSelector(
                        options: _selectorOptions,
                        onSelected: _addDagwa,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompositionStatus extends StatelessWidget {
  const _CompositionStatus({
    required this.slots,
    required this.activeSlot,
    required this.filledCount,
    required this.totalPrice,
    required this.onSlotTap,
  });

  final List<_DagwaOption?> slots;
  final int? activeSlot;
  final int filledCount;
  final int totalPrice;
  final ValueChanged<int> onSlotTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8DCD6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB99A90).withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: -10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: compact
              ? Column(
                  children: [
                    _StatusText(
                      filledCount: filledCount,
                      totalPrice: totalPrice,
                      activeSlot: activeSlot,
                    ),
                    const SizedBox(height: 14),
                    _SlotChipRow(
                      slots: slots,
                      activeSlot: activeSlot,
                      onSlotTap: onSlotTap,
                    ),
                  ],
                )
              : Row(
                  children: [
                    _StatusText(
                      filledCount: filledCount,
                      totalPrice: totalPrice,
                      activeSlot: activeSlot,
                    ),
                    const Spacer(),
                    _SlotChipRow(
                      slots: slots,
                      activeSlot: activeSlot,
                      onSlotTap: onSlotTap,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({
    required this.filledCount,
    required this.totalPrice,
    required this.activeSlot,
  });

  final int filledCount;
  final int totalPrice;
  final int? activeSlot;

  @override
  Widget build(BuildContext context) {
    final activeLabel = activeSlot == null
        ? '구성 완료'
        : '${activeSlot! + 1}번 칸 선택';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '상자 구성',
              style: TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$filledCount / 6',
              style: const TextStyle(
                color: Color(0xFF934753),
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '${_formatWon(totalPrice)}원',
              style: const TextStyle(
                color: Color(0xFF837777),
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          activeLabel,
          style: const TextStyle(
            color: Color(0xFF9A9285),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _SlotChipRow extends StatelessWidget {
  const _SlotChipRow({
    required this.slots,
    required this.activeSlot,
    required this.onSlotTap,
  });

  final List<_DagwaOption?> slots;
  final int? activeSlot;
  final ValueChanged<int> onSlotTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < slots.length; index++)
          _SlotChip(
            index: index,
            option: slots[index],
            active: activeSlot == index,
            onTap: () => onSlotTap(index),
          ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.index,
    required this.option,
    required this.active,
    required this.onTap,
  });

  final int index;
  final _DagwaOption? option;
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
          width: 40,
          height: 40,
          padding: EdgeInsets.all(option == null ? 0 : 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF934753) : const Color(0xFFFFFCFA),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? const Color(0xFF934753) : const Color(0xFFE5D6D0),
              width: active ? 2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF934753).withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: option == null
              ? Icon(
                  Icons.add_rounded,
                  color: active ? Colors.white : const Color(0xFFB79B95),
                  size: 21,
                )
              : ClipOval(
                  child: Image.asset(option!.image, fit: BoxFit.contain),
                ),
        ),
      ),
    );
  }
}

class _UsageGuideCard extends StatelessWidget {
  const _UsageGuideCard();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    final pills = const [
      _GuidePill(icon: Icons.touch_app_outlined, label: '칸 선택'),
      _GuidePill(icon: Icons.add_circle_outline_rounded, label: '다과 담기'),
      _GuidePill(icon: Icons.refresh_rounded, label: '칸 교체'),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.66),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE9DDD8)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 20,
            compact ? 14 : 16,
            compact ? 16 : 20,
            compact ? 14 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: compact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  const _GuideTitle(),
                  SizedBox(width: compact ? 0 : 14, height: compact ? 8 : 0),
                  Flexible(
                    fit: compact ? FlexFit.loose : FlexFit.tight,
                    child: Text(
                      '상자 칸을 먼저 누르고 아래 다과 카드의 담기를 선택하세요. 이미 채운 칸을 누르면 새 다과로 교체됩니다.',
                      style: TextStyle(
                        color: const Color(0xFF8B7D7A),
                        fontFamily: 'Gowun Batang',
                        fontFamilyFallback: _serifFallback,
                        fontSize: compact ? 13 : 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: pills),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideTitle extends StatelessWidget {
  const _GuideTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome_rounded, color: Color(0xFF934753), size: 18),
        SizedBox(width: 7),
        Text(
          '상자 구성 방법',
          style: TextStyle(
            color: Color(0xFF534344),
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _GuidePill extends StatelessWidget {
  const _GuidePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECE9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5D6D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 8, 6, 8),
            child: Icon(icon, color: const Color(0xFF934753), size: 16),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 13, 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF534344),
                fontFamily: 'Gowun Batang',
                fontFamilyFallback: _serifFallback,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorHeading extends StatelessWidget {
  const _SelectorHeading();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: const Row(
        children: [
          Text(
            '다과 선택',
            style: TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(width: 14),
          Expanded(child: Divider(color: Color(0xFFE9DDD8))),
        ],
      ),
    );
  }
}

class _TrayBuilder extends StatelessWidget {
  const _TrayBuilder({
    required this.slots,
    required this.activeSlot,
    required this.onSlotTap,
  });

  final List<_DagwaOption?> slots;
  final int? activeSlot;
  final ValueChanged<int> onSlotTap;

  static const _slotCenters = [
    Offset(0.235, 0.27),
    Offset(0.49, 0.27),
    Offset(0.745, 0.27),
    Offset(0.235, 0.745),
    Offset(0.49, 0.745),
    Offset(0.745, 0.745),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 727),
      child: AspectRatio(
        aspectRatio: 1024 / 560,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(_trayAsset, fit: BoxFit.contain),
                ),
                for (var index = 0; index < slots.length; index++)
                  _TraySlot(
                    index: index,
                    option: slots[index],
                    active: activeSlot == index,
                    center: Offset(
                      width * _slotCenters[index].dx,
                      height * _slotCenters[index].dy,
                    ),
                    trayWidth: width,
                    onTap: () => onSlotTap(index),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TraySlot extends StatelessWidget {
  const _TraySlot({
    required this.index,
    required this.option,
    required this.active,
    required this.center,
    required this.trayWidth,
    required this.onTap,
  });

  final int index;
  final _DagwaOption? option;
  final bool active;
  final Offset center;
  final double trayWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = option == null
        ? trayWidth * 0.22
        : trayWidth * option!.trayScale;

    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: option == null
              ? _EmptyTraySlot(active: active, label: '${index + 1}')
              : _TrayItem(option: option!, active: active),
        ),
      ),
    );
  }
}

class _TrayItem extends StatelessWidget {
  const _TrayItem({required this.option, required this.active});

  final _DagwaOption option;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: active ? 1.06 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.all(active ? 5 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? const Color(0xFF934753).withValues(alpha: 0.82)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: active ? 0.26 : 0.22),
              blurRadius: active ? 24 : 19,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(option.image, fit: BoxFit.contain),
      ),
    );
  }
}

class _EmptyTraySlot extends StatelessWidget {
  const _EmptyTraySlot({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.54)
            : Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(
          color: active
              ? const Color(0xFF934753).withValues(alpha: 0.70)
              : const Color(0xFFD9C9C4).withValues(alpha: 0.62),
          width: 2,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: const Color(0xFF934753).withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(
        child: active
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF934753),
                    size: 28,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF934753),
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              )
            : Icon(
                Icons.add_rounded,
                color: const Color(0xFFBCA7A1).withValues(alpha: 0.72),
                size: 26,
              ),
      ),
    );
  }
}

class _DagwaSelector extends StatelessWidget {
  const _DagwaSelector({required this.options, required this.onSelected});

  final List<_DagwaOption> options;
  final ValueChanged<_DagwaOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : (constraints.maxWidth >= 560 ? 2 : 1);
        final gap = columns == 1 ? 18.0 : (columns == 4 ? 20.0 : 28.0);
        final maxGridWidth = columns == 4
            ? 1000.0
            : (columns == 2 ? 660.0 : 314.0);
        final gridWidth = constraints.maxWidth < maxGridWidth
            ? constraints.maxWidth
            : maxGridWidth;
        final cardWidth = (gridWidth - gap * (columns - 1)) / columns;

        return Center(
          child: SizedBox(
            width: gridWidth,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: gap,
              runSpacing: 18,
              children: [
                for (final option in options)
                  SizedBox(
                    width: cardWidth,
                    child: _DagwaCard(
                      option: option,
                      onTap: () => onSelected(option),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DagwaCard extends StatefulWidget {
  const _DagwaCard({required this.option, required this.onTap});

  final _DagwaOption option;
  final VoidCallback onTap;

  @override
  State<_DagwaCard> createState() => _DagwaCardState();
}

class _DagwaCardState extends State<_DagwaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 342,
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFFFFEFD) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? const Color(0xFFE0C7C2) : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF995959,
                ).withValues(alpha: _hovered ? 0.16 : 0.06),
                blurRadius: _hovered ? 24 : 12,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageSize = (constraints.maxWidth - 44).clamp(
                142.0,
                widget.option.cardImageSize,
              );
              final titleSize = constraints.maxWidth < 210 ? 25.0 : 28.0;

              return Column(
                children: [
                  Text(
                    widget.option.price,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF4A3D3A),
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: 16,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.option.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _hovered ? const Color(0xFF934753) : Colors.black,
                      fontFamily: 'Gowun Batang',
                      fontFamilyFallback: _serifFallback,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: _hovered ? 1.04 : 1,
                        child: SizedBox(
                          width: imageSize.toDouble(),
                          height: imageSize.toDouble(),
                          child: Image.asset(
                            widget.option.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AddDagwaButton(hovered: _hovered),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AddDagwaButton extends StatelessWidget {
  const _AddDagwaButton({required this.hovered});

  final bool hovered;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: hovered ? const Color(0xFF934753) : const Color(0xFFF4ECE9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_rounded,
            color: hovered ? Colors.white : const Color(0xFF934753),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '담기',
            style: TextStyle(
              color: hovered ? Colors.white : const Color(0xFF934753),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DagwaOption {
  const _DagwaOption({
    required this.name,
    required this.price,
    required this.priceValue,
    required this.image,
    required this.trayScale,
    required this.cardImageSize,
  });

  final String name;
  final String price;
  final int priceValue;
  final String image;
  final double trayScale;
  final double cardImageSize;
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
