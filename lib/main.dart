import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

Future<void> main() async {
  // 3. Garante que os widgets do Flutter estão prontos
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Inicializa o Firebase ANTES de tudo
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // O resto do seu código continua igual
await Supabase.initialize(
    url: 'https://ddiztapmnmwdaisqgsvw.supabase.co', // Cole sua URL aqui
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkaXp0YXBtbm13ZGFpc3Fnc3Z3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NjczOTYsImV4cCI6MjA2NTE0MzM5Nn0.gHoSY7h0c-Olct3p3bswHOIzM8ri1weELDdrQxF3yC8', // Cole sua Anon Key aqui
  );
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(const MyApp());
  });
}

// Atalho para acessar o cliente Supabase de qualquer lugar
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão Familiar',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // A primeira tela a ser exibida será a SplashPage
      home: const SplashPage(),
    );
  }
}
