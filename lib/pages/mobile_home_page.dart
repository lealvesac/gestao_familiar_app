import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/calendar_page.dart';
import 'package:gestao_familiar_app/pages/family_page.dart';
import 'package:gestao_familiar_app/pages/profile_page.dart';
import 'package:gestao_familiar_app/pages/shopping_list_page.dart';
import 'package:gestao_familiar_app/pages/splash_page.dart';
import 'package:gestao_familiar_app/pages/tasks_page.dart';
import 'package:gestao_familiar_app/widgets/menu_button_widget.dart';

// O NOME DA CLASSE FOI ALTERADO DE HomeMenuPage PARA MobileHomePage
class MobileHomePage extends StatelessWidget {
  final String houseId;
  final String houseName;
  final String userRole;
  final String inviteCode;
  final String houseOwnerId;

  const MobileHomePage({
    super.key,
    required this.houseId,
    required this.houseName,
    required this.userRole,
    required this.inviteCode,
    required this.houseOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(houseName),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          tooltip: 'Meu Perfil',
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
          },
        ),
        actions: [
          if (userRole == 'administrador')
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: 'Convidar Membros',
              onPressed: () {
                // TODO: Adicionar navegação para página de convite se necessário
              },
            ),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          MenuButton(
            icon: Icons.check_circle_outline,
            label: 'Tarefas',
            color: Colors.orange.shade600,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TasksPage(houseId: houseId)),
              );
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.shopping_cart_outlined,
            label: 'Compras',
            color: Colors.green.shade600,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShoppingListPage(houseId: houseId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.calendar_month_outlined,
            label: 'Calendário',
            color: Colors.purple.shade600,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CalendarPage(houseId: houseId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.people_outline,
            label: 'Família',
            color: Colors.blue.shade600,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FamilyPage(
                    houseId: houseId,
                    currentUserRole: userRole,
                    houseOwnerId: houseOwnerId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
