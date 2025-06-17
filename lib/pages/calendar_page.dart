import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/add_edit_event_page.dart'; // <-- IMPORT DA NOVA PÁGINA
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final String houseId;
  const CalendarPage({super.key, required this.houseId});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  LinkedHashMap<DateTime, List<dynamic>> _events = LinkedHashMap(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  );
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    final response = await supabase
        .from('calendar_events')
        .select()
        .eq('house_id', widget.houseId);

    final newEvents = LinkedHashMap<DateTime, List<dynamic>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    for (final event in response) {
      final day = DateTime.parse(event['start_time']).toLocal();
      if (newEvents[day] == null) {
        newEvents[day] = [];
      }
      newEvents[day]!.add(event);
    }

    setState(() {
      _events = newEvents;
    });
    // Atualiza a lista de eventos para o dia selecionado
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Retorna a lista de eventos para um determinado dia
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
            locale: 'pt_BR', // Para o calendário ficar em português
            calendarFormat: CalendarFormat.month,
            eventLoader:
                _getEventsForDay, // Mostra os marcadores nos dias com evento
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<dynamic>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        // AO TOCAR EM UM EVENTO, ABRE A TELA DE EDIÇÃO
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditEventPage(
                                event: event,
                                houseId: widget.houseId,
                              ),
                            ),
                          );
                          // Após voltar da tela de edição, atualiza a lista
                          _fetchEvents();
                        },
                        title: Text('${event['title']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // AO TOCAR NO BOTÃO '+', ABRE A TELA PARA CRIAÇÃO
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditEventPage(houseId: widget.houseId),
            ),
          );
          // Após voltar da tela de criação, atualiza a lista
          _fetchEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
