import 'package:flutter/material.dart';

import '../widgets/menu_section.dart';
import '../widgets/page_shell.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      currentRoute: '/menu',
      backgroundColor: const Color(0xFFF5F5F3),
      child: const MenuSection(),
    );
  }
}
