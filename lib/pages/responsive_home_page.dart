import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/pages/desktop_dashboard_page.dart';
import 'package:gestao_familiar_app/pages/mobile_home_page.dart';

class ResponsiveHomePage extends StatelessWidget {
  // Ele recebe todos os dados e os repassa para a tela correta
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define um ponto de quebra. Se a tela for maior que 600px, é desktop.
        if (constraints.maxWidth < 600) {
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
          return const DesktopDashboardPage();
        }
      },
    );
  }
}
