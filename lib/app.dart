import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme/app_theme.dart';
import 'presentation/router/app_router.dart';
import 'presentation/screens/user/settings_screen.dart';

class AYPTourGuideApp extends ConsumerWidget {
  const AYPTourGuideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appearanceSettings = ref.watch(appearanceSettingsProvider);

    return MaterialApp.router(
      title: 'AYP Tour Guide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appearanceSettings.themeMode,
      routerConfig: router,
    );
  }
}
