import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nutritrack/core/theme/theme.dart';

/// Branded text field for the Nutritrack auth screens.
/// Matches the rounded, cream-background style from the designs.
class NutriTextField extends HookWidget {
  const NutriTextField({
    super.key,
    required this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.enabled = true,
    this.autofillHints,
  });

  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final isFocused = useState(false);

    final colors = context.colors;
    final nutri = context.nutri;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.radiusXl),
      borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),

      child: Focus(
        onFocusChange: (f) => isFocused.value = f,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          enabled: enabled,
          autofillHints: autofillHints,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: IconTheme(
                      data: IconThemeData(
                        color: nutri.textHint,
                        size: 20,
                      ),
                      child: prefixIcon!,
                    ),
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconTheme(
                      data: IconThemeData(
                        color: nutri.textHint,
                        size: 20,
                      ),
                      child: suffixIcon!,
                    ),
                  )
                : null,
            filled: true,
            fillColor: isFocused.value ? nutri.inputBackground : colors.shadow,
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: baseBorder,
            errorBorder: baseBorder,
            contentPadding: EdgeInsets.symmetric(
              horizontal: prefixIcon != null ? 0 : 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}