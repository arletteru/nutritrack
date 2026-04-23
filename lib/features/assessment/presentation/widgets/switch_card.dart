import 'package:flutter/material.dart';

class SwitchCard extends StatelessWidget {
  final String primaryLabel;
  final String ? secondaryLabel;
  final Function(bool) onChanged;
  const SwitchCard({
    super.key,
    required this.primaryLabel,
    required this.onChanged,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(primaryLabel, style: TextStyle(fontWeight: .w900)),
                secondaryLabel != null ? Text(secondaryLabel ?? '', style: TextStyle(fontSize: 9)) : SizedBox(),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(value: false, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
