import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../theme/app_colors.dart';

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
      text: '안녕하세요! 행궁다과 AI 안내입니다. 메뉴, 위치, 영업시간, 체험·케이터링 문의를 도와드릴게요.',
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
    final windowWidth = width < 440 ? width - 40 : 380.0;
    final windowHeight = math.min(560.0, math.max(260.0, height - 128.0));

    return Container(
      width: windowWidth,
      constraints: BoxConstraints(maxHeight: windowHeight),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.wheat),
        boxShadow: [
          BoxShadow(
            color: AppColors.deep.withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: AppColors.deep,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '宮',
                        style: TextStyle(
                          color: AppColors.cinnabar,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'AppleMyungjo',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '행궁다과 AI 안내',
                        style: TextStyle(
                          color: AppColors.paper,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '무엇이든 물어보세요',
                        style: TextStyle(
                          color: Color(0xFFB9AA96),
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 메시지 목록
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(14),
                itemCount: messages.length,
                itemBuilder: (context, index) =>
                    _Bubble(message: messages[index]),
              ),
            ),
            // 빠른 질문 칩
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              decoration: BoxDecoration(
                color: AppColors.hanji,
                border: Border(top: BorderSide(color: AppColors.wheat)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '빠른 질문',
                    style: TextStyle(
                      color: AppColors.cinnabar,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final q in const [
                        '체험 문의 방법',
                        '포장 주문 문의',
                        '운영 시간',
                        'English menu',
                      ])
                        _QuickChip(label: q, onTap: () => onSend(q)),
                    ],
                  ),
                ],
              ),
            ),
            // 입력창
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border(top: BorderSide(color: AppColors.wheat)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        isDense: true,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onSend(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.deep,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppColors.paper,
                        size: 16,
                      ),
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

// ── 빠른 질문 칩 (React 스타일: 직각, hover 시 dark) ──
class _QuickChip extends StatefulWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.deep : AppColors.paper,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.wheat),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovered ? AppColors.paper : AppColors.deep,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 말풍선 ─────────────────────────────────────────
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _Role.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: isUser ? AppColors.cinnabar : AppColors.paper,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isUser
                ? const Radius.circular(14)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(14),
          ),
          border: Border.all(
            color: isUser ? AppColors.cinnabar : AppColors.wheat,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? AppColors.paper : AppColors.deep,
            height: 1.55,
            fontSize: 13,
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
