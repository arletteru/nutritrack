import 'package:flutter/material.dart';
import 'package:nutritrack/config/theme/theme.dart';
import 'package:nutritrack/core/navigation/nutritrack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: getAppTheme(),
      home:  NutritrackApp(),
    );
  }
}
