// Diálogo que aparece al finalizar la consulta preguntando
// si se quiere generar el plan nutricional automáticamente.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../recommendations/presentation/notifiers/generate_plan_notifier.dart';

class GeneratePlanDialog extends ConsumerWidget {
  const GeneratePlanDialog({
    super.key,
    required this.patientId,
    required this.patientUid,
    required this.nutriologistId,
    required this.consultationId,
    required this.step6Data,
  });

  final String patientId;
  final String patientUid;
  final String nutriologistId;
  final String consultationId;
  final Map<String, dynamic> step6Data;

  /// Muestra el diálogo y retorna true si se generó el plan.
  static Future<bool> show(
    BuildContext context, {
    required String patientId,
    required String patientUid,
    required String nutriologistId,
    required String consultationId,
    required Map<String, dynamic> step6Data,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => GeneratePlanDialog(
            patientId: patientId,
            patientUid: patientUid,
            nutriologistId: nutriologistId,
            consultationId: consultationId,
            step6Data: step6Data,
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generateState = ref.watch(generatePlanProvider);
    final notifier = ref.read(generatePlanProvider.notifier);

    // Cerrar automáticamente cuando termine
    ref.listen(generatePlanProvider, (_, next) {
      if (next is AsyncData && !next.isLoading) {
        Navigator.of(context).pop(true);
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error.toString()),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.of(context).pop(false);
      }
    });

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radiusXl),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(context.radiusMd),
            ),
            child: Icon(Icons.restaurant_menu_outlined,
                color: context.colors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('¿Generar plan\nnutricional?',
                style: context.textTheme.headlineSmall),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Se creará automáticamente a partir del diagnóstico:',
            style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _PlanPreviewItem(
            icon: Icons.pie_chart_outline,
            label: 'Plan de macronutrientes',
            detail: '${(step6Data['macroModifications'] as List?)?.length ?? 0} modificaciones',
          ),
          _PlanPreviewItem(
            icon: Icons.checklist_outlined,
            label: 'Recomendaciones generales',
            detail: '${(step6Data['generalRecommendations'] as List?)?.length ?? 0} indicaciones',
          ),
          _PlanPreviewItem(
            icon: Icons.task_alt_outlined,
            label: 'Tareas diarias para el paciente',
            detail: patientUid.isNotEmpty
                ? 'Visibles en su app'
                : 'Disponibles cuando se registre',
          ),
          if (patientUid.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.nutri.warningContainer,
                borderRadius: BorderRadius.circular(context.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: context.nutri.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El paciente aún no tiene cuenta. Las tareas se asignarán cuando se registre.',
                      style: context.textTheme.bodySmall?.copyWith(
                          color: context.nutri.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: generateState.isLoading
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Ahora no'),
        ),
        FilledButton.icon(
          icon: generateState.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.onPrimary,
                  ),
                )
              : const Icon(Icons.auto_awesome_outlined, size: 18),
          label: Text(generateState.isLoading ? 'Generando...' : 'Generar plan'),
          onPressed: generateState.isLoading
              ? null
              : () => notifier.generate(
                    patientId: patientId,
                    patientUid: patientUid,
                    nutriologistId: nutriologistId,
                    consultationId: consultationId,
                    step6Data: step6Data,
                  ),
        ),
      ],
    );
  }
}

class _PlanPreviewItem extends StatelessWidget {
  const _PlanPreviewItem({
    required this.icon,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.titleSmall),
                Text(detail,
                    style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
