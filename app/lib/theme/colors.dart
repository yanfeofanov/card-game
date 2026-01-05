// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Получаем цвета из текущей темы
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color primaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceVariant;

  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.background;

  static Color onBackground(BuildContext context) =>
      Theme.of(context).colorScheme.onBackground;

  // Статические цвета (не зависят от темы)
  static const Color rarityCommon = Color(0xFF808080);
  static const Color rarityRare = Color(0xFF4A90E2);
  static const Color rarityEpic = Color(0xFF9B59B6);
  static const Color rarityLegendary = Color(0xFFF1C40F);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF2196F3);
}
