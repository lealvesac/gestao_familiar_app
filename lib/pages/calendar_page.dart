// ARQUIVO COMPLETO E CORRIGIDO: lib/pages/calendar_page.dart

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/add_edit_event_page.dart';
import 'package:table_calendar/table_calendar.dart'; // <-- IMPORT CORRIGIDO

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
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Map<String, dynamic>> _houseMembers = [];
  Set<String> _selectedMemberIds = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchInitialData();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchEvents();
    await _fetchHouseMembers();
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
      debugPrint("Erro ao buscar membros: $e");
    }
  }

  Future<void> _fetchEvents() async {
    final response = await supabase.rpc(
      'get_events_for_house',
      params: {'p_house_id': widget.houseId},
    );

    final newEvents = LinkedHashMap<DateTime, List<dynamic>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    for (final event in response) {
      final day = DateTime.parse(event['start_time']).toLocal();
      final normalizedDay = DateTime.utc(day.year, day.month, day.day);

      if (newEvents[normalizedDay] == null) {
        newEvents[normalizedDay] = [];
      }
      newEvents[normalizedDay]!.add(event);
    }

    if (mounted) {
      setState(() {
        _events = newEvents;
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
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

  Widget _buildMemberFilterChips() {
    if (_houseMembers.isEmpty) return const SizedBox.shrink();

    List<Widget> chips = [];

    chips.add(
      FilterChip(
        label: const Text('Todos'),
        selected: _selectedMemberIds.isEmpty,
        onSelected: (bool selected) {
          setState(() {
            _selectedMemberIds.clear();
          });
        },
      ),
    );

    for (final member in _houseMembers) {
      chips.add(
        FilterChip(
          label: Text(member['full_name'] ?? 'Sem nome'),
          selected: _selectedMemberIds.contains(member['id']),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedMemberIds.add(member['id']);
              } else {
                _selectedMemberIds.remove(member['id']);
              }
            });
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(spacing: 8.0, runSpacing: 4.0, children: chips),
    );
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
            locale: 'pt_BR',
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mês',
              CalendarFormat.twoWeeks: '2 Semanas',
              CalendarFormat.week: 'Semana',
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          _buildMemberFilterChips(),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder<List<dynamic>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                final filteredEvents = value.where((event) {
                  if (_selectedMemberIds.isEmpty) return true;
                  final participants =
                      (event['participants'] as List?)
                          ?.cast<Map<String, dynamic>>() ??
                      [];
                  return participants.any(
                    (participant) =>
                        _selectedMemberIds.contains(participant['id']),
                  );
                }).toList();

                if (filteredEvents.isEmpty) {
                  return const Center(
                    child: Text('Nenhum evento para a seleção atual.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    final participants =
                        (event['participants'] as List?)
                            ?.cast<Map<String, dynamic>>() ??
                        [];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditEventPage(
                                event: event,
                                houseId: widget.houseId,
                              ),
                            ),
                          );
                          _fetchEvents();
                        },
                        title: Text('${event['title']}'),
                        subtitle: participants.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 6.0,
                                  runSpacing: 4.0,
                                  children: participants
                                      .map(
                                        (p) => Chip(
                                          label: Text(
                                            p['full_name'] ?? '?',
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.all(2),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                            : null,
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
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditEventPage(houseId: widget.houseId),
            ),
          );
          _fetchEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
