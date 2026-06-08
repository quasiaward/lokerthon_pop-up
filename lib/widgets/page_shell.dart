import 'package:flutter/material.dart';

import 'app_nav.dart';
import 'floating_chatbot.dart';
import 'footer.dart';

class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.currentRoute,
    required this.child,
    this.backgroundColor = const Color(0xFFF5F5F3),
  });

  final String currentRoute;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppNavBar(currentRoute: currentRoute),
                  child,
                  const AppFooter(),
                ],
              ),
            ),
          ),
          const FloatingHaenggungChatbot(),
        ],
      ),
    );
  }
}
