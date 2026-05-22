import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/core/navigation/nutritrack.dart';
import 'package:nutritrack/features/assessment/presentation/pages/assessment.dart';
import 'package:nutritrack/features/auth/presentation/pages/login_page.dart';
import 'package:nutritrack/features/configuration/presentation/pages/configuration.dart';
import 'package:nutritrack/features/home/presentation/pages/home.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',

    routes: [

      // LOGIN
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // REGISTER
      GoRoute(
        path: '/register',
        builder: (context, state) => const LoginPage(),
      ),

      // APP CON NAVBAR
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NutritrackApp(
            navigationShell: navigationShell,
          );
        },

        branches: [

          // HOME TAB
          StatefulShellBranch(
            routes: [

              GoRoute(
                path: '/home',
                builder: (_, __) =>
                    const HomeScreen(),
              ),

            ],
          ),

          // ASSESSMENT TAB
          StatefulShellBranch(
            routes: [

              GoRoute(
                path: '/assessment',
                builder: (_, __) =>
                    const AssessmentPage(),

                routes: [

                  // /assessment/create
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const LoginPage(),
                  ),

                  // /assessment/result/1
                  GoRoute(
                    path: 'result/:id',
                    builder: (context, state) => const LoginPage(),
                    /* builder: (context, state) {

                      final id =
                          state.pathParameters['id'];

                      return ResultAssessmentPage(
                        assessmentId: id!,
                      );
                    },*/
                  ),
                ],
              ),
            ],
          ),

          // SETTINGS TAB
          StatefulShellBranch(
            routes: [

              GoRoute(
                path: '/settings',
                builder: (_, __) =>
                    const ConfigurationScreen(),
              ),

            ],
          ),
        ],
      ),
    ],
  );
});