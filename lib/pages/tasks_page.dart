import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/board_detail_page.dart';

class TasksPage extends StatefulWidget {
  final String houseId;
  const TasksPage({super.key, required this.houseId});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Map<String, dynamic>> _boards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getBoards();
  }

  Future<void> _getBoards() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('task_boards')
          .select()
          .eq('house_id', widget.houseId)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _boards = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar quadros: $e");
      // Lidar com erro
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddBoardDialog() async {
    final boardNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar Novo Quadro'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: boardNameController,
              decoration: const InputDecoration(labelText: 'Nome do Quadro'),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'O nome é obrigatório.'
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await supabase.from('task_boards').insert({
                      'name': boardNameController.text.trim(),
                      'house_id': widget.houseId,
                    });
                    if (mounted) Navigator.of(context).pop();
                    _getBoards(); // Atualiza a lista de quadros
                  } catch (e) {
                    // Lidar com erro
                  }
                }
              },
              child: const Text('Criar'),
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
          : RefreshIndicator(
              onRefresh: _getBoards,
              child: _boards.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum quadro de tarefas criado. Crie o primeiro!',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _boards.length,
                      itemBuilder: (context, index) {
                        final board = _boards[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(board['name']),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  // Navega para a página de detalhes do quadro
                                  builder: (_) => BoardDetailPage(
                                    boardId: board['id'],
                                    boardName: board['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Novo Quadro'),
        onPressed: _showAddBoardDialog,
      ),
    );
  }
}
