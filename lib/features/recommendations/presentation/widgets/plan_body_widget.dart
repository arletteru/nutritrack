import 'package:flutter/material.dart';
import 'package:nutritrack/core/theme/app_theme_extensions.dart';
import 'package:nutritrack/features/recommendations/domain/entities/recommendation_entity.dart';

class PlanBody extends StatelessWidget {
  const PlanBody({super.key, required this.recommendation});
  final RecommendationEntity recommendation;

  @override
  Widget build(BuildContext context) {
    final guidelines =
        List<String>.from(recommendation.dietGuidelines );
    final habits = List<String>.from(recommendation.habits);
    final goals = List<String>.from(recommendation.goals );
    final notes = recommendation.additionalNotes;
    final modifications = recommendation.macroModifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Modificaciones de macros ───────────────────────────────────────
        if (modifications.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.pie_chart_outline,
            title: 'Plan de macronutrientes',
          ),
          const SizedBox(height: 12),
          ...modifications.map((m) {
            final mod = m;
            return _MacroCard(
              nutrient: mod['nutrient'] as String? ?? '',
              modification: mod['modification'] as String? ?? '',
              description: mod['description'] as String? ?? '',
            );
          }),
          const SizedBox(height: 20),
        ],

        // ── Guías dietéticas ───────────────────────────────────────────────
        if (guidelines.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.restaurant_menu_outlined,
            title: 'Guías alimentarias',
          ),
          const SizedBox(height: 12),
          _BulletList(items: guidelines),
          const SizedBox(height: 20),
        ],

        // ── Hábitos ────────────────────────────────────────────────────────
        if (habits.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.self_improvement_outlined,
            title: 'Hábitos a desarrollar',
          ),
          const SizedBox(height: 12),
          _BulletList(items: habits, color: context.nutri.success),
          const SizedBox(height: 20),
        ],

        // ── Metas ──────────────────────────────────────────────────────────
        if (goals.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.flag_outlined,
            title: 'Mis metas',
          ),
          const SizedBox(height: 12),
          _BulletList(items: goals, color: context.colors.primary),
          const SizedBox(height: 20),
        ],

        // ── Notas del nutriólogo ───────────────────────────────────────────
        if (notes != null && notes.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(context.radiusLg),
              border: Border.all(
                  color: context.colors.primary.withValues(alpha: .2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 18, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text('Nota de tu nutriólogo',
                      style: context.textTheme.titleSmall),
                ]),
                const SizedBox(height: 8),
                Text(notes, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Macro card ────────────────────────────────────────────────────────────────
class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.nutrient,
    required this.modification,
    required this.description,
  });
  final String nutrient;
  final String modification;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isPositive = modification.startsWith('+');
    final isNeutral = modification == 'Mantener';
    final color = isNeutral
        ? context.colors.onSurfaceVariant
        : isPositive
            ? context.nutri.success
            : context.colors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nutrient, style: context.textTheme.titleSmall),
                if (description.isNotEmpty)
                  Text(description,
                      style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(modification,
                style: context.textTheme.labelMedium?.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 20, color: context.colors.primary),
      const SizedBox(width: 8),
      Text(title, style: context.textTheme.headlineSmall),
    ]);
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items, this.color});
  final List<String> items;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bulletColor = color ?? context.colors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.radiusLg),
      ),
      child: Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: bulletColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item, style: context.textTheme.bodyMedium),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}