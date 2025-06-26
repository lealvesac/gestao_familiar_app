// CÓDIGO FINAL E DEFINITIVO: lib/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/home_page.dart';
import 'package:gestao_familiar_app/pages/login_page.dart';
import 'package:gestao_familiar_app/pages/reset_password_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Image.asset('assets/icons/logo.png', width: 120),
            ),
          );
        }

        final data = snapshot.data!;
        final event = data.event;
        final session = data.session;

        // Ao carregar, o Supabase vai ler a sessão que a página auth.html salvou.
        if (event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordPage();
        }

        if (session != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
