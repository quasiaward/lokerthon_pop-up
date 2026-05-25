import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/recommendation.dart';
import '../services/recommendation_service.dart';
import '../theme/app_colors.dart';
import 'common.dart';

class AIRecommendationSection extends StatefulWidget {
  const AIRecommendationSection({super.key});

  @override
  State<AIRecommendationSection> createState() =>
      _AIRecommendationSectionState();
}

class _AIRecommendationSectionState extends State<AIRecommendationSection> {
  final _service = RecommendationService();
  final _controller = TextEditingController(
    text: defaultRecommendationInput.situation,
  );
  RecommendationInput _input = defaultRecommendationInput;
  RecommendationResult? _result;
  bool _isLoading = false;
  bool _copied = false;
  int _variant = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runRecommendation() async {
    final snapshot = _input.copyWith(situation: _controller.text);
    final nextVariant = _variant + 1;

    setState(() {
      _input = snapshot;
      _variant = nextVariant;
      _isLoading = true;
      _copied = false;
      _result = null;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _result = _service.getRecommendation(snapshot, variant: nextVariant);
      _isLoading = false;
    });
  }

  Future<void> _copyResult() async {
    final result = _result;
    if (result == null) return;

    await Clipboard.setData(ClipboardData(text: _service.formatResult(result)));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  void _updateInput(RecommendationInput nextInput) {
    setState(() {
      _input = nextInput;
      _copied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1020;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deep, Color(0xFF30211D), Color(0xFF162B27)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 92),
      child: SectionShell(
        child: Column(
          children: [
            const SectionHeading(
              eyebrow: 'AI Recommend',
              title: 'AI 다과 추천',
              description: '개별 다과 유형과 취향 신호를 비교해 한 가지 메뉴를 제안합니다.',
              inverse: true,
            ),
            const SizedBox(height: 24),
            const _EngineProofBar(),
            const SizedBox(height: 34),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 10,
                        child: _InputPanel(
                          input: _input,
                          controller: _controller,
                          isLoading: _isLoading,
                          onInputChanged: _updateInput,
                          onSubmit: _runRecommendation,
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        flex: 12,
                        child: _ResultPanel(
                          input: _input,
                          result: _result,
                          isLoading: _isLoading,
                          copied: _copied,
                          onCopy: _copyResult,
                          onRetry: _runRecommendation,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _InputPanel(
                        input: _input,
                        controller: _controller,
                        isLoading: _isLoading,
                        onInputChanged: _updateInput,
                        onSubmit: _runRecommendation,
                      ),
                      const SizedBox(height: 20),
                      _ResultPanel(
                        input: _input,
                        result: _result,
                        isLoading: _isLoading,
                        copied: _copied,
                        onCopy: _copyResult,
                        onRetry: _runRecommendation,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _EngineProofBar extends StatelessWidget {
  const _EngineProofBar();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: const [
        _EngineProofChip(
          icon: Icons.psychology_alt_outlined,
          label: '6개 성향 질문',
        ),
        _EngineProofChip(icon: Icons.category_outlined, label: '개별 다과 분석'),
        _EngineProofChip(icon: Icons.tune_rounded, label: '맛·식감 매칭'),
        _EngineProofChip(icon: Icons.edit_note_rounded, label: '상황 문장 보정'),
      ],
    );
  }
}

class _EngineProofChip extends StatelessWidget {
  const _EngineProofChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 17),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.hanji,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputPanel extends StatelessWidget {
  const _InputPanel({
    required this.input,
    required this.controller,
    required this.isLoading,
    required this.onInputChanged,
    required this.onSubmit,
  });

  final RecommendationInput input;
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<RecommendationInput> onInputChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(22),
      color: AppColors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '성향 분석 입력',
                      style: TextStyle(
                        color: AppColors.cinnabar,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '다과 취향 설문',
                      style: TextStyle(
                        color: AppColors.deep,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Noto Serif KR',
                        fontFamilyFallback: ['AppleMyungjo', 'serif'],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.hanji,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.manage_search_rounded,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _CompactQuestionGrid(
            children: [
              _CompactSelect(
                label: '성향',
                options: personalityTypes,
                value: input.personality,
                onChanged: (value) =>
                    onInputChanged(input.copyWith(personality: value)),
              ),
              _CompactSelect(
                label: '상황',
                options: visitMoments,
                value: input.moment,
                onChanged: (value) =>
                    onInputChanged(input.copyWith(moment: value)),
              ),
              _CompactSelect(
                label: '단맛',
                options: sweetnessPreferences,
                value: input.sweetness,
                onChanged: (value) =>
                    onInputChanged(input.copyWith(sweetness: value)),
              ),
              _CompactSelect(
                label: '식감',
                options: texturePreferences,
                value: input.texture,
                onChanged: (value) =>
                    onInputChanged(input.copyWith(texture: value)),
              ),
              _CompactSelect(
                label: '차 취향',
                options: teaPreferences,
                value: input.tea,
                onChanged: (value) =>
                    onInputChanged(input.copyWith(tea: value)),
              ),
              _CompactSelect(
                label: '선택 스타일',
                options: choiceStyles,
                value: input.choiceStyle,
                onChanged: (value) =>
                    onInputChanged(input.copyWith(choiceStyle: value)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            '오늘의 취향 메모 (선택)',
            style: TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 2,
            minLines: 2,
            style: const TextStyle(
              color: AppColors.deep,
              fontSize: 14,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: '예: 조용히 앉아서 따뜻한 차와 함께 먹고 싶어요',
              hintStyle: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.62),
              ),
              filled: true,
              fillColor: AppColors.cream,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.brown.withValues(alpha: 0.14),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.brown.withValues(alpha: 0.14),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.paper,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('성향 분석하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactQuestionGrid extends StatelessWidget {
  const _CompactQuestionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 500;
        final itemWidth = useTwoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _CompactSelect extends StatelessWidget {
  const _CompactSelect({
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
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.brown,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: AppColors.cream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      selectedItemBuilder: (context) => [
        for (final option in options)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              option,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.deep,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
      items: [
        for (final option in options)
          DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: const TextStyle(
                color: AppColors.deep,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
      onChanged: (nextValue) {
        if (nextValue != null) onChanged(nextValue);
      },
    );
  }
}

class OptionGroup extends StatelessWidget {
  const OptionGroup({
    super.key,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.brown,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              _OptionButton(
                option: option,
                selected: option == value,
                onTap: () => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final String option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.brown : AppColors.paper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.brown
                : AppColors.brown.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: selected ? AppColors.paper : AppColors.muted,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.input,
    required this.result,
    required this.isLoading,
    required this.copied,
    required this.onCopy,
    required this.onRetry,
  });

  final RecommendationInput input;
  final RecommendationResult? result;
  final bool isLoading;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      color: AppColors.paper,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.hanji,
                  AppColors.porcelain.withValues(alpha: 0.78),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.brown.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.deep,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.psychology_alt_outlined,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI 다과 추천 엔진',
                            style: TextStyle(
                              color: AppColors.cinnabar,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '취향 분석 결과',
                            style: TextStyle(
                              color: AppColors.deep,
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 21 : 24,
                              height: 1.2,
                              fontFamily: 'Noto Serif KR',
                              fontFamilyFallback: const [
                                'AppleMyungjo',
                                'serif',
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) const _ReadyBadge(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _panelBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelBody(BuildContext context) {
    if (isLoading) {
      return _LoadingAnalysis(input: input);
    }

    final current = result;
    if (current == null) {
      return _EmptyResult(input: input);
    }

    return _RecommendationResultView(
      result: current,
      copied: copied,
      onCopy: onCopy,
      onRetry: onRetry,
    );
  }
}

class _ReadyBadge extends StatelessWidget {
  const _ReadyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.36)),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.input});

  final RecommendationInput input;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '현재 성향 신호를 읽고 있습니다',
            style: TextStyle(
              color: AppColors.deep,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              fontFamily: 'Noto Serif KR',
              fontFamilyFallback: ['AppleMyungjo', 'serif'],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '분석을 실행하면 추천 메뉴, 함께 어울리는 차, 차선 메뉴, 추천 근거가 한 번에 정리됩니다.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 15,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 20),
          _SignalPreview(input: input),
        ],
      ),
    );
  }
}

class _SignalPreview extends StatelessWidget {
  const _SignalPreview({required this.input});

  final RecommendationInput input;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PreviewRow(label: '성향 신호', value: input.personality),
        _PreviewRow(label: '상황 신호', value: input.moment),
        _PreviewRow(label: '단맛 신호', value: input.sweetness),
        _PreviewRow(label: '식감 신호', value: input.texture),
        _PreviewRow(label: '차 신호', value: input.tea),
        _PreviewRow(label: '선택 신호', value: input.choiceStyle),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.cinnabar,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.brown.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingAnalysis extends StatelessWidget {
  const _LoadingAnalysis({required this.input});

  final RecommendationInput input;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('loading'),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '행궁다과 AI가 성향과 메뉴 특징을 맞추고 있어요...',
            style: TextStyle(
              color: AppColors.deep,
              fontWeight: FontWeight.w800,
              fontSize: 21,
              fontFamily: 'Noto Serif KR',
              fontFamilyFallback: ['AppleMyungjo', 'serif'],
            ),
          ),
          const SizedBox(height: 18),
          _AnalysisStep(label: '성향 질문 읽기', value: input.personality),
          _AnalysisStep(label: '메뉴 특징값 매칭', value: input.sweetness),
          _AnalysisStep(label: '상황 문장 보정', value: input.situation),
          const _AnalysisStep(label: '결과 문장 생성', value: '추천 메뉴와 차선 메뉴 정리'),
        ],
      ),
    );
  }
}

class _AnalysisStep extends StatelessWidget {
  const _AnalysisStep({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.deep,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '입력값 없음' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.45,
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

class _RecommendationResultView extends StatelessWidget {
  const _RecommendationResultView({
    required this.result,
    required this.copied,
    required this.onCopy,
    required this.onRetry,
  });

  final RecommendationResult result;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      key: const ValueKey('result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultHero(result: result),
          const SizedBox(height: 12),
          _RecommendationNote(message: result.packagingMessage),
          const SizedBox(height: 18),
          _SignalBoard(result: result),
          const SizedBox(height: 18),
          const Text(
            '추천 이유',
            style: TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < result.reasons.length; index++) ...[
            _ReasonRow(index: index, reason: result.reasons[index]),
            const SizedBox(height: 9),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;
              final blocks = [
                _InfoBlock(
                  icon: Icons.local_cafe_outlined,
                  title: '함께 어울리는 메뉴/차',
                  value: result.teaPairing,
                ),
                _InfoBlock(
                  icon: Icons.alt_route_rounded,
                  title: '차선 추천',
                  value: result.secondaryMenuName,
                ),
              ];

              return isNarrow
                  ? Column(
                      children: [
                        blocks[0],
                        const SizedBox(height: 12),
                        blocks[1],
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: blocks[0]),
                        const SizedBox(width: 12),
                        Expanded(child: blocks[1]),
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in result.tags) TagPill(label: tag)],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: Icon(
                  copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 18,
                ),
                label: Text(copied ? '복사 완료' : '추천 결과 복사'),
              ),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('다시 분석하기'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.result});

  final RecommendationResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.24)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '추천 프로필',
                style: TextStyle(
                  color: AppColors.cinnabar,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                result.profileTitle,
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 18 : 20,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              _TypeBadge(label: result.dagwaType),
              const SizedBox(height: 10),
              Text(
                result.productName,
                style: TextStyle(
                  color: AppColors.deep,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 27 : 32,
                  height: 1.15,
                  fontFamily: 'Noto Serif KR',
                  fontFamilyFallback: const ['AppleMyungjo', 'serif'],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.typeDescription,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                result.aiSummary,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  height: 1.65,
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 14),
                _ConfidenceBadge(confidence: result.confidence, compact: true),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 16),
              _ConfidenceBadge(confidence: result.confidence),
            ],
          );
        },
      ),
    );
  }
}

class _RecommendationNote extends StatelessWidget {
  const _RecommendationNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.hanji.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.cinnabar,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.brown,
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.cinnabar,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence, this.compact = false});

  final int confidence;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 86,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 0,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.deep,
        borderRadius: BorderRadius.circular(8),
      ),
      child: compact
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '추천 매칭도',
                  style: TextStyle(
                    color: AppColors.hanji,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$confidence%',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Text(
                  '$confidence%',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '매칭도',
                  style: TextStyle(
                    color: AppColors.hanji,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SignalBoard extends StatelessWidget {
  const _SignalBoard({required this.result});

  final RecommendationResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI가 읽은 신호',
            style: TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final signal in result.signals) _SignalRow(signal: signal),
        ],
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.signal});

  final AiSignal signal;

  @override
  Widget build(BuildContext context) {
    final widthFactor = (signal.weight / 100).clamp(0.12, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 92,
                child: Text(
                  signal.label,
                  style: const TextStyle(
                    color: AppColors.cinnabar,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  signal.value,
                  style: const TextStyle(
                    color: AppColors.deep,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${signal.weight}',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 6,
              color: AppColors.hanji,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(color: AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.index, required this.reason});

  final int index;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.brown,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.paper,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reason,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brown.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.cinnabar, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.cinnabar,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.deep,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
