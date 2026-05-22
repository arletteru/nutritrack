import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/core/theme/app_theme_extensions.dart';
import '../widgets/login_widgets.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // -----    Theme   ------
    final colors = context.colors;
    final nutri = context.nutri;
    final text = context.textTheme;

    // -----    Controladores y nodos -----
    final formKey = useMemoized(GlobalKey<FormState>.new,);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: 24,),

                // Logo
                Text(
                  'Nutritrack',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: nutri.logo,
                  ),
                ),

                const SizedBox(height: 48),

                // ── Headline ──────────────────────────────────────────────────
                Text(
                  'Welcome back.',
                  style: context.textTheme.displayLarge
                ),
                const SizedBox(height: 6),
                Text(
                  'Nos alegra verte de nuevo.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 36),


                NutriTextField(
                  hint: 'Correo electrónico',
                  controller: emailController,
                  focusNode: emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo.';
                    if (!v.contains('@')) return 'Correo inválido.';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ── Password ──────────────────────────────────────────────────
                NutriPasswordField(
                  hint: 'Contraseña',
                  controller: passwordController,
                  focusNode: passwordFocus,
                  textInputAction: TextInputAction.done,
                  //onFieldSubmitted: (_) => _submit(formKey, emailController, passwordController, notifier),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña.';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ── Forgot password ───────────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    //onTap: () => context.push('/forgot-password'),
                    child: Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.secondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Primary CTA ───────────────────────────────────────────────
                NutriPrimaryButton(
                  label: 'Entrar',
                  //isLoading: isLoading,
                  //onPressed: () => _submit(
                  //    formKey, emailController, passwordController, notifier),
                ),

                const SizedBox(height: 28),

                // ── Divider ───────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: colors.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'O CONTINÚA CON',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: nutri.textHint
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: colors.outline)),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Social buttons ────────────────────────────────────────────
                Row(
                  children: [
                    NutriSocialButton(
                      label: 'Google',
                      //isLoading: isLoading,
                      icon: Image.asset('assets/icons/google.png'),
                      onPressed: (){}
                      //onPressed: notifier.signInWithGoogle,
                    ),
                    const SizedBox(width: 12),
                    NutriSocialButton(
                      label: 'Apple',
                      //isLoading: isLoading,
                      icon: const Icon(Icons.apple,
                          size: 22, color: Color(0xFF1A1A1A)),
                      onPressed: (){}
                      //notifier.signInWithApple,
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Sign up link ──────────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    //onTap: () => context.push('/register'),
                    child: RichText(
                      text: TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: text.bodyMedium?.copyWith(
                          color: nutri.textHint,
                        ) ,
                        children: [
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              color: colors.primary,
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
            )
          ),
        )
      ),
    );
  }
}