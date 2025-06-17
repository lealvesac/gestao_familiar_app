import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart'; // Import para supabase
import 'package:gestao_familiar_app/pages/create_house_page.dart';
import 'package:gestao_familiar_app/pages/join_house_page.dart';
import 'package:gestao_familiar_app/pages/splash_page.dart'; // Import para SplashPage

class NoHousePage extends StatelessWidget {
  final VoidCallback onHouseCreatedOrJoined;

  const NoHousePage({super.key, required this.onHouseCreatedOrJoined});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APPBAR ADICIONADA AQUI
      appBar: AppBar(
        title: const Text('Bem-vindo!'),
        automaticallyImplyLeading: false, // Remove o botão de "voltar"
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Comece a organizar sua vida familiar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Crie uma nova casa para sua família ou entre em uma já existente.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_home_outlined),
                label: const Text('Criar uma Nova Casa'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // A CreateHousePage espera 'onHouseCreated'
                      builder: (_) => CreateHousePage(
                        onHouseCreated: onHouseCreatedOrJoined,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.group_add_outlined),
                label: const Text('Entrar com Código de Convite'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // A JoinHousePage espera 'onHouseJoined'
                      builder: (_) =>
                          JoinHousePage(onHouseJoined: onHouseCreatedOrJoined),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
