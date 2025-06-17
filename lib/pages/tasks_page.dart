// NOVO ARQUIVO: lib/pages/tasks_page.dart
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';

class TasksPage extends StatefulWidget {
  final String houseId;
  const TasksPage({super.key, required this.houseId});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getTasks();
  }

  Future<void> _getTasks() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('tasks')
          .select()
          .eq('house_id', widget.houseId)
          .order('created_at', ascending: true);
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Erro ao buscar tarefas: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTaskStatus(int taskId, bool newStatus) async {
    try {
      await supabase
          .from('tasks')
          .update({'is_complete': newStatus})
          .eq('id', taskId);
    } catch (e) {
      debugPrint("Erro ao atualizar tarefa: $e");
      // Se der erro, podemos reverter a mudança na UI ou mostrar um aviso
    }
  }
  void _showAddTaskDialog() {
    final taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: TextFormField(
            controller: taskController,
            decoration: const InputDecoration(
              labelText: 'O que precisa ser feito?',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final taskContent = taskController.text.trim();
                if (taskContent.isEmpty) return;

                try {
                  // Insere a nova tarefa no banco de dados
                  await supabase.from('tasks').insert({
                    'content': taskContent,
                    'house_id': widget.houseId,
                  });
                  if (mounted) {
                    Navigator.of(context).pop(); // Fecha o diálogo
                    _getTasks(); // Atualiza a lista de tarefas na tela
                  }
                } catch (e) {
                  debugPrint("Erro ao criar tarefa: $e");
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? const Center(child: Text('Nenhuma tarefa ainda. Adicione uma!'))
          : RefreshIndicator(
              onRefresh: _getTasks,
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return CheckboxListTile(
                    title: Text(task['content']),
                    value: task['is_complete'],
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      setState(() => task['is_complete'] = newValue);
                      _toggleTaskStatus(task['id'], newValue);
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
