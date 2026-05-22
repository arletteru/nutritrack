import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_theme_extension.dart';

/// Atajos de acceso al tema desde cualquier widget.
///
/// En lugar de escribir:
/// ```dart
/// Theme.of(context).colorScheme.primary
/// Theme.of(context).textTheme.displayLarge
/// Theme.of(context).extension<NutriColors>()!.success
/// ```
///
/// Puedes escribir:
/// ```dart
/// context.colors.primary
/// context.textTheme.displayLarge
/// context.nutri.success
/// ```
extension AppThemeX on BuildContext {
  /// Acceso al [ColorScheme] completo de Material 3.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Acceso a la escala tipográfica.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Tokens adicionales de Nutritrack ([NutriColors]).
  NutriColors get nutri => Theme.of(this).extension<NutriColors>()!;

  /// Radio estándar pequeño (8 px).
  double get radiusSm => AppTheme.radiusSm;

  /// Radio estándar medio (12 px).
  double get radiusMd => AppTheme.radiusMd;

  /// Radio estándar grande (16 px).
  double get radiusLg => AppTheme.radiusLg;

  /// Radio extra grande (24 px).
  double get radiusXl => AppTheme.radiusXl;

  /// Si el tema activo es dark mode.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
