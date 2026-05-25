import 'package:flutter/material.dart';

import '../data/place_info.dart';
import '../theme/app_colors.dart';
import 'common.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onAiTap,
    required this.onReservationTap,
    required this.onCateringTap,
  });

  final VoidCallback onAiTap;
  final VoidCallback onReservationTap;
  final VoidCallback onCateringTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.paper,
            AppColors.cream,
            AppColors.porcelain.withValues(alpha: 0.42),
          ],
        ),
        border: Border(bottom: BorderSide(color: AppColors.wheat)),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          0,
          isWide ? 124 : 132,
          0,
          isWide ? 82 : 60,
        ),
        child: SectionShell(
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 105,
                      child: _HeroCopy(
                        onAiTap: onAiTap,
                        onReservationTap: onReservationTap,
                        onCateringTap: onCateringTap,
                      ),
                    ),
                    const SizedBox(width: 52),
                    const Expanded(flex: 95, child: _HeroVisual()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _HeroCopy(
                        onAiTap: onAiTap,
                        onReservationTap: onReservationTap,
                        onCateringTap: onCateringTap,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: double.infinity,
                      child: _HeroVisual(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── 왼쪽: 카피 ──────────────────────────────────────
class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.onAiTap,
    required this.onReservationTap,
    required this.onCateringTap,
  });

  final VoidCallback onAiTap;
  final VoidCallback onReservationTap;
  final VoidCallback onCateringTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 820;
    final copyWidth = isWide
        ? double.infinity
        : screenWidth - (screenWidth < 420 ? 36 : 48);

    return SizedBox(
      width: copyWidth,
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow
            const Text(
              'HANGGUNG DAGWA · 행궁다과',
              style: TextStyle(
                color: AppColors.cinnabar,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 3.8,
              ),
            ),
            const SizedBox(height: 20),
            // Headline
            Text(
              '화성행궁 곁,\n명인이 빚은 다과.',
              style: TextStyle(
                color: AppColors.deep,
                fontWeight: FontWeight.w800,
                fontFamily: 'Noto Serif KR',
                fontFamilyFallback: const ['AppleMyungjo', 'serif'],
                fontSize: isWide ? 58 : 39,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 22),
            // Description
            const Text(
              '화성행궁 옆 2층 전통 디저트 공간입니다.\n다과상, 화전, 전통차, 빙수와 체험·케이터링 문의를 한곳에서 확인하세요.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 17,
                height: 1.75,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 28),
            const _HeroStoreInfo(),
            const SizedBox(height: 28),
            // CTA Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: onReservationTap,
                  icon: const Icon(Icons.event_available_outlined, size: 18),
                  label: const Text('체험 문의하기'),
                ),
                OutlinedButton.icon(
                  onPressed: onCateringTap,
                  icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('케이터링 문의'),
                ),
                OutlinedButton.icon(
                  onPressed: onAiTap,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text('AI 다과 추천'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cinnabar,
                    side: BorderSide(
                      color: AppColors.cinnabar.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStoreInfo extends StatelessWidget {
  const _HeroStoreInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat),
      ),
      child: const Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          _StoreInfoItem(
            icon: Icons.location_on_outlined,
            label: '위치',
            value: '행궁로 25 2층',
          ),
          _StoreInfoItem(
            icon: Icons.schedule_outlined,
            label: '운영',
            value: placeTodayStatus,
          ),
          _StoreInfoItem(
            icon: Icons.event_busy_outlined,
            label: '휴무',
            value: placeRegularClosed,
          ),
          _StoreInfoItem(
            icon: Icons.phone_outlined,
            label: '문의',
            value: placePhone,
          ),
        ],
      ),
    );
  }
}

class _StoreInfoItem extends StatelessWidget {
  const _StoreInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 178, maxWidth: 275),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 17, color: AppColors.cinnabar),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.cinnabar,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.brown,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
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

// ── 오른쪽: 비주얼 (React HeroSection 우측 패널 재현) ──
class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 120),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 메인 외부 박스 (한지 배경)
          Container(
            decoration: BoxDecoration(
              color: AppColors.hanji.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.wheat),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 48,
                  spreadRadius: -14,
                  offset: const Offset(0, 28),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: const _InnerPanel(),
          ),
          // 장식용 오프셋 사각형 (React -bottom-4 -right-4)
          Positioned(
            bottom: -14,
            right: -14,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          Positioned(
            top: -12,
            left: -12,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerPanel extends StatelessWidget {
  const _InnerPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.wheat),
      ),
      child: Stack(
        children: [
          // 내부 얇은 테두리 (React absolute inset-4)
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.deep.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ),
          // 코너 브래킷 (React h-9 w-9 border-l/r border-t/b)
          Positioned(
            top: 20,
            left: 20,
            child: _CornerBracketWidget(corner: _CornerSide.topLeft),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _CornerBracketWidget(corner: _CornerSide.topRight),
          ),
          Positioned(
            bottom: 52,
            left: 20,
            child: _CornerBracketWidget(corner: _CornerSide.bottomLeft),
          ),
          Positioned(
            bottom: 52,
            right: 20,
            child: _CornerBracketWidget(corner: _CornerSide.bottomRight),
          ),
          // 콘텐츠 영역
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 32, 36, 72),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'HANGGUNG DAGWA',
                  style: TextStyle(
                    color: AppColors.cinnabar,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 24),
                const _HeroPlacePhoto(),
                const SizedBox(height: 24),
                const Text(
                  '다과상',
                  style: TextStyle(
                    color: AppColors.deep,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Noto Serif KR',
                    fontFamilyFallback: ['AppleMyungjo', 'serif'],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '영양찰떡, 약과, 정과와 차를 함께 즐기는 대표 메뉴',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 16),
                const _HeroVisualRibbon(),
              ],
            ),
          ),
          // 하단 다크 바 (React absolute left-7 right-7 bottom-7 h-9 bg-[#241914])
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 44,
              color: AppColors.deep,
              alignment: Alignment.center,
              child: const Text(
                '茶菓膳  ·  행궁다과',
                style: TextStyle(
                  color: Color(0xFFE8D8C0),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPlacePhoto extends StatelessWidget {
  const _HeroPlacePhoto();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 156,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              placePhotos.first.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.hanji,
                alignment: Alignment.center,
                child: const YakgwaMedallion(size: 112),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.hanji,
                  alignment: Alignment.center,
                  child: const YakgwaMedallion(size: 96),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.deep.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '녹차빙수',
                  style: TextStyle(
                    color: Color(0xFFE8D8C0),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroVisualRibbon extends StatelessWidget {
  const _HeroVisualRibbon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.porcelain,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.jade.withValues(alpha: 0.16)),
      ),
      child: const Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Icon(Icons.spa_outlined, color: AppColors.jade, size: 16),
          Text(
            '다과상 · 전통차 · 빙수',
            style: TextStyle(
              color: AppColors.jade,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 코너 브래킷 위젯 (React h-9 w-9 border) ──────────
enum _CornerSide { topLeft, topRight, bottomLeft, bottomRight }

class _CornerBracketWidget extends StatelessWidget {
  const _CornerBracketWidget({required this.corner});
  final _CornerSide corner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(painter: _CornerPainter(corner: corner)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.corner});
  final _CornerSide corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    switch (corner) {
      case _CornerSide.topLeft:
        canvas.drawLine(Offset(0, h), Offset(0, 0), paint);
        canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      case _CornerSide.topRight:
        canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
        canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      case _CornerSide.bottomLeft:
        canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
        canvas.drawLine(Offset(0, h), Offset(w, h), paint);
      case _CornerSide.bottomRight:
        canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
        canvas.drawLine(Offset(w, h), Offset(0, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.corner != corner;
}
