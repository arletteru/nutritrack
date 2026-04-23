import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget childWidget;
  final Color ? background;
  final String ? sectionName;
  final IconData ? sectionIcon;
  
  const SectionCard({
    super.key, 
    required this.childWidget, 
    this.background,
    this.sectionName,
    this.sectionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(10),
            decoration: BoxDecoration(
              color: background ?? Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
        child: Column(
          mainAxisAlignment: .start,
                crossAxisAlignment: .start,
                children: [
                  ListTile(
                    leading: sectionIcon != null ? Icon(sectionIcon, color: Theme.of(context).primaryColor,) : null,
                    title: sectionName != null ? Text(sectionName! ,style: TextStyle(fontWeight: FontWeight.w700,)) : null,
                  ),
                  Padding(
                    padding: const .only(left: 15, right: 15, bottom: 10),
                    child: childWidget,
                  )
                ]
        ),
    );
  }
}