import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/kiosk_button.dart';
import '../widgets/kiosk/metadata_row.dart';
import '../widgets/kiosk/top_control.dart';
import '../widgets/kiosk/story_sheet.dart';

/// 결과 데이터의 `runnerUp` 표기가 메뉴 키와 다른 경우를 이어 준다.
/// 문구 자체는 기존 것을 그대로 두고, 이미지를 찾을 때만 쓴다.
const _runnerUpAliases = <String, String>{'견과류 강정': '구움 견과 강정'};

DagwaResult? _resolve(String name) =>
    dagwaResults[name] ?? dagwaResults[_runnerUpAliases[name] ?? ''];

/// 전체 경험에서 가장 중요한 화면.
///
/// 결과 페이지가 아니라 하나의 editorial spread로 구성한다. 사용자가 휴대폰으로
/// 찍었을 때 그 자체로 포스터 한 장이 되어야 하므로, 화면 구석의 UI를 최소화하고
/// 다과 이미지를 가장 큰 주인공으로 둔다.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.menuName,
    required this.onRestart,
    required this.onHome,
  });

  final String menuName;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _shown = false;

  /// 디자인 확인용 — `--dart-define=KIOSK_STORY=true`면 시트를 열어 둔 채 시작한다.
  bool _story = const bool.fromEnvironment('KIOSK_STORY');

  @override
  void initState() {
    super.initState();
    // 앞 화면이 빠져나갈 시간을 준 뒤 등장시킨다. 바로 띄우면 전환 화면과
    // 겹쳐 보여서 공개 순간이 흐려진다.
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = dagwaResults[widget.menuName];
    if (result == null) {
      return Center(
        child: Text(
          tr('추천 결과를 찾지 못했어요.', 'No result found.'),
          style: Type.body,
        ),
      );
    }
    final tone = toneFor(widget.menuName);
    final runnerUp = _resolve(result.runnerUp);

    return Stack(
      children: [
        // 다과 대표색에서 끌어온 아주 옅은 배경 tint.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.55, -0.2),
                  radius: 1.0,
                  colors: [
                    tone.soft.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(88, 72, 88, 72),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 시각적 주인공 ──
              Expanded(
                flex: 8,
                child: _Reveal(
                  shown: _shown,
                  duration: const Duration(milliseconds: 1000),
                  child: DangwaImage(
                    assetPath: result.imagePath,
                    tone: tone,
                    aspectRatio: 5 / 6,
                    padding: 0.10,
                  ),
                ),
              ),
              const SizedBox(width: Space.x3),

              // ── 타이포그래피 ──
              Expanded(
                flex: 6,
                child: _Reveal(
                  shown: _shown,
                  delay: const Duration(milliseconds: 350),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tr('당신과 가장 잘 어울리는 다과', 'Your dagwa today'),
                        style: Type.eyebrow(tone.deep, latin: isEn, size: 16),
                      ),
                      const SizedBox(height: Space.md),
                      Text(result.menuName, style: Type.resultTitle),
                      const SizedBox(height: Space.lg),
                      Text(
                        result.title,
                        style: Type.body.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: Space.xl),
                      Container(height: 1, color: AppColors.line),
                      const SizedBox(height: Space.xl),
                      MetadataRow(
                        tone: tone.deep,
                        items: [
                          (
                            label: tr('어울리는 차', 'PAIRS WITH'),
                            value: result.pairing,
                            latin: isEn,
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xxl),
                      Column(
                        children: [
                          KioskButton(
                            label: tr('다시 추천받기', 'Try again'),
                            onPressed: widget.onRestart,
                            fullWidth: true,
                            accentColor: tone.deep,
                          ),
                          const SizedBox(height: Space.xs),
                          KioskButton(
                            label: tr('이 다과 이야기 보기', 'Read the story'),
                            onPressed: () => setState(() => _story = true),
                            variant: KioskButtonVariant.text,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── 보조 추천 — 메인을 압도하지 않게 작게 ──
        if (runnerUp != null)
          Positioned(
            right: 88,
            bottom: 40,
            child: _Reveal(
              shown: _shown,
              delay: const Duration(milliseconds: 900),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      tr('이런 다과도\n잘 어울려요', 'You may\nalso like'),
                      textAlign: TextAlign.right,
                      style: Type.caption.copyWith(
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  SizedBox(
                    width: 84,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DangwaImage(
                          assetPath: runnerUp.imagePath,
                          tone: toneFor(runnerUp.menuName),
                          padding: 0.08,
                        ),
                        const SizedBox(height: Space.xs),
                        Text(
                          runnerUp.menuName,
                          textAlign: TextAlign.center,
                          style: Type.caption.copyWith(
                            fontSize: 14,
                            color: AppColors.charcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        Positioned(left: 88, top: 60, child: TopControl(onHome: widget.onHome)),

        // ── 상세 이야기 ──
        if (_story)
          StorySheet(
            result: result,
            tone: tone,
            onClose: () => setState(() => _story = false),
          ),
      ],
    );
  }
}

/// 이미지 → 타이포 순서로 시차를 두고 떠오르는 등장.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.shown,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
  });

  final bool shown;
  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // 큰 서브트리에 불투명도를 걸면 매 프레임 saveLayer가 생긴다.
    // RepaintBoundary로 한 번 래스터해 두면 그 위에 불투명도만 얹힌다.
    return AnimatedSlide(
      offset: shown ? Offset.zero : const Offset(0, 0.04),
      duration: duration + delay,
      curve: Motion.curve,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: duration + delay,
        curve: Motion.curve,
        child: RepaintBoundary(child: child),
      ),
    );
  }
}
