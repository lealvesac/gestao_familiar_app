import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/no_house_page.dart';
import 'package:gestao_familiar_app/api/firebase_api.dart';
import 'package:gestao_familiar_app/pages/responsive_home_page.dart'; 
// A linha do 'house_dashboard_page.dart' foi removida.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>?> _getHouseMembershipFuture;

  @override
  void initState() {
    super.initState();
    _getHouseMembershipFuture = _getHouseMembership();
    FirebaseApi().initNotifications();
  }

  Future<Map<String, dynamic>?> _getHouseMembership() async {
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

        if (snapshot.hasData && snapshot.data != null) {
          final membershipData = snapshot.data!;
          // Verifica se 'houses' não é nulo antes de acessar
          final houseData = membershipData['houses'];
          if (houseData == null) {
            // Se por algum motivo a casa não for encontrada, trata como se não tivesse casa
            return NoHousePage(
              onHouseCreatedOrJoined: () {
                setState(() {
                  _getHouseMembershipFuture = _getHouseMembership();
                });
              },
            );
          }

          return ResponsiveHomePage(
            houseId: houseData['id'],
            houseName: houseData['name'],
            userRole: membershipData['role'],
            inviteCode: houseData['invite_code'],
            houseOwnerId:
                houseData['owner_id'], // Agora será recebido corretamente
          );
        }

        return NoHousePage(
          onHouseCreatedOrJoined: () {
            setState(() {
              _getHouseMembershipFuture = _getHouseMembership();
            });
          },
        );
      },
    );
  }
}
