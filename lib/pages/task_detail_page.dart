// CÓDIGO COMPLETO E ATUALIZADO: lib/pages/task_detail_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final String houseId;
  final List<Map<String, dynamic>> houseMembers;

  const TaskDetailPage({
    super.key,
    required this.taskData,
    required this.houseId,
    required this.houseMembers,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late String? _selectedAssigneeId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedAssigneeId = widget.taskData['assignee_id'];
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await supabase
          .from('kanban_tasks')
          .update({'assignee_id': _selectedAssigneeId})
          .eq('id', widget.taskData['id']);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint("Erro ao salvar tarefa: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar alterações.'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta tarefa? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() => _isLoading = true);
      try {
        await supabase
            .from('kanban_tasks')
            .delete()
            .eq('id', widget.taskData['id']);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        debugPrint("Erro ao excluir tarefa: $e");
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir tarefa.'),
              backgroundColor: Colors.red,
            ),
          );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir Tarefa',
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Tarefa:', style: Theme.of(context).textTheme.titleSmall),
          Text(
            widget.taskData['content'],
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(height: 32),

          Text('Designar para:', style: Theme.of(context).textTheme.titleSmall),
          DropdownButtonFormField<String?>(
            value: _selectedAssigneeId,
            hint: const Text('Selecione um membro'),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: null, child: Text('Ninguém')),
              ...widget.houseMembers.map((member) {
                return DropdownMenuItem(
                  value: member['id'],
                  child: Text(member['full_name'] ?? 'Sem nome'),
                );
              }),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _selectedAssigneeId = newValue;
              });
            },
          ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Salvar Alterações'),
                ),
        ],
      ),
    );
  }
}
