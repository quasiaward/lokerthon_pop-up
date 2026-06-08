import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.cinnabar,
      brightness: Brightness.light,
      surface: AppColors.paper,
    ),
    scaffoldBackgroundColor: AppColors.cream,
  );

  return base.copyWith(
    visualDensity: VisualDensity.standard,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.deep,
      displayColor: AppColors.deep,
      fontFamily: 'Gowun Batang',
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.wheat.withValues(alpha: 0.7),
      thickness: 1,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.muted,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deep,
        foregroundColor: AppColors.paper,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deep,
        side: BorderSide(color: AppColors.deep.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: AppColors.wheat),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.deep,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentTextStyle: const TextStyle(
        color: AppColors.paper,
        fontWeight: FontWeight.w600,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.paper,
      headerBackgroundColor: AppColors.deep,
      headerForegroundColor: AppColors.paper,
      todayBorder: const BorderSide(color: AppColors.gold),
      todayForegroundColor: WidgetStateProperty.all(AppColors.cinnabar),
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.paper
            : AppColors.deep,
      ),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? AppColors.cinnabar : null,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.hanji.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.wheat),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.wheat),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      hintStyle: TextStyle(
        color: AppColors.muted.withValues(alpha: 0.58),
        fontWeight: FontWeight.w300,
      ),
    ),
  );
}
