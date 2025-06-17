import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/login_page.dart';
import 'package:gestao_familiar_app/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Aguarda um pequeno momento para a inicialização do app
    await Future.delayed(Duration.zero);

    // Verifica se o widget ainda está montado
    if (!mounted) return;

    final session = supabase.auth.currentSession;
    if (session != null) {
      // Se existe uma sessão, vai para a HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Se não existe sessão, vai para a AuthPage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ), // Mude a classe aqui
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela de loading simples
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
