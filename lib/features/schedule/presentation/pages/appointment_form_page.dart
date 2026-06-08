import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/appointment_entity.dart';
import '../providers/schedule_providers.dart';

part 'appointment_form_page.g.dart';

@riverpod
class CreateAppointmentNotifier extends _$CreateAppointmentNotifier {
  @override
  FutureOr<void> build() => null;

  Future<void> create({
    required String patientId,      // doc ID de patients/
    required String patientUid,     // uid de Firebase Auth (puede ser vacío)
    required String patientName,
    required String nutriologistId,
    required DateTime scheduledAt,
    required AppointmentType type,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(appointmentsRepositoryProvider).createAppointment({
        'patientId': patientId,       // doc ID — para queries del nutriólogo
        'patientUid': patientUid,     // uid — para queries del paciente
        'patientName': patientName,
        'nutriologistId': nutriologistId,
        'scheduledAt': scheduledAt,
        'type': type.name,
        'status': AppointmentStatus.scheduled.name,
        'durationMinutes': 60,
        'notes': notes,
      }),
    );
  }
}

class AppointmentFormPage extends HookConsumerWidget {
  const AppointmentFormPage({
    super.key,
    this.patientId,      // doc ID — siempre tiene valor
    this.patientUid,     // uid — puede ser vacío si no se registró
    this.patientName,    // nombre ya conocido — no hay que escribirlo
  });

  final String? patientId;
  final String? patientUid;
  final String? patientName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final notesCtrl = useTextEditingController();
    final selectedDate = useState<DateTime?>(null);
    final selectedType = useState(AppointmentType.firstConsult);
    final notifier = ref.read(createAppointmentProvider.notifier);
    final state = ref.watch(createAppointmentProvider);

    ref.listen(createAppointmentProvider, (_, next) {
      if (next is AsyncData && !next.isLoading) context.pop();
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
        title: const Text('Nueva cita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Paciente — solo lectura, ya viene del detalle ─────────────
              if (patientName != null) ...[
                Text('Paciente',
                    style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(context.radiusMd),
                  ),
                  child: Text(patientName!,
                      style: context.textTheme.bodyLarge),
                ),
                const SizedBox(height: 20),
              ],

              // ── Fecha y hora ──────────────────────────────────────────────
              Text('Fecha y hora',
                  style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      letterSpacing: 0.8)),
              const SizedBox(height: 6),
              Card(
                child: ListTile(
                  leading: Icon(Icons.calendar_month,
                      color: context.colors.primary),
                  title: Text(
                    selectedDate.value != null
                        ? DateFormat('EEEE d MMMM, HH:mm', 'es_MX')
                            .format(selectedDate.value!)
                        : 'Seleccionar fecha y hora',
                    style: selectedDate.value != null
                        ? context.textTheme.bodyMedium
                        : context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        selectedDate.value = DateTime(date.year,
                            date.month, date.day, time.hour, time.minute);
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Tipo de cita ──────────────────────────────────────────────
              Text('Tipo de cita',
                  style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              SegmentedButton<AppointmentType>(
                segments: const [
                  ButtonSegment(
                      value: AppointmentType.firstConsult,
                      label: Text('1ª consulta'),
                      icon: Icon(Icons.person_add_outlined)),
                  ButtonSegment(
                      value: AppointmentType.followUp,
                      label: Text('Seguimiento'),
                      icon: Icon(Icons.repeat_outlined)),
                ],
                selected: {selectedType.value},
                onSelectionChanged: (s) => selectedType.value = s.first,
              ),

              const SizedBox(height: 20),

              // ── Notas opcionales ──────────────────────────────────────────
              Text('Notas (opcional)',
                  style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      letterSpacing: 0.8)),
              const SizedBox(height: 6),
              TextFormField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Indicaciones previas, recordatorios...'),
              ),

              const SizedBox(height: 32),

              // ── Guardar ───────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (selectedDate.value == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Selecciona fecha y hora'),
                                backgroundColor: context.colors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          final user = ref
                              .read(authStateChangesProvider)
                              .value;
                          notifier.create(
                            patientId: patientId ?? '',
                            patientUid: patientUid ?? '',
                            patientName: patientName ?? '',
                            nutriologistId: user?.uid ?? '',
                            scheduledAt: selectedDate.value!,
                            type: selectedType.value,
                            notes: notesCtrl.text.isNotEmpty
                                ? notesCtrl.text
                                : null,
                          );
                        },
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar cita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}