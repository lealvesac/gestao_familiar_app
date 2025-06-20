// ARQUIVO ATUALIZADO E CORRIGIDO: lib/pages/responsive_home_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart'; // <-- IMPORT ADICIONADO AQUI
import 'package:gestao_familiar_app/pages/desktop_dashboard_page.dart';
import 'package:gestao_familiar_app/pages/mobile_home_page.dart';

class ResponsiveHomePage extends StatelessWidget {
  final String houseId;
  final String houseName;
  final String userRole;
  final String inviteCode;
  final String houseOwnerId;

  const ResponsiveHomePage({
    super.key,
    required this.houseId,
    required this.houseName,
    required this.userRole,
    required this.inviteCode,
    required this.houseOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    // Define um ponto de quebra. Se a tela for menor que 700px, é mobile.
    const breakpoint = 700;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          // MOSTRA A TELA DE MENU PARA CELULAR
          return MobileHomePage(
            houseId: houseId,
            houseName: houseName,
            userRole: userRole,
            inviteCode: inviteCode,
            houseOwnerId: houseOwnerId,
          );
        } else {
          // MOSTRA O NOVO DASHBOARD PARA DESKTOP
          return DesktopDashboardPage(
            houseId: houseId,
            houseName: houseName,
            userRole: userRole,
            // Pega o ID do usuário logado para passar para o dashboard
            userId: supabase.auth.currentUser!.id,
          );
        }
      },
    );
  }
}
