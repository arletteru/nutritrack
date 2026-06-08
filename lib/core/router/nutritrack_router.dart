import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutritrack/features/auth/presentation/pages/login_page.dart';
import 'package:nutritrack/features/auth/presentation/pages/register_page.dart';
import 'package:nutritrack/features/auth/presentation/pages/splash_page.dart';
import 'package:nutritrack/features/consultation/presentation/pages/consultation_summary_page.dart';
import 'package:nutritrack/features/consultation/presentation/pages/consultation_wizard_page.dart';
import 'package:nutritrack/features/consultation/presentation/pages/consultations_list_page.dart';
import 'package:nutritrack/features/daily_log/presentation/pages/log_notes_page.dart';
import 'package:nutritrack/features/home/presentation/pages/home_nutriologist_page.dart';
import 'package:nutritrack/features/home/presentation/pages/home_patient_page.dart';
import 'package:nutritrack/features/patients/presentation/pages/patient_detail_page.dart';
import 'package:nutritrack/features/patients/presentation/pages/patient_form_page.dart';
import 'package:nutritrack/features/recommendations/presentation/pages/my_plan_page.dart';
import 'package:nutritrack/features/schedule/presentation/pages/appointment_detail_page.dart';
import 'package:nutritrack/features/schedule/presentation/pages/appointment_form_page.dart';
import 'package:nutritrack/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:nutritrack/features/patients/presentation/pages/clinical_record_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

part 'nutritrack_router.g.dart';

// ── Notifier que despierta al router cuando el stream de auth cambia ──────────
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue>(authStateChangesProvider, (_, next) {
      if (!next.isLoading) {
        Future.delayed(const Duration(milliseconds: 500), () {
          notifyListeners();
        });
      }
    });
  }
  final Ref _ref;
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateChangesProvider);
      final location = state.matchedLocation;

      if (authAsync.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      if (authAsync.hasError) return '/login';

      final user = authAsync.value;
      final isAuthed = user != null;

      const authRoutes = {
        '/splash',
        '/login',
        '/register',
        '/forgot-password'
      };
      final isOnAuthRoute = authRoutes.contains(location);

      if (!isAuthed && !isOnAuthRoute) return '/login';
      if (isAuthed && isOnAuthRoute) {
        return user.isNutriologist ? '/home/nutriologist' : '/home/patient';
      }
      if (isAuthed) {
        if (user.isPatient && location.startsWith('/home/nutriologist')) {
          return '/home/patient';
        }
        if (user.isNutriologist && location.startsWith('/home/patient')) {
          return '/home/nutriologist';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) =>
            const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home/nutriologist',
        builder: (_, _) => const HomeNutriologistPage(),
      ),
      GoRoute(
        path: '/home/patient',
        builder: (_, _) => const HomePatientPage(),
      ),
      GoRoute(
        path: '/patients/new',
        builder: (_, _) => const PatientFormPage(),
      ),
      GoRoute(
        path: '/patients/:patientId/consultations',
        builder: (_, state) => ConsultationsListPage(
          patientId: state.pathParameters['patientId']!,
          patientUid: state.uri.queryParameters['uid'] ?? '',
          patientName: state.uri.queryParameters['name'] ?? '',
          nutriologistId: state.uri.queryParameters['nutriologistId'],
        ),
      ),
      GoRoute(
        path: '/patients/:patientId/clinical',
        builder: (_, state) => ClinicalRecordPage(
          patientId: state.pathParameters['patientId']!,
          patientUid: state.uri.queryParameters['uid'] ?? '',
          nutriologistId: state.uri.queryParameters['nutriologistId'] ?? '',
          patientName: state.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        path: '/patients/:patientId',
        builder: (_, state) => PatientDetailPage(
          patientId: state.pathParameters['patientId']!,
        ),
      ),
      GoRoute(
        path: '/consultation/new',
        builder: (_, state) => ConsultationWizardPage(
          patientId: state.uri.queryParameters['patientId'] ?? '',
          patientUid: state.uri.queryParameters['patientUid'] ?? '',
          appointmentId: state.uri.queryParameters['appointmentId'],
          existingConsultationId: state.uri.queryParameters['consultationId'],
          patientName: state.uri.queryParameters['name'] ?? '',
          patientExpediente: state.uri.queryParameters['expediente'] ?? '',
        ),
      ),
      GoRoute(
        path: '/consultation/:consultationId/summary',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ConsultationSummaryPage(
            consultationId: state.pathParameters['consultationId']!,
            isNutriologist: extra['isNutriologist'] as bool? ?? false,
            consultationData: extra['data'] as Map<String, dynamic>?,
          );
        },
      ),
      GoRoute(
        path: '/consultation/:consultationId',
        builder: (_, state) => _PlaceholderPage(
          title:
              'Consulta ${state.pathParameters["consultationId"]}',
        ),
      ),
      GoRoute(
        path: '/consultations/patient/:patientId',
        builder: (_, state) => ConsultationsListPage(
          patientId: state.pathParameters['patientId']!,
          patientUid: state.pathParameters['patientId']!,
          patientName: 'Mis consultas',
        ),
      ),
      GoRoute(
        path: '/appointments/new',
        builder: (_, state) => AppointmentFormPage(
          patientId: state.uri.queryParameters['patientId'],
          patientUid: state.uri.queryParameters['patientUid'],
          patientName: state.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        path: '/appointments/:appointmentId',
        builder: (_, state) => AppointmentDetailPage(
          appointmentId: state.pathParameters['appointmentId']!,
        ),
      ),
      GoRoute(
        path: '/log/notes/:patientId',
        builder: (_, state) => LogNotesPage(
          patientId: state.pathParameters['patientId']!,
        ),
      ),
      GoRoute(
        path: '/plan/:patientId',
        builder: (_, state) => MyPlanPage(
          patientId: state.pathParameters['patientId']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const _PlaceholderPage(title: 'Perfil'),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) =>
            const _PlaceholderPage(title: 'Notificaciones'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.uri}'),
      ),
    ),
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title — próximamente')),
      );
}
