import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaxilloAIApp());
}

class MaxilloAIApp extends StatelessWidget {
  const MaxilloAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'MaxilloAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
