// CÓDIGO FINAL E CORRIGIDO: lib/pages/mobile_home_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/calendar_page.dart';
import 'package:gestao_familiar_app/pages/family_page.dart';
import 'package:gestao_familiar_app/pages/finances_page.dart';
import 'package:gestao_familiar_app/pages/medication_page.dart';
import 'package:gestao_familiar_app/pages/profile_page.dart';
import 'package:gestao_familiar_app/pages/shopping_list_page.dart';
import 'package:gestao_familiar_app/pages/splash_page.dart';
import 'package:gestao_familiar_app/pages/tasks_page.dart';
import 'package:gestao_familiar_app/widgets/menu_button_widget.dart';

class MobileHomePage extends StatefulWidget {
  final String houseId;
  final String houseName;
  final String userRole;
  final String inviteCode;
  final String houseOwnerId;
  final String userId;

  const MobileHomePage({
    super.key,
    required this.houseId,
    required this.houseName,
    required this.userRole,
    required this.inviteCode,
    required this.houseOwnerId,
    required this.userId,
  });

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  String _userFirstName = 'Usuário';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('full_name')
          .eq('id', widget.userId)
          .single();

      if (mounted && response['full_name'] != null) {
        setState(() {
          _userFirstName = (response['full_name'] as String).split(' ').first;
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar nome para o mobile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- A CORREÇÃO ESTÁ AQUI ---
        title: Text(widget.houseName),
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
          if (widget.userRole == 'administrador')
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
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, left: 4.0),
            child: Text(
              'Olá, $_userFirstName!',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          MenuButton(
            icon: Icons.check_circle_outline,
            label: 'Tarefas',
            color: Colors.orange.shade600,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TasksPage(houseId: widget.houseId),
                ),
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
                  builder: (_) => ShoppingListPage(houseId: widget.houseId),
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
                  builder: (_) => CalendarPage(houseId: widget.houseId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Finanças',
            color: Colors.blue.shade800,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FinancesPage()));
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.medication_outlined,
            label: 'Medicamentos',
            color: Colors.red.shade600,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MedicationPage()));
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Gerenciar Família',
            color: Colors.grey.shade700,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FamilyPage(
                    houseId: widget.houseId,
                    currentUserRole: widget.userRole,
                    houseOwnerId: widget.houseOwnerId,
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
