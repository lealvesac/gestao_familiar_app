import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/calendar_page.dart';
import 'package:gestao_familiar_app/pages/family_page.dart';
import 'package:gestao_familiar_app/pages/invite_page.dart';
import 'package:gestao_familiar_app/pages/profile_page.dart';
import 'package:gestao_familiar_app/pages/shopping_list_page.dart';
import 'package:gestao_familiar_app/pages/splash_page.dart';
import 'package:gestao_familiar_app/pages/tasks_page.dart';

class HouseDashboardPage extends StatefulWidget {
  final String houseId;
  final String houseName;
  final String userRole;
  final String inviteCode;
  final String houseOwnerId;

  const HouseDashboardPage({
    super.key,
    required this.houseId,
    required this.houseName,
    required this.userRole,
    required this.inviteCode,
    required this.houseOwnerId,
  });

  @override
  State<HouseDashboardPage> createState() => _HouseDashboardPageState();
}

class _HouseDashboardPageState extends State<HouseDashboardPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late String _currentHouseName;

  @override
  void initState() {
    super.initState();
    _currentHouseName = widget.houseName;
    _pages = [
      TasksPage(houseId: widget.houseId),
      ShoppingListPage(houseId: widget.houseId),
      FamilyPage(
        houseId: widget.houseId,
        currentUserRole: widget.userRole,
        houseOwnerId: widget.houseOwnerId,
      ),
      CalendarPage(houseId: widget.houseId),
    ];
  }

  void _showEditHouseNameDialog() {
    final houseNameController = TextEditingController(text: _currentHouseName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Nome da Casa'),
          content: TextFormField(
            controller: houseNameController,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = houseNameController.text.trim();
                if (newName.isNotEmpty) {
                  await _updateHouseName(newName);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateHouseName(String newName) async {
    try {
      await supabase
          .from('houses')
          .update({'name': newName})
          .eq('id', widget.houseId);

      setState(() {
        _currentHouseName = newName;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao atualizar o nome da casa.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          tooltip: 'Meu Perfil',
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
          },
        ),
        title: Text(_currentHouseName),
        actions: [
          if (widget.userRole == 'administrador')
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar Nome da Casa',
              onPressed: _showEditHouseNameDialog,
            ),
          if (widget.userRole == 'administrador')
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: 'Convidar Membros',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InvitePage(
                      inviteCode: widget.inviteCode,
                      onDone: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // <-- A ADIÇÃO IMPORTANTE
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Compras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Família',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendário',
          ),
        ],
      ),
    );
  }
}
