import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final Box<Event> box;
  Timer? _timer;

  static const primary = Color(0xFF6D4C41);   // Brown 700
  static const secondary = Color(0xFF8D6E63); // Brown 400

  @override
  void initState() {
    super.initState();
    box = Hive.box<Event>('events');
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Event> coming(Iterable<Event> list) =>
      list.where((e) => e.dateTime.isAfter(DateTime.now())).toList();

  List<Event> past(Iterable<Event> list) =>
      list.where((e) => e.dateTime.isBefore(DateTime.now())).toList();


  // Add / Edit Bottom Sheet

  void _showAddEdit([Event? e]) {
    final formKey = GlobalKey<FormState>();

    final nameCtl = TextEditingController(text: e?.name ?? '');
    final locCtl = TextEditingController(text: e?.location ?? '');
    DateTime selectedDate = e?.dateTime ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (ctx2, setSt) => Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      e == null ? "Add Event" : "Edit Event",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Event Name
                    TextFormField(
                      controller: nameCtl,
                      decoration: InputDecoration(
                        labelText: "Event Name",
                        prefixIcon: const Icon(Icons.event),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Event name cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: locCtl,
                      decoration: InputDecoration(
                        labelText: "Location",
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "📅 ${selectedDate.toString().substring(0, 16)}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text("Pick"),
                          onPressed: () async {
                            final now = DateTime.now();

                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                              selectedDate.isBefore(now) ? now : selectedDate,
                              firstDate:
                              DateTime(now.year, now.month, now.day),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: primary,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate == null) return;

                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: primary,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime == null) return;

                            final newDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            if (newDateTime.isBefore(DateTime.now())) return;
                            setSt(() => selectedDate = newDateTime);
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
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;

                            if (e == null) {
                              box.add(Event(
                                name: nameCtl.text.trim(),
                                location: locCtl.text.trim(),
                                dateTime: selectedDate,
                              ));
                            } else {
                              e.name = nameCtl.text.trim();
                              e.location = locCtl.text.trim();
                              e.dateTime = selectedDate;
                              e.save();
                            }
                            Navigator.pop(ctx);
                          },
                          child: Text(e == null ? "Add Event" : "Save"),
                        ),
                      ],
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

  // Swipe to Delete Card
  Widget eventTile(Event e) {
    return Dismissible(
      key: ValueKey(e.key),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.brown.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => e.delete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: () => _showAddEdit(e),
          leading: const Icon(Icons.event, color: primary),
          title: Text(
            e.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${e.location}\n${e.dateTime.toString().substring(0, 16)}",
          ),
          isThreeLine: true,
          trailing: const Icon(
            Icons.edit,
            size: 18,
            color: primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Events", style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.event), text: "Coming"),
              Tab(icon: Icon(Icons.event_available), text: "Past"),
            ],
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (_, Box<Event> b, _) {
            final events = b.values.toList();
            return TabBarView(
              children: [
                ListView(children: coming(events).map(eventTile).toList()),
                ListView(children: past(events).map(eventTile).toList()),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primary,
          onPressed: () => _showAddEdit(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
