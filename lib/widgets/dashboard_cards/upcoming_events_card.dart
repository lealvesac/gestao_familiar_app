// lib/widgets/dashboard_cards/upcoming_events_card.dart
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:intl/intl.dart';

class UpcomingEventsCard extends StatefulWidget {
  final String houseId;
  const UpcomingEventsCard({super.key, required this.houseId});

  @override
  State<UpcomingEventsCard> createState() => _UpcomingEventsCardState();
}

class _UpcomingEventsCardState extends State<UpcomingEventsCard> {
  late final Future<List<Map<String, dynamic>>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = supabase.rpc('get_upcoming_events', params: {'p_house_id': widget.houseId});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Próximos Eventos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum evento futuro.'));
                }
                final events = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final startTime = DateTime.parse(event['start_time']).toLocal();
                    return Text('${DateFormat('dd/MM HH:mm').format(startTime)} - ${event['title']}');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}