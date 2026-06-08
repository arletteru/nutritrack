import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutritrack/core/router/nutritrack_router.dart';
import 'package:nutritrack/core/theme/app_theme.dart';
import 'package:nutritrack/core/theme/app_theme_extension.dart';
import 'package:nutritrack/firebase_options.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
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
