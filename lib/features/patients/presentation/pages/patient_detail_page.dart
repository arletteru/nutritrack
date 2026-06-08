import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/features/patients/presentation/widgets/patient_detail_content_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/patient_entity.dart';
import '../notifiers/sync_notifier.dart';
import '../providers/patients_providers.dart';

part 'patient_detail_page.g.dart';

@riverpod
Future<PatientEntity?> patientDetail(
  Ref ref,
  String patientId,
) =>
    ref.watch(getPatientUseCaseProvider).call(patientId);

class PatientDetailPage extends HookConsumerWidget {
  const PatientDetailPage({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailProvider(patientId));

    return patientAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detalle del paciente')),
        body: Center(
          child: Text(e.toString(),
              style: TextStyle(color: context.colors.error)),
        ),
      ),
      data: (patient) {
        if (patient == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle del paciente')),
            body: const Center(child: Text('Paciente no encontrado')),
          );
        }
        return _PatientDetailContent(patient: patient);
      },
    );
  }
}

class _PatientDetailContent extends ConsumerWidget {
  const _PatientDetailContent({required this.patient});
  final PatientEntity patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateChangesProvider).value;
    final syncState = ref.watch(syncPatientHistoryProvider);
    final syncNotifier =
        ref.read(syncPatientHistoryProvider.notifier);

    // Mostrar resultado de la sincronización
    ref.listen(syncPatientHistoryProvider, (_, next) {
      if (next is AsyncData && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Historial sincronizado correctamente ✓'),
          backgroundColor: context.nutri.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error.toString()),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Text(patient.fullName,
            style: context.textTheme.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: context.colors.primaryContainer,
                    child: Text(
                      patient.initials,
                      style: context.textTheme.headlineLarge
                          ?.copyWith(color: context.colors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.fullName,
                            style: context.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(patient.email,
                            style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text('Exp. ${patient.expediente}',
                            style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        // Badge de estado de registro
                        _RegistrationBadge(hasUid: patient.uid.isNotEmpty),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Banner de sincronización ──────────────────────────────────────
          // Solo aparece cuando el paciente ya se registró (tiene uid)
          // pero puede que sus consultas/citas no estén sincronizadas
          if (patient.uid.isNotEmpty)
            _SyncBanner(
              isSyncing: syncState.isLoading,
              onSync: () => syncNotifier.sync(
                patientDocId: patient.id,
                patientUid: patient.uid,
                nutriologistId: currentUser?.uid ?? '',
              ),
            ),

          const SizedBox(height: 12),

          // ── Acciones ──────────────────────────────────────────────────────
          Text('Acciones', style: context.textTheme.titleLarge),
          const SizedBox(height: 12),

          _ActionTile(
            icon: Icons.folder_open_outlined,
            label: 'Historial de consultas',
            subtitle: 'Ver y gestionar consultas anteriores',
            onTap: () => context.push(
              '/patients/${patient.id}/consultations'
              '?uid=${patient.uid}'
              '&nutriologistId=${currentUser?.uid ?? ''}'
              '&name=${Uri.encodeComponent(patient.fullName)}',
            ),
          ),
          _ActionTile(
            icon: Icons.monitor_heart_outlined,
            label: 'Expediente clínico',
            subtitle: 'Gráficas de evolución y bioquímicos',
            onTap: () => context.push(
              '/patients/${patient.id}/clinical'
              '?uid=${patient.uid}'
              '&nutriologistId=${currentUser?.uid ?? ''}'
              '&name=${Uri.encodeComponent(patient.fullName)}',
            ),
          ),
          _ActionTile(
            icon: Icons.note_add_outlined,
            label: 'Nueva consulta',
            subtitle: 'Iniciar un nuevo registro clínico',
            onTap: () => context.push(
              '/consultation/new'
              '?patientId=${patient.id}'
              '&patientUid=${patient.uid}'
              '&name=${Uri.encodeComponent(patient.fullName)}'
              '&expediente=${Uri.encodeComponent(patient.expediente)}',
            ),
          ),
          _ActionTile(
            icon: Icons.event_outlined,
            label: 'Agendar cita',
            subtitle: 'Programar próxima consulta',
            onTap: () => context.push(
              '/appointments/new'
              '?patientId=${patient.id}'
              '&patientUid=${patient.uid}'
              '&name=${Uri.encodeComponent(patient.fullName)}',
            ),
          ),
          if (patient.uid.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Seguimiento del paciente', style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
            PatientComplianceSection(patientUid: patient.uid),
          ],
        ],
      ),
    );
  }
}

// ── Banner de sincronización ──────────────────────────────────────────────────
class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.isSyncing, required this.onSync});
  final bool isSyncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(context.radiusLg),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_outlined,
              color: context.colors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paciente registrado',
                  style: context.textTheme.titleSmall?.copyWith(
                      color: context.colors.onPrimaryContainer),
                ),
                Text(
                  'Sincroniza para que el paciente vea su historial.',
                  style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isSyncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.primary,
                  ),
                )
              : FilledButton(
                  onPressed: onSync,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Sincronizar'),
                ),
        ],
      ),
    );
  }
}

// ── Badge de estado ───────────────────────────────────────────────────────────
class _RegistrationBadge extends StatelessWidget {
  const _RegistrationBadge({required this.hasUid});
  final bool hasUid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: hasUid
            ? context.nutri.successContainer
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasUid
                ? Icons.check_circle_outline
                : Icons.person_outline,
            size: 12,
            color: hasUid
                ? context.nutri.success
                : context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            hasUid ? 'Registrado en app' : 'Sin cuenta aún',
            style: context.textTheme.labelSmall?.copyWith(
              color: hasUid
                  ? context.nutri.success
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ActionTile ────────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(context.radiusMd),
          ),
          child: Icon(icon, color: context.colors.primary, size: 22),
        ),
        title: Text(label, style: context.textTheme.titleSmall),
        subtitle: Text(subtitle,
            style: context.textTheme.bodySmall
                ?.copyWith(color: context.colors.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right,
            color: context.colors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
