
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../notifier/auth_notifier.dart';
import '../widgets/nutri_primary_button.dart';
import '../widgets/nutri_text_field.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final sent = useState(false);

    final forgotState = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);

    ref.listen<AsyncValue>(forgotPasswordProvider, (_, next) {
      next.whenOrNull(
        data: (email) {
          if (email != null) sent.value = true;
        },
        error: (error, _) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(error is Exception
                  ? error.toString().replaceAll('Exception: ', '')
                  : 'Ocurrió un error. Intenta de nuevo.'),
              backgroundColor: context.colors.error,
              behavior: SnackBarBehavior.floating,
            ));
        },
      );
    });

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: sent.value
              ? _SuccessView(
                  email: emailController.text.trim(),
                  onBack: () => context.go('/login'),
                )
              : Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── Ícono ─────────────────────────────────────────────
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(context.radiusLg),
                        ),
                        child: Icon(
                          Icons.lock_reset_outlined,
                          size: 28,
                          color: context.colors.primary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Título ────────────────────────────────────────────
                      Text('Recuperar contraseña',
                          style: context.textTheme.headlineLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                        style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant),
                      ),

                      const SizedBox(height: 32),

                      // ── Email ─────────────────────────────────────────────
                      NutriTextField(
                        hint: 'tu@email.com',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu correo.';
                          }
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Correo inválido.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── Botón ─────────────────────────────────────────────
                      forgotState.isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : NutriPrimaryButton(
                              label: 'Enviar enlace',
                              icon: const Icon(
                                Icons.send_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () {
                                if (formKey.currentState?.validate() ??
                                    false) {
                                  notifier.sendResetEmail(
                                    emailController.text.trim(),
                                  );
                                }
                              },
                            ),

                      const SizedBox(height: 20),

                      // ── Volver al login ───────────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Volver al inicio de sesión',
                            style: TextStyle(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Vista de éxito ────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email, required this.onBack});
  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        // Ícono de éxito
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.nutri.successContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 40,
            color: context.nutri.success,
          ),
        ),

        const SizedBox(height: 24),

        Text('Correo enviado',
            style: context.textTheme.headlineLarge,
            textAlign: TextAlign.center),

        const SizedBox(height: 12),

        Text(
          'Enviamos un enlace de recuperación a:',
          style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Text(
          email,
          style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.primary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'Revisa tu bandeja de entrada y sigue las instrucciones. Si no lo ves, revisa tu carpeta de spam.',
          style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        NutriPrimaryButton(
          label: 'Volver al inicio de sesión',
          onPressed: onBack,
        ),
      ],
    );
  }
}
