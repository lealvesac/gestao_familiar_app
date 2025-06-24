// CÓDIGO FINAL PARA: lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/no_house_page.dart';
import 'package:gestao_familiar_app/api/firebase_api.dart';
import 'package:gestao_familiar_app/pages/responsive_home_page.dart';

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
    // A inicialização das notificações continua aqui
    FirebaseApi().initNotifications();
  }

  Future<Map<String, dynamic>?> _getHouseMembership() async {
    final userId = supabase.auth.currentUser!.id;
    try {
      // Garante que todos os campos necessários são buscados
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
          final houseData = membershipData['houses'];

          if (houseData == null) {
            return NoHousePage(
              onHouseCreatedOrJoined: () {
                setState(() {
                  _getHouseMembershipFuture = _getHouseMembership();
                });
              },
            );
          }

          // A chamada para a página responsiva, passando todos os parâmetros corretamente
          return ResponsiveHomePage(
            houseId: houseData['id'],
            houseName: houseData['name'],
            userRole: membershipData['role'],
            inviteCode: houseData['invite_code'],
            houseOwnerId: houseData['owner_id'],
            userId: supabase.auth.currentUser!.id,
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
