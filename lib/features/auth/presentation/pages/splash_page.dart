import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/features/auth/presentation/providers/auth_providers.dart'; //

/// Shown while Firebase is resolving the auth state.
/// Automatically routes to the correct screen once state is known.
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);

    // Navigate after first frame to avoid calling GoRouter during build.
    useEffect(() {
      Future.microtask(() {
        authAsync.when(
          data: (userEntity) {
            if (userEntity == null) {
              context.go('/login');
            } else if (userEntity.isNutriologist) {
              context.go('/home/nutriologist');
            } else {
              context.go('/home/patient');
            }
          },
          error: (error, stackTrace) {
            context.go('/splash'); // O una pantalla de error
          },
          // Mientras Firebase está averiguando si hay sesión activa
          loading: () {
          },
        );
      });
      return null;
    }, [authAsync]);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5EE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF2D5016),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nutritrack',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Color(0xFF2D5016),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Color(0xFF2D5016)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}