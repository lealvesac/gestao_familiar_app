import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/board_detail_page.dart';
import 'package:animate_do/animate_do.dart';

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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddBoardDialog() async {
    final boardNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    void submit() async {
      if (formKey.currentState!.validate()) {
        try {
          await supabase.from('task_boards').insert({
            'name': boardNameController.text.trim(),
            'house_id': widget.houseId,
          });
          if (mounted) Navigator.of(context).pop();
          _getBoards();
        } catch (e) {
          debugPrint("Erro ao criar quadro: $e");
        }
      }
    }

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
              autofocus: true,
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'O nome é obrigatório.'
                  : null,
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(onPressed: submit, child: const Text('Criar')),
          ],
        );
      },
    );
  }

  // --- NOVA FUNÇÃO PARA EXCLUIR UM QUADRO ---
  Future<void> _deleteBoard(int boardId, String boardName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o quadro "$boardName"?\n\nATENÇÃO: Todas as listas e tarefas contidas neste quadro serão permanentemente excluídas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir Tudo'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await supabase.from('task_boards').delete().eq('id', boardId);
        _getBoards(); // Atualiza a lista de quadros na tela
      } catch (e) {
        debugPrint("Erro ao excluir o quadro: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir quadro.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ), // Espaço para o botão flutuante não cobrir o último item
                      itemCount: _boards.length,
                      itemBuilder: (context, index) {
                        final board = _boards[index];

                        return FadeInUp(
                          delay: Duration(
                            milliseconds: 100 * index,
                          ), // Atraso para cada item aparecer em sequência
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.dashboard_outlined),
                              title: Text(board['name']),
                              // --- MUDANÇA AQUI: de Ícone para Menu ---
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteBoard(board['id'], board['name']);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Excluir Quadro'),
                                  ),
                                  // No futuro, poderíamos adicionar "Renomear", etc.
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BoardDetailPage(
                                      boardId: board['id'],
                                      boardName: board['name'],
                                      houseId: widget.houseId,
                                    ),
                                  ),
                                );
                              },
                            ),
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
