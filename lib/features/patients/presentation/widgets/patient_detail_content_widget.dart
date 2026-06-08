import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutritrack/core/theme/app_theme_extensions.dart';
import 'package:nutritrack/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:nutritrack/features/daily_log/presentation/providers/daily_log_providers.dart';

class PatientComplianceSection extends HookConsumerWidget {
  const PatientComplianceSection({super.key, required this.patientUid});
  final String patientUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Día seleccionado — por defecto hoy
    final selectedDay = useState<DateTime>(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    final todayLog = ref.watch(watchTodayLogProvider(patientUid));
    final recentLogs = ref.watch(watchRecentLogsProvider(patientUid));
    final tasks = ref.watch(watchTasksProvider(patientUid));

    // Calcular el log del día seleccionado
    final selectedDateKey =
        '${selectedDay.value.year}-${selectedDay.value.month.toString().padLeft(2, '0')}-${selectedDay.value.day.toString().padLeft(2, '0')}';

    final isToday = selectedDateKey ==
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

    final selectedLog = isToday
        ? todayLog.value
        : recentLogs.value
            ?.where((l) => l.dateKey == selectedDateKey)
            .firstOrNull;

    final totalTasks = tasks.value?.length ?? 0;
    final completed = selectedLog?.completedCount ?? 0;
    final rate = selectedLog?.completionRateOf(totalTasks) ?? 0.0;

    return Column(
      children: [
        // ── Racha semanal interactiva ─────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.calendar_view_week_outlined,
                      size: 18, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text('Esta semana', style: context.textTheme.titleSmall),
                  const Spacer(),
                  Text(
                    isToday
                        ? 'Hoy'
                        : DateFormat('d MMM', 'es_MX')
                            .format(selectedDay.value),
                    style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.primary),
                  ),
                ]),
                const SizedBox(height: 12),
                recentLogs.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (logs) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = DateTime.now()
                          .subtract(Duration(days: 6 - i));
                      final dayNormalized = DateTime(
                          day.year, day.month, day.day);
                      final key =
                          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                      final log =
                          logs.where((l) => l.dateKey == key).firstOrNull;
                      final dayRate = log?.completionRateOf(totalTasks) ?? 0.0;
                      final label = DateFormat('E', 'es_MX')
                          .format(day)
                          .substring(0, 1)
                          .toUpperCase();
                      final isDayToday = i == 6;
                      final isSelected =
                          dayNormalized == selectedDay.value;

                      return GestureDetector(
                        onTap: () => selectedDay.value = dayNormalized,
                        child: Column(children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? context.colors.primary
                                  : dayRate == 0
                                      ? context.colors
                                          .surfaceContainerHighest
                                      : context.colors.primary
                                          .withValues(alpha: dayRate * 0.7),
                              border: isDayToday && !isSelected
                                  ? Border.all(
                                      color: context.colors.primary,
                                      width: 2)
                                  : null,
                            ),
                            child: dayRate >= 0.8
                                ? Icon(Icons.check,
                                    size: 16,
                                    color: isSelected
                                        ? context.colors.onPrimary
                                        : context.colors.onPrimary)
                                : isSelected
                                    ? Icon(Icons.circle,
                                        size: 8,
                                        color: context.colors.onPrimary)
                                    : null,
                          ),
                          const SizedBox(height: 4),
                          Text(label,
                              style: context.textTheme.labelSmall
                                  ?.copyWith(
                                color: isSelected || isDayToday
                                    ? context.colors.primary
                                    : context.colors.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : null,
                              )),
                        ]),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Detalle del día seleccionado ──────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.checklist_outlined,
                      size: 18, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isToday
                          ? 'Tareas de hoy'
                          : 'Tareas del ${DateFormat('d MMMM', 'es_MX').format(selectedDay.value)}',
                      style: context.textTheme.titleSmall,
                    ),
                  ),
                  // Badge de progreso
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rate == 0
                          ? context.colors.surfaceContainerHighest
                          : rate >= 0.8
                              ? context.nutri.successContainer
                              : context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$completed/$totalTasks',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: rate == 0
                            ? context.colors.onSurfaceVariant
                            : rate >= 0.8
                                ? context.nutri.success
                                : context.colors.primary,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),

                // Barra de progreso
                LinearProgressIndicator(
                  value: rate,
                  backgroundColor:
                      context.colors.primary.withValues(alpha: .12),
                  color: rate >= 0.8
                      ? context.nutri.success
                      : context.colors.primary,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),

                const SizedBox(height: 12),

                // Lista de tareas con estado
                tasks.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text('Sin tareas',
                      style: context.textTheme.bodySmall),
                  data: (taskList) {
                    if (taskList.isEmpty) {
                      return Text(
                        'No hay tareas asignadas.',
                        style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant),
                      );
                    }
                    if (selectedLog == null) {
                      return Text(
                        'Sin registro para este día.',
                        style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant),
                      );
                    }
                    return Column(
                      children: taskList.map((task) {
                        final completion = selectedLog.taskCompletions
                            .where((c) => c.taskId == task.id)
                            .firstOrNull;
                        final done = completion?.completed ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: done
                                    ? context.nutri.successContainer
                                    : context.colors
                                        .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                    context.radiusSm),
                              ),
                              child: Icon(
                                _categoryIcon(task.category),
                                size: 16,
                                color: done
                                    ? context.nutri.success
                                    : context.colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                      decoration: done
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: done
                                          ? context
                                              .colors.onSurfaceVariant
                                          : null,
                                    ),
                                  ),
                                  if (task.description != null)
                                    Text(task.description!,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                                color: context.colors
                                                    .onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Icon(
                              done
                                  ? Icons.check_circle_outline
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: done
                                  ? context.nutri.success
                                  : context.colors.onSurfaceVariant,
                            ),
                          ]),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _categoryIcon(TaskCategory cat) => switch (cat) {
        TaskCategory.nutrition => Icons.restaurant_outlined,
        TaskCategory.hydration => Icons.water_drop_outlined,
        TaskCategory.exercise => Icons.fitness_center_outlined,
        TaskCategory.habit => Icons.self_improvement_outlined,
        TaskCategory.supplement => Icons.medication_outlined,
      };
}
