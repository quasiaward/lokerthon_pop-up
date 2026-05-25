import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'ai_recommendation_section.dart';
import 'app_footer.dart';
import 'brand_story_section.dart';
import 'catering_section.dart';
import 'floating_chatbot.dart';
import 'hero_section.dart';
import 'menu_section.dart';
import 'reservation_section.dart';
import 'top_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _topKey = GlobalKey();
  final _brandKey = GlobalKey();
  final _menuKey = GlobalKey();
  final _reservationKey = GlobalKey();
  final _cateringKey = GlobalKey();
  final _aiKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(key: _topKey, height: 1),
                  HeroSection(
                    onAiTap: () => _scrollTo(_aiKey),
                    onReservationTap: () => _scrollTo(_reservationKey),
                    onCateringTap: () => _scrollTo(_cateringKey),
                  ),
                  BrandStorySection(key: _brandKey),
                  MenuSection(key: _menuKey),
                  ReservationSection(key: _reservationKey),
                  CateringSection(key: _cateringKey),
                  AIRecommendationSection(key: _aiKey),
                  const AppFooter(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopHeader(
              onLogoTap: () => _scrollTo(_topKey),
              onBrandTap: () => _scrollTo(_brandKey),
              onMenuTap: () => _scrollTo(_menuKey),
              onReservationTap: () => _scrollTo(_reservationKey),
              onCateringTap: () => _scrollTo(_cateringKey),
              onAiTap: () => _scrollTo(_aiKey),
            ),
          ),
          const FloatingHaenggungChatbot(),
        ],
      ),
    );
  }
}
