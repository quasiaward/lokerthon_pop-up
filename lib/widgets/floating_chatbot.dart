import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/place_info.dart';

const _serifFallback = [
  'Apple SD Gothic Neo',
  'Noto Sans CJK KR',
  'Malgun Gothic',
  'sans-serif',
];

class FloatingHaenggungChatbot extends StatefulWidget {
  const FloatingHaenggungChatbot({super.key});

  @override
  State<FloatingHaenggungChatbot> createState() =>
      _FloatingHaenggungChatbotState();
}

class _FloatingHaenggungChatbotState extends State<FloatingHaenggungChatbot> {
  final _controller = TextEditingController();
  bool _open = false;
  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      role: _Role.bot,
      text: '안녕하세요! 행궁다과 AI 입니다.\n메뉴, 위치, 영업시간 등 궁금한 정보를\n물어보세요,',
    ),
  ];
  final List<_ChatMessage> _mutableMessages = [];

  @override
  void initState() {
    super.initState();
    _mutableMessages.addAll(_messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _mutableMessages.add(_ChatMessage(role: _Role.user, text: text));
      _mutableMessages.add(_ChatMessage(role: _Role.bot, text: _answer(text)));
      _controller.clear();
      _open = true;
    });
  }

  String _answer(String text) {
    final lower = text.toLowerCase();
    if (text.contains('예약') || text.contains('체험') || text.contains('방문')) {
      return '네이버 지도 기준으로는 즉시 예약 버튼보다 전화·현장 문의가 자연스럽습니다. 희망 체험 날짜, 시간, 인원, 연락처를 남기시면 매장 확인 후 안내받는 흐름으로 정리해 두었습니다.';
    }
    if (text.contains('케이터링') ||
        text.contains('행사') ||
        text.contains('주문') ||
        text.contains('포장') ||
        text.contains('단체')) {
      return '케이터링 문의는 다과상, 행궁약과, 정과류, 전통차 구성을 중심으로 수량과 픽업 시간을 확인하는 방식이 좋습니다. 가장 정확한 확인 전화는 $placePhone입니다.';
    }
    if (text.contains('메뉴') || text.contains('약과') || text.contains('다과')) {
      return '공개 메뉴 기준 대표 메뉴는 진달래화전 7,000원, 다과상 7,000원, 쌍화차 9,000원, 대추차 9,000원, 생강차 7,000원입니다. 빙수와 포장 다과도 함께 확인해 보세요.';
    }
    if (text.contains('위치') || text.contains('행궁동') || text.contains('주소')) {
      return '행궁다과 주소는 $placeRoadAddress입니다. 지번 주소는 $placeLotAddress이고, 화성행궁 관람 전후에 들르기 좋은 2층 매장입니다.';
    }
    if (text.contains('운영') || text.contains('영업') || text.contains('시간')) {
      return '공개 영업정보 기준 $placeTodayStatus, $placeRegularClosed입니다. 영업시간은 변동될 수 있어 방문 전 네이버 지도나 전화($placePhone)로 확인해 주세요.';
    }
    if (text.contains('가격') || text.contains('얼마') || text.contains('비용')) {
      return '공개 메뉴 기준 진달래화전·다과상 7,000원, 생강차 7,000원, 대추차·쌍화차 9,000원입니다. 계절 메뉴와 포장 구성은 매장에서 확인하는 편이 정확합니다.';
    }
    if (lower.contains('english') || lower.contains('menu')) {
      return 'Our menu is available in English! Visit the Menu section and select the "English" tab to view all items with English descriptions and prices.';
    }
    if (text.contains('日本') || text.contains('予約') || text.contains('メニュー')) {
      return 'メニューは日本語でもご確認いただけます。「メニュー」セクションで「日本語」タブをお選びください。';
    }
    if (text.contains('AI') || text.contains('추천') || text.contains('처방')) {
      return 'AI 다과 추천 섹션에서 성향, 상황, 단맛, 식감, 차 취향을 답하면 오늘 어울리는 다과와 함께 마실 차, 차선 메뉴까지 추천해 드립니다.';
    }
    return '행궁다과에 대해 더 궁금한 점이 있으시면 메뉴, 위치, 영업시간, 가격, 체험·케이터링 문의를 입력해 주세요. 전화 문의: $placePhone';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_open)
            _ChatWindow(
              messages: _mutableMessages,
              controller: _controller,
              onSend: _send,
            ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7E7),
                borderRadius: BorderRadius.circular(42.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.39),
                    blurRadius: 4.3,
                  ),
                ],
              ),
              child: Icon(
                _open ? Icons.close_rounded : Icons.headset_mic_outlined,
                color: const Color(0xFF534344),
                size: 41,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 채팅 윈도우 ──────────────────────────────────────
class _ChatWindow extends StatelessWidget {
  const _ChatWindow({
    required this.messages,
    required this.controller,
    required this.onSend,
  });

  final List<_ChatMessage> messages;
  final TextEditingController controller;
  final void Function([String? preset]) onSend;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final windowWidth = width < 560 ? width - 28 : 520.0;
    final windowHeight = math.min(560.0, math.max(430.0, height - 126.0));

    return Container(
      width: windowWidth,
      height: windowHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD5D1D1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
              color: const Color(0xFFFCFCFC),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.headset_mic_outlined,
                    color: Color(0xFF9B766F),
                    size: 42,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '행궁다과 AI 안내',
                          style: TextStyle(
                            color: Color(0xFF7C6864),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontWeight: FontWeight.w700,
                            fontSize: 29,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'AI 챗봇을 통해 매장의 간단한 정보들을 쉽고 빠르게 알려줍니다.\n자세한 정보는 행궁다과 카카오톡 채널을 이용해주세요.',
                          style: TextStyle(
                            color: Color(0xFFAAA5A5),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 15,
                            height: 1.32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _ChatBody(messages: messages, onSend: onSend),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 18, 14),
              color: const Color(0xFFFCFCFC),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(
                          fontFamily: 'Gowun Batang',
                          fontFamilyFallback: _serifFallback,
                          color: Color(0xFF534344),
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요.',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB5B3B3),
                            fontFamily: 'Gowun Batang',
                            fontFamilyFallback: _serifFallback,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3EFEF),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0CBCB),
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    tooltip: '전송',
                    onPressed: () => onSend(),
                    icon: const Icon(Icons.arrow_upward_rounded),
                    color: const Color(0xFF9B4A4F),
                    iconSize: 42,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(52, 52),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({required this.messages, required this.onSend});

  final List<_ChatMessage> messages;
  final void Function([String? preset]) onSend;

  bool get _initial => messages.length == 1 && messages.first.role == _Role.bot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFCFAFA),
      child: _initial
          ? _InitialChatBody(message: messages.first, onSend: onSend)
          : _ConversationList(messages: messages, onSend: onSend),
    );
  }
}

class _InitialChatBody extends StatelessWidget {
  const _InitialChatBody({required this.message, required this.onSend});

  final _ChatMessage message;
  final void Function([String? preset]) onSend;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 500;
        final content = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _Bubble(message: message, compact: true)),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 230,
                    child: _QuickQuestionPanel(onSend: onSend, compact: true),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Bubble(message: message, compact: true),
                  const SizedBox(height: 12),
                  _QuickQuestionPanel(onSend: onSend, compact: true),
                ],
              );

        return Padding(
          padding: EdgeInsets.fromLTRB(24, wide ? 16 : 12, 24, wide ? 18 : 12),
          child: Center(child: content),
        );
      },
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.messages, required this.onSend});

  final List<_ChatMessage> messages;
  final void Function([String? preset]) onSend;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 18),
      children: [
        for (final message in messages)
          _Bubble(message: message, compact: true),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: _QuickQuestionPanel(onSend: onSend, compact: true),
        ),
      ],
    );
  }
}

class _QuickQuestionPanel extends StatelessWidget {
  const _QuickQuestionPanel({required this.onSend, this.compact = false});

  final void Function([String? preset]) onSend;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 480;

    return Container(
      width: compact || narrow ? double.infinity : 312,
      padding: EdgeInsets.fromLTRB(
        16,
        compact ? 13 : 16,
        16,
        compact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE1E1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: Border.all(color: const Color(0xFFE2CACA), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 질문',
            style: TextStyle(
              color: Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          Wrap(
            spacing: compact ? 8 : 12,
            runSpacing: compact ? 8 : 12,
            children: [
              for (final q in const [
                '체험 문의 방법',
                '운영 시간',
                '포장 주문 문의',
                'English menu',
              ])
                _QuickChip(label: q, compact: compact, onTap: () => onSend(q)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatefulWidget {
  const _QuickChip({
    required this.label,
    required this.compact,
    required this.onTap,
  });
  final String label;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14 : 18,
            vertical: widget.compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF8F6F6) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: const Color(0xFF9B766F).withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: const Color(0xFF534344),
              fontFamily: 'Gowun Batang',
              fontFamilyFallback: _serifFallback,
              fontSize: widget.compact ? 17 : 20,
              fontWeight: _hovered ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.compact = false});
  final _ChatMessage message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _Role.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 15 : 18,
          vertical: compact ? 14 : 18,
        ),
        constraints: BoxConstraints(maxWidth: compact ? 260 : 318),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFEDE1E1) : const Color(0xFFFEFEFE),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(0),
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser ? const Color(0xFFE2CACA) : const Color(0xFFE2CACA),
            width: 3,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: const Color(0xFF7B716C),
            height: compact ? 1.25 : 1.18,
            fontFamily: 'Gowun Batang',
            fontFamilyFallback: _serifFallback,
            fontSize: compact ? (isUser ? 16 : 18) : (isUser ? 18 : 23),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

enum _Role { user, bot }

class _ChatMessage {
  const _ChatMessage({required this.role, required this.text});
  final _Role role;
  final String text;
}
