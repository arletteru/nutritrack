import 'package:flutter/material.dart';

class ChipsCard extends StatelessWidget {
  final String question;
  final List<String> chipsList;
  const ChipsCard({
    super.key,
    required this.question,
    required this.chipsList,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ...chipsList.map((String chip){
              return _buildChip(chip);
            }),
            _buildChip('+')
          ],
          
        ),
      ],
    );
  }

  // TODO: Implementar on selected, y funcion +
  Widget _buildChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: false, // TODO: Conectar con lista de seleccionados
      onSelected: (bool selected) {},
      selectedColor: const Color(0xFF386641).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF386641),
      labelStyle: const TextStyle(color: Color(0xFF386641), fontSize: 13),
      backgroundColor: const Color(0xFFF5F7F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    );
  }
}
