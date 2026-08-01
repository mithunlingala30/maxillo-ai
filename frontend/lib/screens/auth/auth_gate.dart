import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../home/main_shell.dart';
import 'auth_screen.dart';

/// Watches [AppState.status] and shows the Auth screen or the main
/// bottom-nav shell accordingly. Also used as the target after splash /
/// onboarding, and as the screen shown after sign-out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    switch (state.status) {
      case AuthStatus.signedIn:
        return const MainShell();
      case AuthStatus.signedOut:
        return const AuthScreen();
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
