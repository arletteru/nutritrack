import 'package:flutter/material.dart';

/// Escala tipográfica de Nutritrack basada en Material 3.
///
/// Usa la familia "Outfit" definida en pubspec.yaml.
/// Los widgets consumen esto vía [Theme.of(context).textTheme].
abstract final class AppTextTheme {
  static const _family = 'Outfit';

  static TextTheme get textTheme => const TextTheme(
        // ── Display ──────────────────────────────────────────────────────────
        // Titulares grandes tipo "Welcome back."
        displayLarge: TextStyle(
          fontFamily: _family,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontFamily: _family,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.15,
        ),
        displaySmall: TextStyle(
          fontFamily: _family,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),

        // ── Headline ─────────────────────────────────────────────────────────
        // Secciones, titles de page
        headlineLarge: TextStyle(
          fontFamily: _family,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: _family,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: _family,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),

        // ── Title ─────────────────────────────────────────────────────────────
        // Labels de campos, subtítulos de card
        titleLarge: TextStyle(
          fontFamily: _family,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: _family,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontFamily: _family,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),

        // ── Body ──────────────────────────────────────────────────────────────
        // Texto corrido, descripciones
        bodyLarge: TextStyle(
          fontFamily: _family,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontFamily: _family,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),
        bodySmall: TextStyle(
          fontFamily: _family,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),

        // ── Label ─────────────────────────────────────────────────────────────
        // Botones, chips, badges, caps
        labelLarge: TextStyle(
          fontFamily: _family,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: _family,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontFamily: _family,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.7,
        ),
      );
}
