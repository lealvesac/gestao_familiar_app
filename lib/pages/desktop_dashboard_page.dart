// CÓDIGO FINAL: lib/pages/desktop_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/calendar_page.dart';
import 'package:gestao_familiar_app/pages/desktop_summary_page.dart';
import 'package:gestao_familiar_app/pages/family_page.dart';
import 'package:gestao_familiar_app/pages/finances_page.dart';
import 'package:gestao_familiar_app/pages/medication_page.dart';
import 'package:gestao_familiar_app/pages/profile_page.dart';
import 'package:gestao_familiar_app/pages/shopping_list_page.dart';
import 'package:gestao_familiar_app/pages/tasks_page.dart';

class DesktopDashboardPage extends StatefulWidget {
  final String houseId;
  final String houseName;
  final String userRole;
  final String userId;
  final String houseOwnerId;

  const DesktopDashboardPage({
    super.key,
    required this.houseId,
    required this.houseName,
    required this.userRole,
    required this.userId,
    required this.houseOwnerId,
  });

  @override
  State<DesktopDashboardPage> createState() => _DesktopDashboardPageState();
}

class _DesktopDashboardPageState extends State<DesktopDashboardPage> {
  int _selectedIndex = 0;
  String _userFullName = 'Usuário'; // Valor inicial

  @override
  void initState() {
    super.initState();
    // Busca o nome do usuário ao iniciar a tela
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', widget.userId)
          .single();

      if (mounted && response['full_name'] != null) {
        // Se encontrar, atualiza o estado com o nome real.
        setState(() {
          _userFullName = response['full_name'];
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar perfil do usuário no dashboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa a variável de estado para obter o primeiro nome
    final userFirstName = _userFullName.split(' ').first;

    // A lista de páginas é criada aqui, garantindo que sempre use os dados mais recentes
    final List<Widget> pages = [
      DesktopSummaryPage(
        houseId: widget.houseId,
        userId: widget.userId,
        userName: _userFullName,
      ),
      TasksPage(houseId: widget.houseId),
      ShoppingListPage(houseId: widget.houseId),
      CalendarPage(houseId: widget.houseId),
      const FinancesPage(),
      const MedicationPage(),
      FamilyPage(
        houseId: widget.houseId,
        currentUserRole: widget.userRole,
        houseOwnerId: widget.houseOwnerId,
      ),
    ];

    final List<String> pageTitles = [
      widget.houseName,
      'Quadros de Tarefas',
      'Listas de Compras',
      'Calendário',
      'Finanças',
      'Medicamentos',
      'Gerenciar Família',
    ];

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
              child: Image.asset('assets/icons/logo.png', width: 40),
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
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: Text('Finanças'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medication_outlined),
                selectedIcon: Icon(Icons.medication),
                label: Text('Medicamentos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: Text('Gestão'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(pageTitles[_selectedIndex]),
                  backgroundColor: Colors.white,
                  elevation: 1,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    Center(
                      child: Text(
                        'Olá, $userFirstName',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      tooltip: 'Meu Perfil',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(child: pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
