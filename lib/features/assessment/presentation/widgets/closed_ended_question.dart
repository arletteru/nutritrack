import 'package:flutter/material.dart';

class ClosedEndedQuestion extends StatelessWidget {
  final String? label;
  final String question;

  const ClosedEndedQuestion({super.key, this.label, required this.question});

  @override
  Widget build(BuildContext context) {
    bool? seleccion = false;
    return Container(
      width: .maxFinite,
      alignment: .centerLeft,
      padding: .all(10),
      decoration: BoxDecoration(
        borderRadius: .circular(10),
        color: const Color.fromARGB(55, 184, 184, 184),
      ),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 3,
        children: [
          Text(label ?? '', style: TextStyle(fontSize: 10)),
          Text(question),
          RadioGroup<bool>(
            groupValue: seleccion,
            onChanged: (val) => (seleccion = val),
            child: Row(
              children: [
                const Radio(value: true),
                const Text("Sí", style: TextStyle()),
                const SizedBox(width: 20),
                const Radio(value: false),
                const Text("No", style: TextStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
