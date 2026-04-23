import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final String primaryLabel;
  final String ? secondaryLabel;
  final IconData icon;
  final List<String> ? tiles;
  final List<Widget> ? childrenWidgets;
  const CustomExpansionTile({
    super.key,
    required this.primaryLabel,
    this.secondaryLabel,
    required this.icon,
    this.tiles,
    this.childrenWidgets,    
    });

  @override
  Widget build(BuildContext context) {
    Color colorFondoCard = Theme.of(context).primaryColor;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorFondoCard,
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.white.withValues(
          alpha: 0.05,
        ),
        iconColor: Colors.white,
        collapsedIconColor:  Colors.white,
        textColor: Colors.white,
        collapsedTextColor:  Colors.white,

        leading: Icon(icon),
        title: Text(
          primaryLabel,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          secondaryLabel ?? '',
          style: TextStyle(fontSize: 12),
        ),

        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: childrenWidgets ?? [
                ...tiles!.map((String tile) {
                  return _buildCheckboxOption(tile);
                }),
                const SizedBox(height: 10),
                const TextField(
                  decoration: InputDecoration(
                    hintText: "Otros antecedentes...",
                    hintStyle: TextStyle(color:  Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(String title) {
    return CheckboxListTile(
    title: Text(
      title, 
      style: const TextStyle(color: Colors.white),
    ),
    value: true, // TODO: Cambiar por variable de estado
    onChanged: (val) {},
    controlAffinity: ListTileControlAffinity.leading,
    activeColor: Colors.white, 
    checkColor: const Color(0xFF386641), 
    side: const BorderSide(color:Colors.white, width: 1.5),
    contentPadding: EdgeInsets.zero, 
  );
  }
}
