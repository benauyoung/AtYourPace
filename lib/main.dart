import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if not in demo mode
  if (!AppConfig.demoMode) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: AYPTourGuideApp(),
    ),
  );
}
