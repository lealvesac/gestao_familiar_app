// NOVO ARQUIVO: lib/pages/desktop_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart'; // Para as cores

class DesktopDashboardPage extends StatefulWidget {
  // Esta página receberá todos os dados necessários no futuro
  const DesktopDashboardPage({super.key});

  @override
  State<DesktopDashboardPage> createState() => _DesktopDashboardPageState();
}

class _DesktopDashboardPageState extends State<DesktopDashboardPage> {
  int _selectedIndex = 0;

  // Widget auxiliar para os cartões de resumo do painel central
  Widget _buildSummaryCard(String title, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Icon(icon, color: Colors.grey),
              ],
            ),
            const Divider(height: 24),
            // Placeholder para o conteúdo do card
            const Text('Dados do resumo aparecerão aqui.'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // --- COLUNA 1: BARRA DE NAVEGAÇÃO LATERAL ---
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                // TODO: Adicionar lógica para trocar o conteúdo principal
              });
            },
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

          // --- COLUNA 2: CONTEÚDO PRINCIPAL (DASHBOARD) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Boa tarde, Leal!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Aqui está um resumo da sua casa hoje.',
                    style: TextStyle(color: lightTextColor),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    // Wrap permite que os cards quebrem a linha se a tela for menor
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          maxWidth: 400,
                        ),
                        child: _buildSummaryCard(
                          'Próximos Eventos',
                          Icons.calendar_month,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          maxWidth: 400,
                        ),
                        child: _buildSummaryCard(
                          'Lista de Compras',
                          Icons.shopping_cart,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          maxWidth: 400,
                        ),
                        child: _buildSummaryCard(
                          'Resumo do Mês',
                          Icons.attach_money,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          maxWidth: 400,
                        ),
                        child: _buildSummaryCard(
                          'Quadro de Tarefas',
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- COLUNA 3: BARRA LATERAL DE MEMBROS (OPCIONAL) ---
          Container(
            width: 250,
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Membros da Casa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                // Placeholder para a lista de membros
                ListTile(
                  leading: CircleAvatar(child: Text('L')),
                  title: Text('Leal (Admin)'),
                ),
                ListTile(
                  leading: CircleAvatar(child: Text('C')),
                  title: Text('Convidado 1'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
