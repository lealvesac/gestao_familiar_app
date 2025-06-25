// ARQUIVO FINAL E CORRIGIDO: lib/pages/splash_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/login_page.dart';
import 'package:gestao_familiar_app/pages/home_page.dart';
import 'package:gestao_familiar_app/pages/reset_password_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- A LINHA QUE FALTAVA

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Garante que o Supabase e a UI estejam prontos antes de escutar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAuthListener();
    });
  }

  void _setupAuthListener() {
    // Escuta por TODAS as mudanças de estado de autenticação
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      // Assim que o primeiro evento chegar, o trabalho da SplashPage terminou.
      _authSubscription?.cancel();

      if (!mounted) return;

      final session = data.session;
      final event = data.event;

      // Damos prioridade MÁXIMA ao evento de recuperação de senha.
      // O listener no main.dart já trata isso, mas mantemos aqui como uma segurança extra.
      if (event == AuthChangeEvent.passwordRecovery) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      } else if (session != null) {
        // Se não for recuperação, mas existir uma sessão, vai para a Home.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Se não houver sessão, vai para o Login.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });

    // Fallback de segurança para o caso de o app abrir sem internet e nenhum
    // evento ser disparado. Após 1 segundo, ele checa manualmente.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && supabase.auth.currentSession == null) {
        _authSubscription?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Opcional: Adicione seu logo aqui se desejar
            Image.asset('assets/icons/logo.png', width: 120),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Carregando...'),
          ],
        ),
      ),
    );
  }
}
