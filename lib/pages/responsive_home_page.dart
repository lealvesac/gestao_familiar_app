// CÓDIGO FINAL PARA: lib/pages/responsive_home_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/pages/desktop_dashboard_page.dart';
import 'package:gestao_familiar_app/pages/mobile_home_page.dart';

class ResponsiveHomePage extends StatelessWidget {
  // A classe agora ACEITA todos os parâmetros
  final String houseId;
  final String houseName;
  final String userRole;
  final String inviteCode;
  final String houseOwnerId;
  final String userId;

  const ResponsiveHomePage({
    super.key,
    required this.houseId,
    required this.houseName,
    required this.userRole,
    required this.inviteCode,
    required this.houseOwnerId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    const breakpoint = 700;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          // Passa os parâmetros para a versão mobile
          return MobileHomePage(
            houseId: houseId,
            houseName: houseName,
            userRole: userRole,
            inviteCode: inviteCode,
            houseOwnerId: houseOwnerId,
          );
        } else {
          // Passa os parâmetros para a versão desktop
          return DesktopDashboardPage(
            houseId: houseId,
            houseName: houseName,
            userRole: userRole,
            userId: userId,
            houseOwnerId: houseOwnerId,
          );
        }
      },
    );
  }
}
