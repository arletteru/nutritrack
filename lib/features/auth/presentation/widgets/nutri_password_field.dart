import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nutritrack/features/auth/presentation/widgets/nutri_text_field.dart';

// ─── Password Field ──────────────────────────────────────────────────────────

/// A [NutriTextField] with a built-in show/hide toggle for passwords.
class NutriPasswordField extends HookWidget {
  const NutriPasswordField({
    super.key,
    required this.hint,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.enabled = true,
  });

  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isVisible = useState(false);

    return NutriTextField(
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      enabled: enabled,
      obscureText: !isVisible.value,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: GestureDetector(
        onTap: () => isVisible.value = !isVisible.value,
        child: Icon(
          isVisible.value
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    );
  }
}