import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class InvitePage extends StatelessWidget {
  final String inviteCode;
  final VoidCallback onDone;
  const InvitePage({super.key, required this.inviteCode, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final inviteMessage =
        'Você foi convidado para se juntar à nossa casa no App Familiar! Use o código: $inviteCode';
    return Scaffold(
      appBar: AppBar(title: const Text('Casa Criada com Sucesso!')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Sua casa foi criada. Agora convide sua família e amigos!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              Text(
                'Seu código de convite é:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Código copiado para a área de transferência!',
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inviteCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Compartilhar Convite'),
                onPressed: () {
                  Share.share(inviteMessage);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Primeiro, executa a função para atualizar o estado da HomePage
                  onDone();

                  // Depois, remove todas as telas do "wizard" (convite, criar, etc)
                  // e volta para a primeira tela do app, que agora será o painel.
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Ir para o Painel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
