import 'package:flutter/material.dart';

import '../widgets/page_shell.dart';
import '../widgets/reservation_section.dart';

class ExperiencePage extends StatelessWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageShell(
      currentRoute: '/experience',
      backgroundColor: Color(0xFFFFFEF8),
      child: ReservationSection(),
    );
  }
}
