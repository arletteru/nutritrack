// Quién la usa: Paciente — desde HomePatientPage tab "Mi plan"
// Muestra el plan nutricional, macros, hábitos y metas que el nutriólogo
// generó a partir de la última consulta completa.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/features/recommendations/presentation/widgets/plan_body_widget.dart';

import '../../../../core/theme/theme.dart';
import '../providers/recommendations_providers.dart';


class MyPlanPage extends ConsumerWidget {
  const MyPlanPage({super.key, required this.patientId});
  final String patientId; // uid de Firebase Auth del paciente

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(watchLatestRecommendationProvider(patientId));

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Text('Mi plan', style: context.textTheme.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Ver mis consultas',
            onPressed: () =>
                context.push('/consultations/patient/$patientId'),
          ),
        ],
      ),
      body: recAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: TextStyle(color: context.colors.error)),
        ),
        data: (rec) => rec == null
            ? _EmptyPlan(patientId: patientId)
            : PlanBody(recommendation: rec),
      ),
    );
  }
}


class _EmptyPlan extends StatelessWidget {
  const _EmptyPlan({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu_outlined,
                size: 56, color: context.colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Sin plan asignado',
                style: context.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Tu nutriólogo generará tu plan nutricional después de tu primera consulta.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.history_outlined),
              label: const Text('Ver mis consultas'),
              onPressed: () =>
                  context.push('/consultations/patient/$patientId'),
            ),
          ],
        ),
      ),
    );
  }
}
