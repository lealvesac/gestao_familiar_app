// ARQUIVO CORRIGIDO E INDEPENDENTE: lib/pages/desktop_summary_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/widgets/dashboard_cards/my_tasks_card.dart';
import 'package:gestao_familiar_app/widgets/dashboard_cards/upcoming_events_card.dart';

class DesktopSummaryPage extends StatefulWidget {
  final String houseId;
  final String userId;

  const DesktopSummaryPage({
    super.key,
    required this.houseId,
    required this.userId,
  });

  @override
  State<DesktopSummaryPage> createState() => _DesktopSummaryPageState();
}

class _DesktopSummaryPageState extends State<DesktopSummaryPage> {
  // Usaremos um FutureBuilder para lidar com a busca do nome de forma elegante
  late final Future<String> _futureUserName;

  @override
  void initState() {
    super.initState();
    _futureUserName = _fetchUserName();
  }

  // Função que busca o nome do usuário na tabela de perfis
  Future<String> _fetchUserName() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', widget.userId)
          .single();

      // Retorna o nome completo encontrado ou 'Usuário' como fallback
      return (response['full_name'] as String?) ?? 'Usuário';
    } catch (e) {
      debugPrint("Erro ao buscar nome para o resumo: $e");
      return 'Usuário'; // Retorna o fallback em caso de erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FutureBuilder para construir a saudação APÓS o nome ter sido buscado
          FutureBuilder<String>(
            future: _futureUserName,
            builder: (context, snapshot) {
              // Enquanto busca, pode mostrar um placeholder ou nada
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 34); // Mantém o espaçamento
              }
              // Pega o primeiro nome para a saudação
              final userFirstName =
                  snapshot.data?.split(' ').first ?? 'Usuário';
              return Text(
                'Boa tarde, $userFirstName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
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
              UpcomingEventsCard(houseId: widget.houseId),
              MyTasksCard(userId: widget.userId),
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
