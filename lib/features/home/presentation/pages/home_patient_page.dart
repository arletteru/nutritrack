import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutritrack/features/consultation/presentation/providers/consultation_providers.dart';
import 'package:nutritrack/features/daily_log/presentation/notifiers/daily_log_notifier.dart';
import 'package:nutritrack/features/home/presentation/widgets/weight_progress_card.dart';
import 'package:nutritrack/features/recommendations/presentation/providers/recommendations_providers.dart';
import 'package:nutritrack/features/recommendations/presentation/widgets/plan_body_widget.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../daily_log/domain/entities/daily_log_entity.dart';
import '../../../daily_log/presentation/providers/daily_log_providers.dart';
import '../../../schedule/domain/entities/appointment_entity.dart';
import '../../../schedule/presentation/providers/schedule_providers.dart';

class HomePatientPage extends HookConsumerWidget {
  const HomePatientPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);

    return userAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return _PatientHomeContent(
            patientId: user.uid, name: user.displayName ?? '');
      },
    );
  }
}

class _PatientHomeContent extends HookConsumerWidget {
  const _PatientHomeContent(
      {required this.patientId, required this.name});
  final String patientId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = useState(0);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: IndexedStack(
          index: tabIndex.value,
          children: [
            _OverviewTab(patientId: patientId, name: name),
            _DailyLogTab(patientId: patientId),
            _MyPlanTab(patientId: patientId),
            _AppointmentsTab(patientId: patientId),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex.value,
        onDestinationSelected: (i) => tabIndex.value = i,
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Mi plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Citas',
          ),
        ],
      ),
    );
  }
}

// ── Tab: Overview ─────────────────────────────────────────────────────────────
class _OverviewTab extends HookConsumerWidget {
  const _OverviewTab({required this.patientId, required this.name});
  final String patientId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(watchTodayLogProvider(patientId));
    final nextAppt =
        ref.watch(watchNextPatientAppointmentProvider(patientId));
    final recentLogs = ref.watch(watchRecentLogsProvider(patientId));
    final tasks = ref.watch(watchTasksProvider(patientId));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: context.colors.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, ${name.split(' ').first} 👋',
                  style: context.textTheme.headlineMedium),
              Text(
                DateFormat('EEEE, d MMMM', 'es_MX').format(DateTime.now()),
                style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Seguro que quieres salir?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.error,
                        ),
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref.read(signOutUseCaseProvider).call();
                }
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Progreso del día
              Text('Tu día', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              todayLog.when(
                loading: () => const _PatientLoadingCard(),
                error: (e, _) => Text(e.toString()),
                data: (log) => _TodayProgressCard(
                  log: log,
                  totalTasks: tasks.value?.length ?? 0,
                  ),
              ),
              const SizedBox(height: 20),

              // Próxima cita
              Text('Próxima cita', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              nextAppt.when(
                loading: () => const _PatientLoadingCard(),
                error: (e, _) => Text(e.toString()),
                data: (appt) => appt == null
                    ? _PatientEmptyCard(
                        icon: Icons.event_outlined,
                        message: 'No tienes citas programadas')
                    : _NextAppointmentCard(appointment: appt),
              ),
              const SizedBox(height: 20),
              
              Text('Mi progreso', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              WeightProgressCard(patientUid: patientId),
              const SizedBox(height: 20),
              
              
              // Racha semanal
              Text('Esta semana', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              recentLogs.when(
                loading: () => const _PatientLoadingCard(),
                error: (e, _) => Text(e.toString()),
                data: (logs) => _WeeklyStreakCard(
                  logs: logs, 
                  totalTasks: tasks.value?.length ?? 0,
                  ),
              ),
              const SizedBox(height: 32),
              Text('Mi consulta', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              _LatestConsultationCard(patientId: patientId),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Tab: Daily Log ────────────────────────────────────────────────────────────
class _DailyLogTab extends HookConsumerWidget {
  const _DailyLogTab({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(watchTasksProvider(patientId));
    final todayLog = ref.watch(watchTodayLogProvider(patientId));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: context.colors.surface,
          title: Text('Hoy', style: context.textTheme.headlineMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              onPressed: () => context.push('/log/notes/$patientId'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: tasks.when(
            loading: () =>
                const SliverToBoxAdapter(child: _PatientLoadingCard()),
            error: (e, _) =>
                SliverToBoxAdapter(child: Text(e.toString())),
            data: (taskList) {
              if (taskList.isEmpty) {
                return SliverFillRemaining(
                  child: _PatientEmptyCard(
                    icon: Icons.checklist_outlined,
                    message:
                        'Tu nutriólogo aún no ha asignado tareas',
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final task = taskList[i];
                    return todayLog.maybeWhen(
                      data: (log) {
                        final completion = log?.taskCompletions
                            .where((c) => c.taskId == task.id)
                            .firstOrNull;
                        return _TaskCheckTile(
                          task: task,
                          isCompleted: completion?.completed ?? false,
                          patientId: patientId,
                        );
                      },
                      orElse: () => _TaskCheckTile(
                        task: task,
                        isCompleted: false,
                        patientId: patientId,
                      ),
                    );
                  },
                  childCount: taskList.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Tab: My Plan ──────────────────────────────────────────────────────────────
// ── Tab: My Plan ──────────────────────────────────────────────────────────────
class _MyPlanTab extends ConsumerWidget {
  const _MyPlanTab({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(watchLatestRecommendationProvider(patientId));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: context.colors.surface,
          title: Text('Mi plan', style: context.textTheme.headlineMedium),
        ),
        recAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(child: Text(e.toString())),
          ),
          data: (rec) => rec == null
              ? SliverFillRemaining(
                  child: _EmptyPlanInline(patientId: patientId),
                )
              : SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16),
                      // Reutiliza _PlanBody de my_plan_page.dart
                      child: PlanBody(recommendation: rec),
                    ),
                  ]),
                ),
        ),
      ],
    );
  }
}

class _EmptyPlanInline extends StatelessWidget {
  const _EmptyPlanInline({required this.patientId});
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
          ],
        ),
      ),
    );
  }
}

// ── Tab: Appointments ─────────────────────────────────────────────────────────
class _AppointmentsTab extends HookConsumerWidget {
  const _AppointmentsTab({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = ref.watch(watchNextPatientAppointmentProvider(patientId));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: context.colors.surface,
          title: Text('Mis citas', style: context.textTheme.headlineMedium),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('Próxima', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              next.when(
                loading: () => const _PatientLoadingCard(),
                error: (e, _) => Text(e.toString()),
                data: (appt) => appt == null
                    ? _PatientEmptyCard(
                        icon: Icons.event_outlined,
                        message: 'No hay citas programadas')
                    : _NextAppointmentCard(appointment: appt),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Cards específicos del paciente ────────────────────────────────────────────

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({required this.log, required this.totalTasks});
  final DailyLogEntity? log;
  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    final completed = log?.completedCount ?? 0;
    final total = totalTasks;
    final rate = log?.completionRateOf(totalTasks) ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${(rate * 100).toStringAsFixed(0)}%',
                    style: context.textTheme.displaySmall
                        ?.copyWith(color: context.colors.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$completed de $total tareas completadas',
                          style: context.textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: rate,
                        backgroundColor:
                            context.colors.primary.withOpacity(0.15),
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tu nutriólogo asignará tareas después de tu consulta',
                  style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment});
  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE d MMMM, HH:mm', 'es_MX')
        .format(appointment.scheduledAt);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final apptDate = DateTime(
      appointment.scheduledAt.year,
      appointment.scheduledAt.month,
      appointment.scheduledAt.day,
    );
    final daysLeft = apptDate.difference(todayDate).inDays;

    return Card(
      color: context.colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.event_outlined,
                color: context.colors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date,
                      style: context.textTheme.titleSmall?.copyWith(
                          color: context.colors.onPrimaryContainer)),
                  Text(
                    daysLeft == 0
                        ? 'Es hoy'
                        : daysLeft == 1
                            ? 'Mañana'
                            : 'En $daysLeft días',
                    style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyStreakCard extends StatelessWidget {
  const _WeeklyStreakCard({required this.logs, required this.totalTasks});
  final List<DailyLogEntity> logs;
  final int totalTasks;
  

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cumplimiento diario',
                style: context.textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = DateTime.now().subtract(Duration(days: 6 - i));
                final key =
                    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                final log = logs.where((l) => l.dateKey == key).firstOrNull;
                final rate = log?.completionRateOf(totalTasks) ?? 0.0;
                final label = DateFormat('E', 'es_MX')
                    .format(day)
                    .substring(0, 1)
                    .toUpperCase();
                return Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rate == 0
                            ? context.colors.surfaceContainerHighest
                            : context.colors.primary.withOpacity(rate),
                      ),
                      child: rate >= 0.8
                          ? Icon(Icons.check,
                              size: 16,
                              color: context.colors.onPrimary)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: context.textTheme.labelSmall?.copyWith(
                            color:
                                context.colors.onSurfaceVariant)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCheckTile extends ConsumerWidget {
  const _TaskCheckTile({
    required this.task,
    required this.isCompleted,
    required this.patientId,
  });
  final TaskEntity task;
  final bool isCompleted;
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggleAsync = ref.watch(toggleTaskProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isCompleted,
        onChanged: toggleAsync.isLoading
            ? null
            : (val) => ref
                .read(toggleTaskProvider.notifier)
                .toggle(
                  patientId: patientId,
                  taskId: task.id,
                  completed: val ?? false,
                ),
        title: Text(task.title,
            style: context.textTheme.titleSmall?.copyWith(
              decoration:
                  isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted
                  ? context.colors.onSurfaceVariant
                  : null,
            )),
        subtitle: task.description != null
            ? Text(task.description!,
                style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant))
            : null,
        secondary: Icon(
          _categoryIcon(task.category),
          color:
              isCompleted ? context.colors.onSurfaceVariant : context.colors.primary,
        ),
        activeColor: context.colors.primary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.radiusLg)),
      ),
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

class _PatientLoadingCard extends StatelessWidget {
  const _PatientLoadingCard();
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator())),
      );
}

class _PatientEmptyCard extends StatelessWidget {
  const _PatientEmptyCard({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: context.colors.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant)),
            ],
          ),
        ),
      );
}

class _LatestConsultationCard extends ConsumerWidget {
  const _LatestConsultationCard({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultationAsync =
        ref.watch(watchLatestPatientConsultationProvider(patientId));

    return consultationAsync.when(
      loading: () => const _PatientLoadingCard(),
      error: (e, _) => const SizedBox.shrink(),
      data: (consultation) {
        // Si no hay ninguna consulta, no mostramos nada
        if (consultation == null) return const SizedBox.shrink();

        final id = consultation['id'] as String;
        final type = consultation['type'] as String? ?? 'first';
        final status = consultation['status'] as String? ?? 'draft';
        final isComplete = status == 'complete';
        final typeLabel =
            type == 'first' ? 'Primera consulta' : 'Seguimiento';

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(context.radiusLg),
            onTap: () => context.push(
              '/consultation/$id/summary',
              extra: {
                'isNutriologist': false, // es el paciente quien ve
                'data': consultation,    // el Map completo del doc
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mi última consulta',
                            style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant)),
                        const SizedBox(height: 2),
                        Text(typeLabel,
                            style: context.textTheme.titleSmall),
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
      },
    );
  }
}
