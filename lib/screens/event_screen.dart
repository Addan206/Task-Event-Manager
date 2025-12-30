import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../controllers/event_controller.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const primary = Color(0xFF6D4C41);
  static const surface = Color(0xFFD7CCC8);

  final _formKey = GlobalKey<FormState>();
  final Set<int> _selectedIds = {};

  List<Event> coming(List<Event> list) =>
      list.where((e) => e.dateTime.isAfter(DateTime.now())).toList();

  List<Event> past(List<Event> list) =>
      list.where((e) => e.dateTime.isBefore(DateTime.now())).toList();

  // ---------------- ADD / EDIT ----------------
  void _showAddEditSheet({Event? event}) {
    final nameCtl = TextEditingController(text: event?.eventName ?? '');
    final locCtl = TextEditingController(text: event?.location ?? '');
    DateTime selectedDate = event?.dateTime ?? DateTime.now();

    final controller = context.read<EventController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (_, setSt) => Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event == null ? "Add Event" : "Edit Event",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: nameCtl,
                    decoration: const InputDecoration(
                      labelText: "Event Name",
                      prefixIcon: Icon(Icons.event),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: locCtl,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate.toString().substring(0, 16),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.calendar_today, color: Colors.white),
                        label: const Text("Pick"),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date == null) return;

                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                            TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (time == null) return;

                          setSt(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (event == null) {
                        await controller.addEvent(
                          Event(
                            eventName: nameCtl.text.trim(),
                            location: locCtl.text.trim(),
                            dateTime: selectedDate,
                          ),
                        );
                      } else {
                        await controller.updateEvent(
                          event.copyWith(
                            eventName: nameCtl.text.trim(),
                            location: locCtl.text.trim(),
                            dateTime: selectedDate,
                          ),
                        );
                      }

                      Navigator.pop(ctx);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),

            ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- TILE ----------------
  Widget _eventTile(Event e) {
    final selected = _selectedIds.contains(e.id);

    return Card(
      color: selected ? surface.withOpacity(0.5) : primary,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(
          selected ? Icons.check_circle : Icons.event,
          color: Colors.white,
        ),
        title: Text(
          e.eventName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "${e.location}\n${e.dateTime.toString().substring(0, 16)}",
          style: const TextStyle(color: Colors.white70),
        ),
        isThreeLine: true,
        onTap: _selectedIds.isNotEmpty
            ? () {
          setState(() {
            selected
                ? _selectedIds.remove(e.id)
                : _selectedIds.add(e.id!);
          });
        }
            : () => _showAddEditSheet(event: e),
        onLongPress: () {
          setState(() {
            selected
                ? _selectedIds.remove(e.id)
                : _selectedIds.add(e.id!);
          });
        },
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Consumer<EventController>(
      builder: (context, controller, _) {
        final upcoming = coming(controller.events);
        final pastEvents = past(controller.events);

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: surface,
            appBar: AppBar(
              backgroundColor: primary,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Events",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                        (_) => false,
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () async {
                      for (final id in _selectedIds) {
                        final e = controller.events
                            .firstWhere((x) => x.id == id);
                        await controller.deleteEvent(e);
                      }
                      setState(() => _selectedIds.clear());
                    },
                  ),
              ],
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.event), text: "Coming"),
                  Tab(
                    icon: Icon(Icons.event_available),
                    text: "Past",
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                upcoming.isEmpty
                    ? const Center(child: Text("No upcoming events"))
                    : ListView(
                  children: upcoming.map(_eventTile).toList(),
                ),
                pastEvents.isEmpty
                    ? const Center(child: Text("No past events"))
                    : ListView(
                  children: pastEvents.map(_eventTile).toList(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primary,
              onPressed: () => _showAddEditSheet(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
