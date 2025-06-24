import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:intl/intl.dart';

class AddEditEventPage extends StatefulWidget {
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

  List<Map<String, dynamic>> _houseMembers = [];
  List<String> _selectedParticipantIds = [];

  @override
  void initState() {
    super.initState();
    _fetchHouseMembers();

    if (widget.event != null) {
      _titleController.text = widget.event!['title'];
      _descriptionController.text = widget.event!['description'] ?? '';
      _startDate = DateTime.parse(widget.event!['start_time']).toLocal();
      _endDate = DateTime.parse(widget.event!['end_time']).toLocal();

      if (widget.event!['participants'] != null) {
        final participants = List<Map<String, dynamic>>.from(
          widget.event!['participants'],
        );
        _selectedParticipantIds = participants
            .map((p) => p['id'] as String)
            .toList();
      }
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchHouseMembers() async {
    try {
      final response = await supabase.rpc(
        'get_house_members',
        params: {'p_house_id': widget.houseId},
      );
      if (mounted) {
        setState(() {
          _houseMembers = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar membros da casa: $e");
    }
  }

  Future<void> _pickDate(bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final currentTime = TimeOfDay.fromDateTime(
        isStartDate ? _startDate : _endDate,
      );
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            currentTime.hour,
            currentTime.minute,
          );
        } else {
          _endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            currentTime.hour,
            currentTime.minute,
          );
        }
      });
    }
  }

  Future<void> _pickTime(bool isStartDate) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartDate ? _startDate : _endDate),
    );

    if (pickedTime != null) {
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

  Future<void> _saveEvent() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      await supabase.rpc(
        'create_or_update_event',
        params: {
          'p_house_id': widget.houseId,
          'p_title': _titleController.text.trim(),
          'p_description': _descriptionController.text.trim(),
          'p_start_time': _startDate.toUtc().toIso8601String(),
          'p_end_time': _endDate.toUtc().toIso8601String(),
          'p_participant_ids': _selectedParticipantIds,
          'p_event_id': widget.event?['id'],
        },
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint("Erro ao salvar evento: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar evento.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent() async {
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
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        // ... (lidar com erro)
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
    final timeFormat = DateFormat('HH:mm', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null ? 'Adicionar Evento' : 'Editar Evento',
        ),
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
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateFormat.format(_startDate)),
                    onPressed: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
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
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateFormat.format(_endDate)),
                    onPressed: () => _pickDate(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(timeFormat.format(_endDate)),
                    onPressed: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Participantes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_houseMembers.isEmpty)
              const Center(child: Text('Carregando membros...'))
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _houseMembers.length,
                  itemBuilder: (context, index) {
                    final member = _houseMembers[index];
                    return CheckboxListTile(
                      title: Text(member['full_name'] ?? 'Sem nome'),
                      value: _selectedParticipantIds.contains(member['id']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedParticipantIds.add(member['id']);
                          } else {
                            _selectedParticipantIds.remove(member['id']);
                          }
                        });
                      },
                    );
                  },
                ),
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
