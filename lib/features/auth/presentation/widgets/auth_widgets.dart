import 'package:flutter/material.dart';

// ─── Password Requirements Widget ─────────────────────────────────────────────

class PasswordRequirementsWidget extends StatelessWidget {
  const PasswordRequirementsWidget({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REQUISITOS DE SEGURIDAD',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B55),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          _Requirement(
            label: 'Mínimo 8 caracteres',
            met: password.length >= 8,
          ),
          _Requirement(
            label: 'Incluye un número o símbolo',
            met: RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]').hasMatch(password),
          ),
          _Requirement(
            label: 'Usa mayúsculas y minúsculas',
            met: RegExp(r'[A-Z]').hasMatch(password) &&
                RegExp(r'[a-z]').hasMatch(password),
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              met ? Icons.check_circle_outline : Icons.circle_outlined,
              key: ValueKey(met),
              size: 16,
              color: met ? const Color(0xFF2D5016) : const Color(0xFF9E9E8A),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: met ? const Color(0xFF2D5016) : const Color(0xFF6B6B55),
            ),
          ),
        ],
      ),
    );
  }
}
