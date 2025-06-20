// lib/widgets/dashboard_cards/family_members_panel.dart
import 'package:flutter/material.dart';

class FamilyMembersPanel extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const FamilyMembersPanel({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (members.isEmpty)
            const Center(child: Text('Carregando...'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final profile = member['profiles'];
                  final fullName = profile['full_name'] ?? 'Sem nome';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(fullName.isNotEmpty ? fullName[0] : '?'),
                    ),
                    title: Text(fullName),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
