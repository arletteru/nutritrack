import 'package:flutter/material.dart';

/// Paleta de colores de Nutritrack.
///
/// Todos los colores viven aquí como constantes estáticas.
/// Los widgets NO deben referenciar hexadecimales directamente —
/// siempre usan [AppColors] o los tokens del [ThemeData].
abstract final class AppColors {
  // ── Primario: verde bosque ────────────────────────────────────────────────
  /// Acción principal, botones CTA, logo.
  static const primary = Color(0xFF2D5016);

  /// Hover / estados activos sobre el primario.
  static const primaryDark = Color(0xFF1E3A0F);

  /// Versión más clara para tintes, chips, badges.
  static const primaryLight = Color(0xFF4A7C2F);

  /// Fondo muy sutil con tinte verde (cards, selecciones).
  static const primaryContainer = Color(0xFFDDEDD0);

  /// Texto / íconos sobre [primaryContainer].
  static const onPrimaryContainer = Color(0xFF1A3A08);

  // ── Secundario: crema / tierra ────────────────────────────────────────────
  /// Superficies de fondo (scaffold, inputs).
  static const background = Color(0xFFF5F5EE);

  /// Superficie elevada (cards, bottom sheets, modales).
  static const surface = Color(0xFFEEEDE5);

  /// Superficie con mayor elevación (tooltips, menús).
  static const surfaceHigh = Color(0xFFE5E4DA);

  // ── Texto ─────────────────────────────────────────────────────────────────
  /// Texto principal sobre fondos claros.
  static const textPrimary = Color(0xFF1A1A1A);

  /// Texto secundario / placeholders.
  static const textSecondary = Color(0xFF6B6B55);

  /// Texto deshabilitado / hints.
  static const textHint = Color(0xFF9E9E8A);

  // ── Bordes ────────────────────────────────────────────────────────────────
  /// Borde sutil (divisores, inputs en reposo).
  static const border = Color(0xFFCCCCBB);

  /// Borde con foco (inputs activos).
  static const borderFocused = primary;

  // ── Semánticos ────────────────────────────────────────────────────────────
  static const error = Color(0xFF8B2500);
  static const errorContainer = Color(0xFFFFDAD4);
  static const onErrorContainer = Color(0xFF5C1200);

  static const success = Color(0xFF2D5016);
  static const successContainer = Color(0xFFDDEDD0);

  static const warning = Color(0xFF7A4F00);
  static const warningContainer = Color(0xFFFFDEAA);

  // ── Dark mode equivalentes ────────────────────────────────────────────────
  static const primaryDarkMode = Color(0xFF8FCA6B);
  static const backgroundDarkMode = Color(0xFF141710);
  static const surfaceDarkMode = Color(0xFF1E2119);
  static const surfaceHighDarkMode = Color(0xFF282C22);
  static const textPrimaryDarkMode = Color(0xFFE8EAE0);
  static const textSecondaryDarkMode = Color(0xFF9EA890);
  static const textHintDarkMode = Color(0xFF6B7260);
  static const borderDarkMode = Color(0xFF3A3E30);
}
