import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens adicionales que no existen en [ColorScheme] estándar de Material 3.
///
/// Acceso:
/// ```dart
/// final ext = Theme.of(context).extension<NutriColors>()!;
/// ext.success
/// ext.inputBackground
/// ```
@immutable
class NutriColors extends ThemeExtension<NutriColors> {
  const NutriColors({
    required this.inputBackground,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.textHint,
    required this.logo,
  });

  /// Fondo de los campos de texto (NutriTextField).
  final Color inputBackground;

  /// Color semántico de éxito (requisitos de contraseña cumplidos, etc.).
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  /// Color semántico de advertencia.
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  /// Texto de placeholder / hint dentro de inputs.
  final Color textHint;

  /// Color del logotipo / marca.
  final Color logo;

  // ── Variantes predefinidas ─────────────────────────────────────────────────

  static const light = NutriColors(
    inputBackground: AppColors.surface,
    success: AppColors.success,
    successContainer: AppColors.successContainer,
    onSuccessContainer: AppColors.onPrimaryContainer,
    warning: AppColors.warning,
    warningContainer: AppColors.warningContainer,
    onWarningContainer: Color(0xFF4A3300),
    textHint: AppColors.textHint,
    logo: AppColors.primary,
  );

  static const dark = NutriColors(
    inputBackground: AppColors.surfaceHighDarkMode,
    success: AppColors.primaryDarkMode,
    successContainer: Color(0xFF1E3A0F),
    onSuccessContainer: Color(0xFFB8E4A0),
    warning: Color(0xFFDDC400),
    warningContainer: Color(0xFF524500),
    onWarningContainer: Color(0xFFFFF1B8),
    textHint: AppColors.textHintDarkMode,
    logo: AppColors.primaryDarkMode,
  );

  // ── ThemeExtension API ────────────────────────────────────────────────────

  @override
  NutriColors copyWith({
    Color? inputBackground,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? textHint,
    Color? logo,
  }) {
    return NutriColors(
      inputBackground: inputBackground ?? this.inputBackground,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      textHint: textHint ?? this.textHint,
      logo: logo ?? this.logo,
    );
  }

  @override
  NutriColors lerp(NutriColors? other, double t) {
    if (other == null) return this;
    return NutriColors(
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      logo: Color.lerp(logo, other.logo, t)!,
    );
  }
}
