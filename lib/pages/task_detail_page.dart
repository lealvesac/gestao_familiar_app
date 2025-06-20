import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:intl/intl.dart';

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
  late DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa o responsável pela tarefa
    _selectedAssigneeId = widget.taskData['assignee_id'];

    // Inicializa a data de vencimento, se ela existir no banco
    final dueDateString = widget.taskData['due_date'];
    _dueDate = dueDateString != null ? DateTime.parse(dueDateString) : null;
  }

  // Função para abrir o seletor de data (DatePicker)
  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Permite datas passadas
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 5),
      ), // Permite datas futuras
    );
    if (pickedDate != null && mounted) {
      setState(() => _dueDate = pickedDate);
    }
  }

  // Função para salvar todas as alterações (responsável e data)
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await supabase
          .from('kanban_tasks')
          .update({
            'assignee_id': _selectedAssigneeId,
            'due_date': _dueDate
                ?.toIso8601String(), // Envia a data ou null se ela for removida
          })
          .eq('id', widget.taskData['id']);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint("Erro ao salvar tarefa: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar alterações.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Função para excluir a tarefa, com diálogo de confirmação
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir tarefa.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
          Text('Tarefa:', style: Theme.of(context).textTheme.bodySmall),
          Text(
            widget.taskData['content'],
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(height: 32),

          Text('Designar para:', style: Theme.of(context).textTheme.bodySmall),
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
          const Divider(height: 32),

          // --- NOVA SEÇÃO PARA DATA DE VENCIMENTO ---
          Text(
            'Data de Vencimento:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _dueDate == null
                      ? 'Sem data definida'
                      : DateFormat('dd/MM/yyyy').format(_dueDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // Botão para remover a data
              if (_dueDate != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Remover data',
                  onPressed: () => setState(() => _dueDate = null),
                ),
              // Botão para adicionar/editar a data
              TextButton(
                onPressed: _pickDueDate,
                child: Text(_dueDate == null ? 'Adicionar' : 'Alterar'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Alterações'),
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
        ],
      ),
    );
  }
}
