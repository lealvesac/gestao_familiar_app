import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:intl/intl.dart';

class AddEditEventPage extends StatefulWidget {
  // Recebe um evento existente para o modo de edição. Se for nulo, está no modo de criação.
  final Map<String, dynamic>? event;
  final String houseId;

  const AddEditEventPage({super.key, this.event, required this.houseId});

  @override
  State<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _startDate;
  late DateTime _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Se um evento foi passado, preenche o formulário com seus dados (modo de edição)
    if (widget.event != null) {
      _titleController.text = widget.event!['title'];
      _descriptionController.text = widget.event!['description'] ?? '';
      _startDate = DateTime.parse(widget.event!['start_time']).toLocal();
      _endDate = DateTime.parse(widget.event!['end_time']).toLocal();
    } else {
      // Senão, inicializa com valores padrão (modo de criação)
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(hours: 1));
    }
  }

  // Função para abrir o seletor de data
  Future<void> _pickDate(bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      // Combina a data escolhida com a hora que já estava definida
      final currentTme = TimeOfDay.fromDateTime(
        isStartDate ? _startDate : _endDate,
      );
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            currentTme.hour,
            currentTme.minute,
          );
        } else {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            currentTme.hour,
            currentTme.minute,
          );
        }
      });
    }
  }

  // Função para abrir o seletor de hora
  Future<void> _pickTime(bool isStartDate) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartDate ? _startDate : _endDate),
    );

    if (pickedTime != null) {
      // Combina a hora escolhida com a data que já estava definida
      final currentDate = isStartDate ? _startDate : _endDate;
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _endDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        }
      });
    }
  }

  // Função principal para salvar (criar ou atualizar) o evento
  Future<void> _saveEvent() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final eventData = {
      'house_id': widget.houseId,
      'profile_id': supabase.auth.currentUser!.id,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'start_time': _startDate.toUtc().toIso8601String(),
      'end_time': _endDate.toUtc().toIso8601String(),
    };

    try {
      if (widget.event == null) {
        // Modo de criação: insere um novo evento
        await supabase.from('calendar_events').insert(eventData);
      } else {
        // Modo de edição: atualiza um evento existente
        await supabase
            .from('calendar_events')
            .update(eventData)
            .eq('id', widget.event!['id']);
      }
      if (mounted) Navigator.of(context).pop(); // Volta para o calendário
    } catch (e) {
      //... (lidar com erro)
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Função para excluir o evento
  Future<void> _deleteEvent() async {
    // Mostra um diálogo de confirmação antes de excluir
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() => _isLoading = true);
      try {
        await supabase
            .from('calendar_events')
            .delete()
            .eq('id', widget.event!['id']);
        if (mounted) Navigator.of(context).pop(); // Volta para o calendário
      } catch (e) {
        //... (lidar com erro)
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um formatador para mostrar a data e hora de forma amigável
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null ? 'Adicionar Evento' : 'Editar Evento',
        ),
        // Mostra o botão de excluir apenas no modo de edição
        actions: [
          if (widget.event != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir Evento',
              onPressed: _deleteEvent,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título do Evento'),
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'O título é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (Opcional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text('Início', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateFormat.format(_startDate)),
                    onPressed: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(timeFormat.format(_startDate)),
                    onPressed: () => _pickTime(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Fim', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateFormat.format(_endDate)),
                    onPressed: () => _pickDate(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(timeFormat.format(_endDate)),
                    onPressed: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Evento'),
                    onPressed: _saveEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
