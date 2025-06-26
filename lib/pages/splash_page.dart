// ARQUIVO FINAL E DEFINITIVO: lib/pages/splash_page.dart

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
    // StreamBuilder é a solução reativa que escuta o estado de autenticação
    // e constrói a tela correta em resposta, sem condição de corrida.
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Se ainda não recebeu NENHUMA informação do stream, mostra o loading.
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final authState = snapshot.data!;
        final session = authState.session;
        final event = authState.event;

        // Damos prioridade MÁXIMA ao evento de recuperação de senha.
        if (event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordPage();
        }

        // Se não for recuperação, mas existir uma sessão, vai para a Home.
        if (session != null) {
          return const HomePage();
        }

        // Se não houver sessão, vai para o Login.
        return const LoginPage();
      },
    );
  }
}
