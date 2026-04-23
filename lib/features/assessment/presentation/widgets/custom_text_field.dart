import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String ? hintText;
  final IconData ? sufIcon;
  final Color ? filledColor;
  final int ? maxLines;
  const CustomTextField({super.key,
    required this.label,
    this.hintText,
    this.sufIcon,
    this.filledColor,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, ),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: filledColor ?? Theme.of(context).cardColor,
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13),
            suffixIcon: Icon(
              sufIcon,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          maxLines: maxLines ?? 1,
        ),
      ],
    );
  }
}
