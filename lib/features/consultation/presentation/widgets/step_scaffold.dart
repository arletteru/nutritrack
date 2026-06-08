import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

/// Scaffold reutilizable para cada paso del wizard de consulta.
/// Maneja scroll, título, subtítulo, cuerpo y botones ANTERIOR/SIGUIENTE.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    required this.onNext,
    this.onBack,
    this.nextLabel = 'Siguiente',
    this.nextIcon = Icons.arrow_forward_rounded,
    this.isSaving = false,
    this.isLastStep = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String nextLabel;
  final IconData nextIcon;
  final bool isSaving;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.displaySmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                      style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant)),
                ],
                const SizedBox(height: 24),
                ...children,
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Bottom action bar
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(
              top: BorderSide(
                color: context.colors.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              if (onBack != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving ? null : onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Anterior'),
                  ),
                ),
              if (onBack != null) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onNext,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(nextIcon, size: 18),
                  label: Text(nextLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: isLastStep
                        ? context.colors.primary
                        : context.colors.primary,
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sección con título y línea divisora para agrupar campos del formulario.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    required this.children,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: context.colors.primary),
              const SizedBox(width: 8),
            ],
            Text(title, style: context.textTheme.headlineSmall),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant)),
        ],
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Campo de texto estilizado para los formularios de consulta.
class ConsultField extends StatelessWidget {
  const ConsultField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.hint,
    this.suffix,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hint;
  final Widget? suffix;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Toggle switch con label para campos booleanos del formulario.
class ConsultToggle extends StatelessWidget {
  const ConsultToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.titleSmall),
                if (subtitle != null)
                  Text(subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.colors.primary,
          ),
        ],
      ),
    );
  }
}
