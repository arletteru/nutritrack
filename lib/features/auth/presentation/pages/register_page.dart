import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/features/auth/domain/entities/user_entity.dart';
import 'package:nutritrack/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:nutritrack/features/auth/presentation/widgets/nutri_password_field.dart';
import 'package:nutritrack/features/auth/presentation/widgets/nutri_primary_button.dart';
import 'package:nutritrack/features/auth/presentation/widgets/nutri_text_field.dart';

import '../widgets/auth_widgets.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Controllers & focus ──────────────────────────────────────────────────
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final nameFocus = useFocusNode();
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    // ── Local state ──────────────────────────────────────────────────────────
    final acceptedTerms = useState(false);
    final passwordValue = useState('');

    // ── Riverpod ─────────────────────────────────────────────────────────────
    final registerState = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    ref.listen<AsyncValue<UserEntity?>>(registerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            notifier.reset();
          }
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Logo ─────────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5016),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.eco_outlined,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Nutritrack',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF2D5016),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Headline ──────────────────────────────────────────────────
                const Text(
                  'Crea tu cuenta',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Únete a nuestra comunidad de salud consciente.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    color: Color(0xFF6B6B55),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Name ──────────────────────────────────────────────────────
                const _FieldLabel(text: 'Nombre Completo'),
                const SizedBox(height: 8),
                NutriTextField(
                  hint: 'Ej. Ana García',
                  controller: nameController,
                  focusNode: nameFocus,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  onFieldSubmitted: (_) => emailFocus.requestFocus(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tu nombre.';
                    }
                    if (v.trim().length < 2) return 'Nombre demasiado corto.';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Email ─────────────────────────────────────────────────────
                const _FieldLabel(text: 'Correo Electrónico'),
                const SizedBox(height: 8),
                NutriTextField(
                  hint: 'tu@email.com',
                  controller: emailController,
                  focusNode: emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo.';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Correo inválido.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Password ──────────────────────────────────────────────────
                const _FieldLabel(text: 'Contraseña'),
                const SizedBox(height: 8),
                NutriPasswordField(
                  hint: '••••••••',
                  controller: passwordController,
                  focusNode: passwordFocus,
                  textInputAction: TextInputAction.done,
                  onChanged: (v) => passwordValue.value = v,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa una contraseña.';
                    if (v.length < 8) return 'Mínimo 8 caracteres.';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ── Password requirements ─────────────────────────────────────
                PasswordRequirementsWidget(password: passwordValue.value),

                const SizedBox(height: 20),

                // ── Terms checkbox ────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: acceptedTerms.value,
                      onChanged: (v) =>
                          acceptedTerms.value = v ?? false,
                      activeColor: const Color(0xFF2D5016),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            color: Color(0xFF4A4A3A),
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'Acepto los '),
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: const TextStyle(
                                color: Color(0xFF2D5016),
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => {},
                            ),
                            const TextSpan(text: ' y la '),
                            TextSpan(
                              text: 'Política de Privacidad',
                              style: const TextStyle(
                                color: Color(0xFF2D5016),
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => {},
                            ),
                            const TextSpan(text: ' de Nutritrack.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Continue CTA ──────────────────────────────────────────────
                registerState.isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(color: Color(0xFF2D5016)),
                        ),
                      )
                    : NutriPrimaryButton(
                        label: 'Continuar',
                        icon: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            await notifier.signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              displayName: nameController.text.trim(),
                              acceptedTerms: acceptedTerms.value,
                              role: UserRole.patient,
                            );
                          }
                        },
                      ),

                const SizedBox(height: 20),

                // ── Footer ────────────────────────────────────────────────────
                Center(
                  child: Text(
                    'NUTRITRACK NUTRITION SYSTEM  •  STEP ONE',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: const TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          color: Color(0xFF6B6B55),
                        ),
                        children: [
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(
                              color: Color(0xFF2D5016),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}
