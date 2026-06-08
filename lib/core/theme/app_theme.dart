import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';

/// Punto de entrada único para los temas de Nutritrack.
///
/// Uso en [MaterialApp]:
/// ```dart
/// MaterialApp.router(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class AppTheme {
  // ── Radios de borde globales ───────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 100; // píldora

  // ── Elevaciones ───────────────────────────────────────────────────────────
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMid = 3;

  // =========================================================================
  // LIGHT THEME
  // =========================================================================
  static ThemeData get light => _build(
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        statusBarBrightness: Brightness.dark, // íconos oscuros sobre fondo claro
      );

  // =========================================================================
  // DARK THEME
  // =========================================================================
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        statusBarBrightness: Brightness.light,
      );

  // =========================================================================
  // COLOR SCHEMES
  // =========================================================================

  static ColorScheme get _lightColorScheme => const ColorScheme(
        brightness: Brightness.light,

        // Primario
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,

        // Secundario (tierra / ocre cálido para acentos complementarios)
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.primaryContainer,
        onSecondaryContainer: AppColors.onPrimaryContainer,

        // Terciario (reservado para acentos futuros)
        tertiary: Color(0xFF6D5E00),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFFFF1B8),
        onTertiaryContainer: Color(0xFF221B00),

        // Error
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,

        // Superficies
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceHigh,
        onSurfaceVariant: AppColors.textSecondary,

        // Fondo general
        // ignore: deprecated_member_use
        background: AppColors.background,
        // ignore: deprecated_member_use
        onBackground: AppColors.textPrimary,

        // Outline
        outline: AppColors.border,
        outlineVariant: Color(0xFFE0DFD5),

        // Misc
        shadow: Color(0x1A000000),
        scrim: Color(0x52000000),
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.background,
        inversePrimary: AppColors.primaryDarkMode,
      );

  static ColorScheme get _darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,

        primary: AppColors.primaryDarkMode,
        onPrimary: Color(0xFF0F2800),
        primaryContainer: Color(0xFF1E3A0F),
        onPrimaryContainer: Color(0xFFB8E4A0),

        secondary: Color(0xFF8FCA6B),
        onSecondary: Color(0xFF0F2800),
        secondaryContainer: Color(0xFF1E3A0F),
        onSecondaryContainer: Color(0xFFB8E4A0),

        tertiary: Color(0xFFDDC400),
        onTertiary: Color(0xFF3A3000),
        tertiaryContainer: Color(0xFF524500),
        onTertiaryContainer: Color(0xFFFFF1B8),

        error: Color(0xFFFFB4A8),
        onError: Color(0xFF5C1200),
        errorContainer: Color(0xFF7E2200),
        onErrorContainer: Color(0xFFFFDAD4),

        surface: AppColors.surfaceDarkMode,
        onSurface: AppColors.textPrimaryDarkMode,
        surfaceContainerHighest: AppColors.surfaceHighDarkMode,
        onSurfaceVariant: AppColors.textSecondaryDarkMode,

        // ignore: deprecated_member_use
        background: AppColors.backgroundDarkMode,
        // ignore: deprecated_member_use
        onBackground: AppColors.textPrimaryDarkMode,

        outline: AppColors.borderDarkMode,
        outlineVariant: Color(0xFF2E3228),

        shadow: Color(0x40000000),
        scrim: Color(0x70000000),
        inverseSurface: AppColors.textPrimaryDarkMode,
        onInverseSurface: AppColors.backgroundDarkMode,
        inversePrimary: AppColors.primary,
      );

  // =========================================================================
  // BUILDER
  // =========================================================================

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Brightness statusBarBrightness,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Outfit',
      textTheme: AppTextTheme.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: colorScheme.surface,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
          statusBarBrightness:
              isDark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: AppTextTheme.textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.55),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
          shape: const StadiumBorder(),
          textStyle: AppTextTheme.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          shape: const StadiumBorder(),
          minimumSize: const Size(0, 52),
          textStyle: AppTextTheme.textTheme.titleMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTextTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── InputDecoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceHighDarkMode
            : AppColors.surface,
        hintStyle: AppTextTheme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
      ),

      // ── Checkbox ──────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AppColors.surfaceHighDarkMode
            : AppColors.textPrimary,
        contentTextStyle: AppTextTheme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.textPrimaryDarkMode : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 4,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Ripple / Splash ───────────────────────────────────────────────────
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
