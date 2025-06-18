import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/task_detail_page.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> _listsFromDB = [];
  List<DragAndDropList> _dragAndDropLists = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _houseMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // --- FUNÇÕES DE DADOS (NENHUMA MUDANÇA AQUI) ---
  Future<void> _fetchInitialData() async {
    setStateIfMounted(() => _isLoading = true);
    await Future.wait([_getBoardDetails(), _fetchHouseMembers()]);
    setStateIfMounted(() => _isLoading = false);
  }

  Future<void> _getBoardDetails() async {
    try {
      final response = await supabase.rpc(
        'get_board_details',
        params: {'p_board_id': widget.boardId},
      );
      if (mounted) {
        _listsFromDB = List<Map<String, dynamic>>.from(response);
        _buildDragAndDropContent();
      }
    } catch (e) {
      debugPrint("Erro ao buscar detalhes do quadro: $e");
      showErrorSnackBar('Erro ao carregar o quadro.');
    }
  }

  Future<void> _fetchHouseMembers() async {
    try {
      final response = await supabase.rpc(
        'get_house_members',
        params: {'p_house_id': widget.houseId},
      );
      if (mounted) {
        _houseMembers = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      debugPrint("Erro ao buscar membros da casa: $e");
    }
  }

  Future<void> _moveTask(
    int taskId,
    int newListId,
    int newPositionInList,
  ) async {
    try {
      await supabase.rpc(
        'move_task',
        params: {
          'p_task_id': taskId,
          'p_new_list_id': newListId,
          'p_new_position': newPositionInList,
        },
      );
    } catch (e) {
      debugPrint("Erro ao mover tarefa: $e");
      showErrorSnackBar('Erro ao sincronizar. Tente recarregar.');
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
        showErrorSnackBar('Erro ao excluir lista.');
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
              final newListData = await supabase.from('task_lists').insert({
                'name': listNameController.text.trim(),
                'board_id': widget.boardId,
                'position': _listsFromDB.length,
              }).select();
              if (mounted) Navigator.of(dialogContext).pop();
              setState(() {
                final newListMap = newListData.first;
                newListMap['list_id'] = newListMap['id'];
                newListMap['list_name'] = newListMap['name'];
                newListMap['list_position'] = newListMap['position'];
                _listsFromDB.add(newListMap);
                _buildDragAndDropContent();
              });
            } catch (e) {
              debugPrint("Erro ao criar lista: $e");
              showErrorSnackBar('Erro ao criar lista.');
            }
          }
        }

        return AlertDialog(
          title: const Text('Criar Nova Lista'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: listNameController,
              decoration: const InputDecoration(labelText: 'Nome da Lista'),
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
              final newTaskData = await supabase.from('kanban_tasks').insert({
                'content': taskContentController.text.trim(),
                'list_id': listId,
                'position': currentTaskCount,
              }).select();
              if (mounted) Navigator.of(dialogContext).pop();
              setState(() {
                final listIndex = _listsFromDB.indexWhere(
                  (list) => list['list_id'] == listId,
                );
                if (listIndex != -1) {
                  if (_listsFromDB[listIndex]['tasks'] == null) {
                    _listsFromDB[listIndex]['tasks'] = <Map<String, dynamic>>[];
                  }
                  _listsFromDB[listIndex]['tasks'].add(newTaskData.first);
                }
                _buildDragAndDropContent();
              });
            } catch (e) {
              debugPrint("Erro ao criar tarefa: $e");
              showErrorSnackBar('Erro ao criar tarefa.');
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

  // --- FUNÇÕES DE LÓGICA DO DRAG AND DROP (NENHUMA MUDANÇA AQUI) ---
  void _onItemReorder(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) {
    final taskData = _listsFromDB[oldListIndex]['tasks'][oldItemIndex];
    final taskId = taskData['id'];
    final newListId = _listsFromDB[newListIndex]['list_id'];

    setState(() {
      final movedItemData = _listsFromDB[oldListIndex]['tasks'].removeAt(
        oldItemIndex,
      );
      if (_listsFromDB[newListIndex]['tasks'] == null) {
        _listsFromDB[newListIndex]['tasks'] = <Map<String, dynamic>>[];
      }
      _listsFromDB[newListIndex]['tasks'].insert(newItemIndex, movedItemData);
      _buildDragAndDropContent();
    });

    _moveTask(taskId, newListId, newItemIndex);
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      final movedListData = _listsFromDB.removeAt(oldListIndex);
      _listsFromDB.insert(newListIndex, movedListData);
      _buildDragAndDropContent();
    });
    // TODO: Chamar RPC para persistir a ordem das listas
  }

  // --- FUNÇÕES DE CONSTRUÇÃO DA UI (COM MUDANÇAS) ---

  void _buildDragAndDropContent() {
    _dragAndDropLists = _listsFromDB.map((listData) {
      final tasksFromDB =
          (listData['tasks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return DragAndDropList(
        header: _buildListHeader(listData),
        footer: _buildListFooter(listData, tasksFromDB.length),
        children: tasksFromDB
            .map(
              (taskData) => DragAndDropItem(
                // Passamos o nome da lista para o cartão da tarefa
                child: _buildTaskCard(taskData, listData['list_name']),
              ),
            )
            .toList(),
      );
    }).toList();
    setStateIfMounted(() {});
  }

  // A função agora recebe o nome da lista para decidir o estilo
  Widget _buildTaskCard(Map<String, dynamic> taskData, String listName) {
    final assigneeName = taskData['assignee_full_name'];
    final dueDateString = taskData['due_date'];
    DateTime? dueDate = dueDateString != null
        ? DateTime.parse(dueDateString)
        : null;
    bool isOverdue =
        dueDate != null &&
        dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    // --- LÓGICA DO CHECK-IN DE CONCLUSÃO ---
    // Considera a tarefa concluída se estiver em uma lista chamada "Feito" ou "Concluído"
    final bool isCompleted = [
      'feito',
      'concluído',
      'done',
    ].contains(listName.toLowerCase());

    return GestureDetector(
      key: ValueKey(taskData['id']),
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
        // Muda a cor do cartão se a tarefa estiver concluída
        color: isCompleted ? Colors.grey.shade100 : Colors.white,
        elevation: isCompleted ? 1 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DragHandle(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                      child: Icon(
                        // Se estiver concluída, mostra um check, senão o puxador
                        isCompleted ? Icons.check_circle : Icons.drag_indicator,
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      taskData['content'],
                      // Aplica o estilo de texto riscado se a tarefa estiver concluída
                      style: TextStyle(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isCompleted
                            ? Colors.grey.shade700
                            : Colors.black87,
                        fontStyle: isCompleted
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  if (assigneeName != null && assigneeName.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 14,
                      child: Text(
                        assigneeName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
              if (dueDate != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Chip(
                    avatar: Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isOverdue
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                    ),
                    label: Text(
                      DateFormat('dd/MM/yy', 'pt_BR').format(dueDate),
                      style: TextStyle(
                        fontSize: 10,
                        color: isOverdue
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                    backgroundColor: isOverdue
                        ? Colors.red.shade100
                        : Colors.grey.shade300,
                    padding: const EdgeInsets.all(2),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // O resto do arquivo continua igual
  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  void showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildListHeader(Map<String, dynamic> listData) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 4.0,
        top: 8.0,
        bottom: 4.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              listData['list_name'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }

  Widget _buildListFooter(Map<String, dynamic> listData, int taskCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Adicionar Tarefa'),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
          onPressed: () => _showAddTaskDialog(listData['list_id'], taskCount),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DragAndDropLists(
              children: _dragAndDropLists,
              onItemReorder: _onItemReorder,
              onListReorder: _onListReorder,
              listPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 16,
              ),
              itemDragOnLongPress: false,
              itemDragHandle: const DragHandle(
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.drag_indicator, color: Colors.grey),
                ),
              ),
              listDragOnLongPress: true,
              listWidth: 300,
              listDecoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_road),
        label: const Text('Nova Lista'),
        onPressed: _showAddListDialog,
      ),
    );
  }
}
