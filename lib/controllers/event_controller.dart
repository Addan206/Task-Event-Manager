import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_api_service.dart';

class EventController extends ChangeNotifier {
  final _api = EventApiService();

  List<Event> events = [];
  bool isLoading = false;

  Future<void> loadEvents() async {
    isLoading = true;
    notifyListeners();

    events = await _api.fetchEvents();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(Event e) async {
    final created = await _api.createEvent(e);
    events.add(created);
    notifyListeners();
  }

  Future<void> updateEvent(Event e) async {
    await _api.updateEvent(e);
    final i = events.indexWhere((x) => x.id == e.id);
    if (i != -1) events[i] = e;
    notifyListeners();
  }

  Future<void> deleteEvent(Event e) async {
    await _api.deleteEvent(e.id!);
    events.removeWhere((x) => x.id == e.id);
    notifyListeners();
  }
}
