import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/house_dashboard_page.dart';
import 'package:gestao_familiar_app/pages/no_house_page.dart';
import 'package:gestao_familiar_app/api/firebase_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Vamos transformar a função em uma variável de futuro para que o FutureBuilder
  // não a chame repetidamente a cada reconstrução.
  late Future<Map<String, dynamic>?> _getHouseMembershipFuture;

  @override
  void initState() {
    super.initState();
    _getHouseMembershipFuture = _getHouseMembership();
     FirebaseApi().initNotifications(); 
  }

  Future<Map<String, dynamic>?> _getHouseMembership() async {
    if (supabase.auth.currentUser == null) {
      return null;
    }

    final userId = supabase.auth.currentUser!.id;
    try {
      final response = await supabase
          .from('house_members')
          .select('role, houses(id, name, invite_code, owner_id)')
          .eq('profile_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint("Erro ao buscar casa: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getHouseMembershipFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // AQUI ESTÁ A MUDANÇA:
          // Passamos a função de callback para o parâmetro com o nome correto.
          return NoHousePage(
            onHouseCreatedOrJoined: () {
              // <-- Nome do parâmetro corrigido
              setState(() {
                _getHouseMembershipFuture = _getHouseMembership();
              });
            },
          );
        }

        final membershipData = snapshot.data!;
        final houseData = membershipData['houses'];
        final userRole = membershipData['role'];
        final houseId = houseData['id'];
        final houseName = houseData['name'];
        final inviteCode = houseData['invite_code'];
        final houseOwnerId = houseData['owner_id'];

        return HouseDashboardPage(
          houseId: houseId,
          houseName: houseName,
          userRole: userRole,
          inviteCode: inviteCode,
          houseOwnerId: houseOwnerId,
        );
      },
    );
  }
}
