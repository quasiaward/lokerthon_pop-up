import 'package:flutter/material.dart';

import '../widgets/catering_section.dart';
import '../widgets/page_shell.dart';

class CateringPage extends StatelessWidget {
  const CateringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageShell(
      currentRoute: '/catering',
      backgroundColor: Color(0xFFFFF9F6),
      child: CateringSection(),
    );
  }
}
