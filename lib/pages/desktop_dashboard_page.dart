// ARQUIVO ATUALIZADO: lib/pages/desktop_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/widgets/dashboard_cards/family_members_panel.dart';
import 'package:gestao_familiar_app/widgets/dashboard_cards/my_tasks_card.dart';
import 'package:gestao_familiar_app/widgets/dashboard_cards/upcoming_events_card.dart';

class DesktopDashboardPage extends StatefulWidget {
  final String houseId;
  final String houseName;
  final String userRole;
  final String userId;

  const DesktopDashboardPage({
    super.key,
    required this.houseId,
    required this.houseName,
    required this.userRole,
    required this.userId,
  });

  @override
  State<DesktopDashboardPage> createState() => _DesktopDashboardPageState();
}

class _DesktopDashboardPageState extends State<DesktopDashboardPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _houseMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchHouseMembers();
  }

  Future<void> _fetchHouseMembers() async {
    try {
      final response = await supabase.rpc(
        'get_house_members',
        params: {'p_house_id': widget.houseId},
      );
      if (mounted)
        setState(
          () => _houseMembers = List<Map<String, dynamic>>.from(response),
        );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final userFirstName =
        supabase.auth.currentUser?.userMetadata?['full_name']
            ?.split(' ')
            .first ??
        'Usuário';

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) =>
                setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Image.asset(
                'assets/icons/logo.png', // Requer que o logo esteja nos assets
                width: 40,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Início'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle),
                label: Text('Tarefas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Compras'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: Text('Calendário'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boa tarde, $userFirstName!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
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
                      // Substituímos os placeholders pelos nossos novos widgets inteligentes
                      UpcomingEventsCard(houseId: widget.houseId),
                      MyTasksCard(userId: widget.userId),
                      // Card de Finanças (ainda como placeholder)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Resumo Financeiro (em breve)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Painel de Membros agora usa o novo widget com dados reais
          FamilyMembersPanel(members: _houseMembers),
        ],
      ),
    );
  }
}
