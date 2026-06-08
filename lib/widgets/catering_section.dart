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
  image: 'assets/figma/catering_figma_yakgwa.png',
  trayScale: 0.23,
  cardImageSize: 228,
);

const _hwajeon = _DagwaOption(
  name: '진달래 화전',
  price: '5,000',
  image: 'assets/figma/catering_figma_hwajeon.png',
  trayScale: 0.29,
  cardImageSize: 225,
);

const _songpyeon = _DagwaOption(
  name: '송편',
  price: '5,000',
  image: 'assets/figma/catering_figma_songpyeon.png',
  trayScale: 0.25,
  cardImageSize: 190,
);

const _osakgyeongdan = _DagwaOption(
  name: '오색경단',
  price: '5,000',
  image: 'assets/figma/catering_figma_osakgyeongdan.png',
  trayScale: 0.26,
  cardImageSize: 198,
);

const _selectorOptions = [_yakgwa, _hwajeon, _songpyeon];

class CateringSection extends StatefulWidget {
  const CateringSection({super.key});

  @override
  State<CateringSection> createState() => _CateringSectionState();
}

class _CateringSectionState extends State<CateringSection> {
  late final List<_DagwaOption?> _slots;
  int? _activeSlot;

  @override
  void initState() {
    super.initState();
    _slots = [_songpyeon, _osakgyeongdan, _songpyeon, _hwajeon, null, null];
  }

  void _selectSlot(int index) {
    setState(() => _activeSlot = index);
  }

  void _addDagwa(_DagwaOption option) {
    setState(() {
      final targetIndex =
          _activeSlot ?? _slots.indexWhere((slot) => slot == null);
      _slots[targetIndex == -1 ? 0 : targetIndex] = option;

      final nextEmpty = _slots.indexWhere((slot) => slot == null);
      _activeSlot = nextEmpty == -1 ? null : nextEmpty;
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
            clipBehavior: Clip.none,
            children: [
              if (!compact)
                Positioned(
                  right: -300,
                  top: 350,
                  width: 760,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.2,
                      child: Image.asset(_decoAsset, fit: BoxFit.contain),
                    ),
                  ),
                ),
              SectionShell(
                maxWidth: 1040,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    compact ? 48 : 62,
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
                      SizedBox(height: compact ? 30 : 36),
                      _TrayBuilder(
                        slots: _slots,
                        activeSlot: _activeSlot,
                        onSlotTap: _selectSlot,
                      ),
                      SizedBox(height: compact ? 42 : 64),
                      _DagwaSelector(
                        options: const [
                          ..._selectorOptions,
                          ..._selectorOptions,
                        ],
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
      child: GestureDetector(
        onTap: onTap,
        child: option == null
            ? _EmptyTraySlot(active: active, label: '${index + 1}')
            : _TrayItem(option: option!, active: active),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.all(active ? 4 : 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: active ? const Color(0xFF995959) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 19,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(option.image, fit: BoxFit.contain),
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
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.transparent,
        border: Border.all(
          color: active
              ? const Color(0xFF995959).withValues(alpha: 0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: active
          ? Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF995959),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
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
        final columns = constraints.maxWidth >= 900
            ? 3
            : (constraints.maxWidth >= 660 ? 2 : 1);
        final gap = columns == 1 ? 18.0 : 32.0;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: 14,
          children: [
            for (final option in options)
              SizedBox(
                width: cardWidth.clamp(240.0, 314.0),
                child: _DagwaCard(
                  option: option,
                  onTap: () => onSelected(option),
                ),
              ),
          ],
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
          height: 349,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF995959).withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                widget.option.price,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
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
                style: TextStyle(
                  color: _hovered ? const Color(0xFF995959) : Colors.black,
                  fontFamily: 'Gowun Batang',
                  fontFamilyFallback: _serifFallback,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: widget.option.cardImageSize,
                height: widget.option.cardImageSize,
                child: Image.asset(widget.option.image, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DagwaOption {
  const _DagwaOption({
    required this.name,
    required this.price,
    required this.image,
    required this.trayScale,
    required this.cardImageSize,
  });

  final String name;
  final String price;
  final String image;
  final double trayScale;
  final double cardImageSize;
}
