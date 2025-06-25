// CÓDIGO FINAL E SIMPLIFICADO: lib/main.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/pages/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta de Cores
const primaryColor = Color(0xFF2DD8C8);
const darkTextColor = Color(0xFF2F363F);
const lightTextColor = Color(0xFF6A737D);
const backgroundColor = Color(0xFFF5F7FA);
const cardColor = Colors.white;
const shadowColor = Color(0x1A2DD8C8);

// A NavigatorKey e o listener foram removidos daqui.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://ddiztapmnmwdaisqgsvw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkaXp0YXBtbm13ZGFpc3Fnc3Z3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NjczOTYsImV4cCI6MjA2NTE0MzM5Nn0.gHoSY7h0c-Olct3p3bswHOIzM8ri1weELDdrQxF3yC8',
  );

  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A navigatorKey foi removida daqui.
      title: 'Familize',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: primaryColor,
          surface: cardColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: darkTextColor, displayColor: darkTextColor),
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0.5,
          centerTitle: true, // Centraliza o título para um visual mais moderno
          titleTextStyle: GoogleFonts.poppins(
            color: darkTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: darkTextColor),
        ),

        // Estilo dos Cards
        cardTheme: CardThemeData(
          color: cardColor,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.08), // Sombra mais suave
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),

        // Estilo dos Botões Flutuantes (FAB)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),

        // Estilo dos Botões Principais
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Estilo da Barra de Navegação Inferior
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          elevation: 4,
        ),

        // Estilo para os campos de formulário
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Fundo branco para os campos
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300), // Borda sutil
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: primaryColor, width: 2.0),
          ),
          labelStyle: const TextStyle(
            color: darkTextColor,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
      // A tela inicial continua sendo a SplashPage, mas agora ela é muito mais inteligente.
      home: const SplashPage(),
    );
  }
}
