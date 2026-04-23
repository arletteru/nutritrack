import 'package:flutter/material.dart';

ThemeData getAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 76, 123, 60)),
    fontFamily: 'Outfit',
  );
}