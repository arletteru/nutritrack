// features/consultation/presentation/pages/consultations_list_page.dart
//
// CAPA: Presentation
// Quién la usa: Nutriólogo — desde PatientDetailPage.
// Muestra el historial de consultas de un paciente y permite abrir el resumen.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/consultation_entity.dart';
import '../providers/consultation_providers.dart';

part 'consultations_list_page.g.dart';

// ── Provider local ────────────────────────────────────────────────────────────
@riverpod
Stream<List<Map<String, dynamic>>> watchPatientConsultations(
  Ref ref,
  String patientUid,                                         // ← uid, no el doc id
) =>
    ref
        .watch(consultationRepositoryProvider)
        .watchPatientConsultations(patientUid);      

// ── Page ──────────────────────────────────────────────────────────────────────
class ConsultationsListPage extends ConsumerWidget {
  const ConsultationsListPage({
    super.key,
    required this.patientId,    // ID del documento — solo para navegar a nueva consulta
    required this.patientUid,   // uid de Firebase Auth — para la query de Firestore
    required this.patientName,
    this.nutriologistId,
  });

  final String patientId;
  final String patientUid;
  final String patientName;
  final String? nutriologistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultationsAsync = nutriologistId != null
        ? ref.watch(watchConsultationsByNutriologistProvider(
            patientId: patientId,
            nutriologistId: nutriologistId!,
          ))
        : ref.watch(watchPatientConsultationsProvider(patientUid));

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historial clínico',
                style: context.textTheme.headlineMedium),
            Text(patientName,
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.colors.onSurfaceVariant)),
          ],
        ),
        actions: [
          FilledButton.icon(
            icon: const Icon(Icons.note_add_outlined, size: 18),
            label: const Text('Nueva'),
            onPressed: () => context.push(
              '/consultation/new'
              '?patientId=$patientId'      
              '&patientUid=$patientUid',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: consultationsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(message: e.toString()),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyBody(patientId: patientId, patientUid: patientUid,); 
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) =>
                _ConsultationCard(data: list[i]),
          );
        },
      ),
    );
  }
}

// ── Consultation card ─────────────────────────────────────────────────────────
class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final id = data['id'] as String;
    final type = data['type'] as String? ?? 'first';
    final status = data['status'] as String? ?? 'draft';
    final currentStep = data['currentStep'] as int? ?? 1;
    final createdAt = data['createdAt'];

    String formattedDate = '—';
    if (createdAt != null) {
      try {
        final dt = createdAt is String
            ? DateTime.parse(createdAt)
            : (createdAt as dynamic).toDate() as DateTime;
        formattedDate =
            DateFormat('d MMMM yyyy, HH:mm', 'es_MX').format(dt);
      } catch (_) {}
    }

    final isComplete = status == ConsultationStatus.complete.name;
    final typeLabel =
        type == 'first' ? 'Primera consulta' : 'Seguimiento';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(context.radiusLg),
        onTap: () {
          if (!isComplete) {
            // Borrador → continuar llenando
            context.push('/consultation/new?consultationId=$id');
          } else {
            // Completa → ver resumen
            context.push(
              '/consultation/$id/summary',
              extra: {'isNutriologist': true, 'data': data},
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono de estado
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isComplete
                      ? context.colors.primaryContainer
                      : context.colors.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(context.radiusMd),
                ),
                child: Icon(
                  isComplete
                      ? Icons.check_circle_outline
                      : Icons.pending_outlined,
                  color: isComplete
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(typeLabel,
                          style: context.textTheme.titleSmall),
                      const SizedBox(width: 8),
                      _StatusBadge(isComplete: isComplete),
                    ]),
                    const SizedBox(height: 4),
                    Text(formattedDate,
                        style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant)),
                    if (!isComplete) ...[
                      const SizedBox(height: 6),
                      // Barra de progreso del wizard
                      Row(children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (currentStep - 1) / 6,
                            backgroundColor: context.colors.primary
                                .withValues(alpha: 0.12),
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Paso ${currentStep - 1}/6',
                            style: context.textTheme.labelSmall
                                ?.copyWith(
                                    color: context
                                        .colors.onSurfaceVariant)),
                      ]),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: context.colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isComplete});
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isComplete
            ? context.colors.primaryContainer
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isComplete ? 'Completa' : 'Borrador',
        style: context.textTheme.labelSmall?.copyWith(
          color: isComplete
              ? context.colors.primary
              : context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.patientId, required this.patientUid});
  final String patientId;
  final String patientUid;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 56, color: context.colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Sin consultas',
                style: context.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Este paciente aún no tiene consultas registradas.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Iniciar primera consulta'),
              onPressed: () => context.push(
              '/consultation/new'
              '?patientId=$patientId'      
              '&patientUid=$patientUid',
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message,
            style: TextStyle(color: context.colors.error)),
      ),
    );
  }
}
