import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/core/router/nutritrack_router.dart';
import 'package:nutritrack/core/theme/app_theme.dart';
import 'package:nutritrack/core/theme/app_theme_extension.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Nutritrack',
      theme: AppTheme.light.copyWith(
        extensions: const [NutriColors.light],
      ),
      darkTheme: AppTheme.dark.copyWith(
        extensions: const [NutriColors.dark],
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
