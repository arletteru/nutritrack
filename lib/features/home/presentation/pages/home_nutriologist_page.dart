import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../patients/presentation/providers/patients_providers.dart';
import '../../../schedule/domain/entities/appointment_entity.dart';
import '../../../schedule/presentation/providers/schedule_providers.dart';

class HomeNutriologistPage extends HookConsumerWidget {
  const HomeNutriologistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateChangesProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return _HomeContent(nutriologistId: user.uid, name: user.displayName ?? '');
      },
    );
  }
}

class _HomeContent extends HookConsumerWidget {
  const _HomeContent({required this.nutriologistId, required this.name});
  final String nutriologistId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = useState(0);
    final colors = context.colors;
    final today = DateFormat('EEEE, d MMMM', 'es_MX').format(DateTime.now());

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: IndexedStack(
          index: tabIndex.value,
          children: [
            _DashboardTab(nutriologistId: nutriologistId, name: name, today: today),
            _PatientsTab(nutriologistId: nutriologistId),
            _AgendaTab(nutriologistId: nutriologistId),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex.value,
        onDestinationSelected: (i) => tabIndex.value = i,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Pacientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
        ],
      ),
    );
  }
}

// ── Tab: Dashboard ────────────────────────────────────────────────────────────
class _DashboardTab extends HookConsumerWidget {
  const _DashboardTab({
    required this.nutriologistId,
    required this.name,
    required this.today,
  });
  final String nutriologistId;
  final String name;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAppts =
        ref.watch(watchTodayAppointmentsProvider(nutriologistId));
    final patients = ref.watch(watchPatientsProvider(nutriologistId));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: context.colors.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, ${name.split(' ').first}',
                  style: context.textTheme.headlineMedium),
              Text(today,
                  style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant)),
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
            const SizedBox(width: 8),
            _AvatarButton(name: name),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Citas de hoy
              Text('Hoy', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              todayAppts.when(
                loading: () => const _LoadingCard(),
                error: (e, _) => _ErrorCard(message: e.toString()),
                data: (appts) => appts.isEmpty
                    ? _EmptyCard(
                        icon: Icons.event_available_outlined,
                        message: 'No tienes citas hoy')
                    : Column(
                        children: appts
                            .map((a) => _AppointmentTile(appointment: a))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Estadísticas rápidas
              Row(
                children: [
                  Text('Resumen', style: context.textTheme.titleLarge),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              patients.when(
                loading: () => const _LoadingCard(),
                error: (e, _) => _ErrorCard(message: e.toString()),
                data: (list) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Pacientes\nactivos',
                        value: list.length.toString(),
                        icon: Icons.people_outline,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: todayAppts.maybeWhen(
                        data: (a) => _StatCard(
                          label: 'Citas\nhoy',
                          value: a.length.toString(),
                          icon: Icons.calendar_today_outlined,
                          color: context.nutri.success,
                        ),
                        orElse: () => const _LoadingCard(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Acceso rápido
              Text('Acciones rápidas', style: context.textTheme.titleLarge),
              const SizedBox(height: 12),
              _QuickActions(nutriologistId: nutriologistId),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Tab: Patients ─────────────────────────────────────────────────────────────
class _PatientsTab extends HookConsumerWidget {
  const _PatientsTab({required this.nutriologistId});
  final String nutriologistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = useTextEditingController();
    final searchQuery = useState('');
    final patientsAsync = ref.watch(watchPatientsProvider(nutriologistId));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: context.colors.surface,
          title: Text('Pacientes', style: context.textTheme.headlineMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Nuevo paciente',
              onPressed: () => context.push('/patients/new'),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: search,
                onChanged: (v) => searchQuery.value = v.toLowerCase(),
                decoration: const InputDecoration(
                  hintText: 'Buscar paciente...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ),
        patientsAsync.when(
          loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverFillRemaining(
              child: Center(child: Text(e.toString()))),
          data: (patients) {
            final filtered = searchQuery.value.isEmpty
                ? patients
                : patients
                    .where((p) =>
                        p.fullName
                            .toLowerCase()
                            .contains(searchQuery.value) ||
                        p.expediente.toLowerCase().contains(searchQuery.value))
                    .toList();
            if (filtered.isEmpty) {
              return SliverFillRemaining(
                child: _EmptyCard(
                  icon: Icons.person_search_outlined,
                  message: searchQuery.value.isEmpty
                      ? 'Aún no tienes pacientes'
                      : 'Sin resultados para "${searchQuery.value}"',
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _PatientListTile(patient: filtered[i]),
                  childCount: filtered.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Tab: Agenda ───────────────────────────────────────────────────────────────
class _AgendaTab extends HookConsumerWidget {
  const _AgendaTab({required this.nutriologistId});
  final String nutriologistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming =
        ref.watch(watchUpcomingAppointmentsProvider(nutriologistId));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: context.colors.surface,
          title: Text('Agenda', style: context.textTheme.headlineMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Nueva cita',
              onPressed: () => context.push('/appointments/new'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: upcoming.when(
            loading: () => const SliverToBoxAdapter(child: _LoadingCard()),
            error: (e, _) =>
                SliverToBoxAdapter(child: _ErrorCard(message: e.toString())),
            data: (appts) {
              if (appts.isEmpty) {
                return const SliverFillRemaining(
                  child: _EmptyCard(
                    icon: Icons.event_outlined,
                    message: 'No hay citas próximas',
                  ),
                );
              }
              // Agrupar por día
              final grouped = <String, List<AppointmentEntity>>{};
              for (final a in appts) {
                final key =
                    DateFormat('EEEE, d MMMM', 'es_MX').format(a.scheduledAt);
                grouped.putIfAbsent(key, () => []).add(a);
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final day = grouped.keys.elementAt(i);
                    final dayAppts = grouped[day]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(day,
                              style: context.textTheme.titleMedium?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                        ...dayAppts
                            .map((a) => _AppointmentTile(appointment: a)),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                  childCount: grouped.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});
  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(appointment.scheduledAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colors.primaryContainer,
          child: Text(
            appointment.patientName.isNotEmpty
                ? appointment.patientName[0].toUpperCase()
                : '?',
            style: TextStyle(color: context.colors.onPrimaryContainer),
          ),
        ),
        title: Text(appointment.patientName,
            style: context.textTheme.titleSmall),
        subtitle: Text(
          '${_typeLabel(appointment.type)} · $time',
          style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant),
        ),
        trailing: _StatusChip(status: appointment.status),
        onTap: () => context.push('/appointments/${appointment.id}'),
      ),
    );
  }

  String _typeLabel(AppointmentType t) => switch (t) {
        AppointmentType.firstConsult => '1ª consulta',
        AppointmentType.followUp => 'Seguimiento',
        AppointmentType.emergency => 'Urgencia',
      };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AppointmentStatus.scheduled => ('Agendada', context.colors.primary),
      AppointmentStatus.confirmed => ('Confirmada', context.nutri.success),
      AppointmentStatus.completed => ('Completada', context.colors.onSurfaceVariant),
      AppointmentStatus.cancelled => ('Cancelada', context.colors.error),
      AppointmentStatus.noShow => ('No asistió', context.colors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: context.textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

class _PatientListTile extends StatelessWidget {
  const _PatientListTile({required this.patient});
  final patient;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colors.primaryContainer,
          child: Text(patient.initials,
              style: TextStyle(color: context.colors.onPrimaryContainer)),
        ),
        title: Text(patient.fullName, style: context.textTheme.titleSmall),
        subtitle: Text(patient.expediente,
            style: context.textTheme.bodySmall
                ?.copyWith(color: context.colors.onSurfaceVariant)),
        trailing: patient.nextAppointment != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Próxima cita',
                      style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant)),
                  Text(
                    DateFormat('d/M/yy').format(patient.nextAppointment!),
                    style: context.textTheme.labelMedium
                        ?.copyWith(color: context.colors.primary),
                  ),
                ],
              )
            : null,
        onTap: () => context.push('/patients/${patient.id}'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: context.textTheme.headlineMedium
                        ?.copyWith(color: color)),
                Text(label,
                    style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.nutriologistId});
  final String nutriologistId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        
        Expanded(
          child: _QuickActionButton(
            icon: Icons.person_add_outlined,
            label: 'Nuevo\npaciente',
            onTap: () => context.push('/patients/new'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.event_outlined,
            label: 'Agendar\ncita',
            onTap: () => context.push('/appointments/new'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(context.radiusLg),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.colors.primary, size: 26),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}

class _AvatarButton extends ConsumerWidget {
  const _AvatarButton({required this.name});
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {},
      child: CircleAvatar(
        radius: 18,
        backgroundColor: context.colors.primaryContainer,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'N',
          style: TextStyle(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message,
              style: TextStyle(color: context.colors.error)),
        ),
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});
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
                  style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant)),
            ],
          ),
        ),
      );
}
