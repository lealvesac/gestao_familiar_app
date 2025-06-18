// CÓDIGO COMPLETO E CORRIGIDO: lib/pages/board_detail_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/task_detail_page.dart';

class BoardDetailPage extends StatefulWidget {
  final int boardId;
  final String boardName;
  final String houseId;

  const BoardDetailPage({
    super.key,
    required this.boardId,
    required this.boardName,
    required this.houseId,
  });

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  List<Map<String, dynamic>> _lists = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _houseMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([_getBoardDetails(), _fetchHouseMembers()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getBoardDetails() async {
    try {
      final response = await supabase.rpc(
        'get_board_details',
        params: {'p_board_id': widget.boardId},
      );
      if (mounted) {
        setState(() {
          _lists = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar detalhes do quadro: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar o quadro.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchHouseMembers() async {
    try {
      final response = await supabase.rpc(
        'get_house_members',
        params: {'p_house_id': widget.houseId},
      );
      if (mounted) {
        setState(
          () => _houseMembers = List<Map<String, dynamic>>.from(response),
        );
      }
    } catch (e) {
      debugPrint("Erro ao buscar membros da casa: $e");
    }
  }

  Future<void> _deleteList(int listId, String listName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a lista "$listName"?\n\nTODAS as tarefas contidas nela também serão excluídas.',
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
      try {
        await supabase.from('task_lists').delete().eq('id', listId);
        _getBoardDetails();
      } catch (e) {
        debugPrint("Erro ao excluir lista: $e");
      }
    }
  }

  Future<void> _showAddListDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        final listNameController = TextEditingController();

        void submit() async {
          if (formKey.currentState!.validate()) {
            try {
              final newPosition = _lists.length;
              await supabase.from('task_lists').insert({
                'name': listNameController.text.trim(),
                'board_id': widget.boardId,
                'position': newPosition,
              });
              if (mounted) Navigator.of(dialogContext).pop();
              _getBoardDetails();
            } catch (e) {
              debugPrint("Erro ao criar lista: $e");
            }
          }
        }

        return AlertDialog(
          title: const Text('Criar Nova Lista'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: listNameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Lista (Ex: A Fazer)',
              ),
              autofocus: true,
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'O nome é obrigatório.'
                  : null,
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(onPressed: submit, child: const Text('Criar')),
          ],
        );
      },
    );
  }

  Future<void> _showAddTaskDialog(int listId, int currentTaskCount) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        final taskContentController = TextEditingController();

        void submit() async {
          if (formKey.currentState!.validate()) {
            try {
              await supabase.from('kanban_tasks').insert({
                'content': taskContentController.text.trim(),
                'list_id': listId,
                'position': currentTaskCount,
              });
              if (mounted) Navigator.of(dialogContext).pop();
              _getBoardDetails();
            } catch (e) {
              debugPrint("Erro ao criar tarefa: $e");
            }
          }
        }

        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: taskContentController,
              decoration: const InputDecoration(
                labelText: 'Descrição da Tarefa',
              ),
              autofocus: true,
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'A descrição é obrigatória.'
                  : null,
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(onPressed: submit, child: const Text('Criar')),
          ],
        );
      },
    );
  }

  // --- FUNÇÃO QUE FALTAVA Nº 1: CONSTRUIR O CARTÃO DE TAREFA ---
  Widget _buildTaskCard(Map<String, dynamic> taskData) {
    final assigneeName = taskData['assignee_full_name'];

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(
              taskData: taskData,
              houseId: widget.houseId,
              houseMembers: _houseMembers,
            ),
          ),
        );
        _getBoardDetails();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(taskData['content'])),
              const SizedBox(width: 8),
              if (assigneeName != null && assigneeName.isNotEmpty)
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    assigneeName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNÇÃO QUE FALTAVA Nº 2: CONSTRUIR A COLUNA DA LISTA ---
  Widget _buildTaskListColumn(Map<String, dynamic> listData) {
    final tasks =
        (listData['tasks'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      width: 300,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    listData['list_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteList(listData['list_id'], listData['list_name']);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Excluir Lista'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 8, endIndent: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final taskData = tasks[index];
                return _buildTaskCard(taskData);
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar Tarefa'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              onPressed: () =>
                  _showAddTaskDialog(listData['list_id'], tasks.length),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lists.isEmpty
          ? Center(
              child: Text(
                'Nenhuma lista criada neste quadro ainda.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _lists.length,
              itemBuilder: (context, index) {
                final listData = _lists[index];
                return _buildTaskListColumn(listData);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_road),
        label: const Text('Nova Lista'),
        onPressed: _showAddListDialog,
      ),
    );
  }
}
