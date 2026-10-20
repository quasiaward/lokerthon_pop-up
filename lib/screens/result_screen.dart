import 'package:flutter/material.dart';

import '../data/dagwa_results.dart';
import '../data/dagwa_tones.dart';
import '../l10n/lang.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/kiosk/dangwa_image.dart';
import '../widgets/kiosk/glass_surface.dart';
import '../widgets/kiosk/kiosk_button.dart';
import '../widgets/kiosk/kiosk_reading_panel.dart';
import '../widgets/kiosk/story_sheet.dart';
import '../widgets/kiosk/store_directions_sheet.dart';
import '../widgets/kiosk/top_control.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.menuName,
    required this.onRestart,
    required this.onHome,
    this.onActivity,
  });

  final String menuName;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final VoidCallback? onActivity;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _story = const bool.fromEnvironment('KIOSK_STORY');
  bool _directions = false;

  void _interact(VoidCallback update) {
    // VoiceOver의 활성화는 포인터 이벤트 없이 실행된다.
    widget.onActivity?.call();
    setState(update);
  }

  @override
  Widget build(BuildContext context) {
    final result = dagwaResults[widget.menuName];
    if (result == null) {
      return Center(
        child: KioskButton(
          label: tr('처음으로', 'Home', 'はじめに戻る'),
          onPressed: widget.onHome,
        ),
      );
    }

    final tone = toneFor(result.menuName);
    return Stack(
      children: [
        ExcludeSemantics(
          excluding: _story || _directions,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(88, 48, 88, 52),
            child: Column(
              children: [
                TopControl(onHome: widget.onHome),
                const SizedBox(height: 28),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: DangwaImage(
                          assetPath: result.imagePath,
                          tone: tone,
                          aspectRatio: 0.95,
                          padding: 0.10,
                        ),
                      ),
                      const SizedBox(width: 64),
                      Expanded(
                        flex: 6,
                        child: KioskReadingPanel(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tr(
                                '당신과 가장 잘 어울리는 다과',
                                'Your dagwa today',
                                'あなたにいちばん似合う茶菓',
                              ),
                              style: Type.eyebrow(
                                tone.deep,
                                latin: isEn,
                                tracking: 3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              result.name.t,
                              style: Type.resultTitle.copyWith(height: 1.12),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              result.title.t,
                              style: Type.body.copyWith(
                                fontSize: 22,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 26),
                            _TeaPairing(
                              pairing: result.pairing.t,
                              accentColor: tone.deep,
                            ),
                            const SizedBox(height: 26),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: KioskButton(
                                      label: tr(
                                        '이 다과 이야기 보기',
                                        'Read the story',
                                        'この茶菓の物語を読む',
                                      ),
                                      fullWidth: true,
                                      accentColor: tone.deep,
                                      onPressed: () =>
                                          _interact(() => _story = true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: KioskButton(
                                      label: tr(
                                        '다시 추천받기',
                                        'Try again',
                                        'もう一度さがす',
                                      ),
                                      fullWidth: true,
                                      variant: KioskButtonVariant.secondary,
                                      onPressed: widget.onRestart,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(flex: 3, child: _PickupNotice()),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: _StoreRouteCard(
                          onPressed: () => _interact(() => _directions = true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_story)
          StorySheet(
            onActivity: widget.onActivity,
            result: result,
            tone: tone,
            onClose: () => _interact(() => _story = false),
          ),
        if (_directions)
          StoreDirectionsSheet(
            onActivity: widget.onActivity,
            onClose: () => _interact(() => _directions = false),
          ),
      ],
    );
  }
}

/// 추천 결과의 보조 정보. 수령 안내보다 한 단계 낮은 밀도와 대비로 표현한다.
class _TeaPairing extends StatelessWidget {
  const _TeaPairing({required this.pairing, required this.accentColor});

  final String pairing;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.celadonSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_cafe_rounded,
            color: AppColors.celadon,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          tr('어울리는 차', 'Pairs with', '相性のよいお茶'),
          style: Type.bodyMuted.copyWith(fontSize: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            pairing,
            textAlign: TextAlign.right,
            style: Type.section.copyWith(fontSize: 22, color: accentColor),
          ),
        ),
      ],
    ),
  );
}

/// 추천을 실제 팝업 경험으로 이어 주는 결과 화면의 마지막 단계.
/// 조작 요소처럼 보이지 않도록 화살표나 버튼 테두리는 쓰지 않는다.
class _PickupNotice extends StatelessWidget {
  const _PickupNotice();

  @override
  Widget build(BuildContext context) {
    final title = tr(
      '추천받은 다과를 받아가세요',
      'Collect your recommended dagwa',
      'おすすめの茶菓をお受け取りください',
    );
    final guide = tr(
      '이 화면을 옆의 직원에게 보여주시면 바로 준비해 드릴게요.',
      'Show this screen to a staff member and we’ll prepare it for you.',
      'この画面をお近くのスタッフに見せてください。すぐにご用意します。',
    );

    return Semantics(
      container: true,
      label: '$title. $guide',
      child: GlassSurface(
        radius: 30,
        strong: true,
        blurBackdrop: true,
        child: ConstrainedBox(
          key: const ValueKey('pickup-notice'),
          constraints: const BoxConstraints(minHeight: 126),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.redeem_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXT STEP',
                        style: Type.eyebrow(
                          AppColors.accent,
                          size: 12,
                          tracking: 2.0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(title, style: Type.section.copyWith(fontSize: 23)),
                      const SizedBox(height: 4),
                      Text(
                        guide,
                        style: Type.bodyMuted.copyWith(
                          fontSize: 16,
                          height: 1.35,
                        ),
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

/// 다과 수령 후 브랜드 매장으로 자연스럽게 이어 주는 보조 행동.
/// 전체 카드가 터치 영역이며, 화살표로 조작 가능성을 명확히 표시한다.
class _StoreRouteCard extends StatelessWidget {
  const _StoreRouteCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final title = tr('행궁다과도 만나보세요', 'Visit Haenggung Dagwa', '行宮茶菓にもお立ち寄りください');
    final distance = tr(
      '도보 약 1분 · 98m',
      'About 1 min on foot · 98 m',
      '徒歩約1分 ・ 98m',
    );

    return Semantics(
      button: true,
      label:
          '$title. $distance. ${tr('앱에서 길 안내 보기', 'View directions in the app', 'アプリで道案内を見る')}',
      child: GlassSurface(
        radius: 30,
        strong: true,
        blurBackdrop: true,
        child: ConstrainedBox(
          key: const ValueKey('store-route-card'),
          constraints: const BoxConstraints(minHeight: 126),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 18, 14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.celadonSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.celadon,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VISIT THE STORE',
                            style: Type.eyebrow(
                              AppColors.celadon,
                              size: 12,
                              tracking: 1.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: Type.section.copyWith(fontSize: 21),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            distance,
                            style: Type.caption.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
