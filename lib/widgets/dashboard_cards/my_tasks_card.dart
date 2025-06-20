// lib/widgets/dashboard_cards/my_tasks_card.dart
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';

class MyTasksCard extends StatefulWidget {
  final String userId;
  const MyTasksCard({super.key, required this.userId});

  @override
  State<MyTasksCard> createState() => _MyTasksCardState();
}

class _MyTasksCardState extends State<MyTasksCard> {
  late final Future<List<Map<String, dynamic>>> _futureTasks;

  @override
  void initState() {
    super.initState();
    _futureTasks = supabase.rpc(
      'get_my_pending_tasks',
      params: {'p_user_id': widget.userId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minhas Tarefas Pendentes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureTasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma tarefa para você. Bom trabalho!'),
                  );
                }
                final tasks = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Text('• ${task['content']}');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
