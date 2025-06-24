// CÓDIGO FINAL: lib/pages/desktop_summary_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/widgets/dashboard_cards/my_tasks_card.dart';
import 'package:gestao_familiar_app/widgets/dashboard_cards/upcoming_events_card.dart';

class DesktopSummaryPage extends StatelessWidget {
  final String houseId;
  final String userId;
  final String userName; // <-- Agora ele RECEBE o nome

  const DesktopSummaryPage({
    super.key,
    required this.houseId,
    required this.userId,
    required this.userName, // <-- Parâmetro obrigatório
  });

  @override
  Widget build(BuildContext context) {
    // Pega o primeiro nome a partir do nome completo que ele recebeu
    final userFirstName = userName.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A saudação agora usa a variável recebida
          Text(
            'Boa tarde, $userFirstName!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Aqui está um resumo da sua casa hoje.',
            style: TextStyle(color: lightTextColor),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              UpcomingEventsCard(houseId: houseId),
              MyTasksCard(userId: userId),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 300,
                    height: 100,
                    child: Center(child: Text('Resumo Financeiro (em breve)')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
