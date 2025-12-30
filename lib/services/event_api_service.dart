import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventApiService {
  static const base = 'http://192.168.1.11:9000/events';

  Future<List<Event>> fetchEvents() async {
    final res = await http.get(Uri.parse('$base/'));
    final List data = json.decode(res.body);
    return data.map((e) => Event.fromJson(e)).toList();
  }

  // ✅ FIXED: JSON BODY
  Future<Event> createEvent(Event event) async {
    final res = await http.post(
      Uri.parse('$base/create_event'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'event_name': event.eventName,
        'location': event.location,
        'event_date': _date(event.dateTime),
        'event_time': _time(event.dateTime),
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return Event.fromJson(json.decode(res.body));
    }

    throw Exception(
      'Create event failed (${res.statusCode}): ${res.body}',
    );
  }

  // ✅ FIXED: JSON BODY
  Future<void> updateEvent(Event event) async {
    final res = await http.put(
      Uri.parse('$base/update_event/${event.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'event_name': event.eventName,
        'location': event.location,
        'event_date': _date(event.dateTime),
        'event_time': _time(event.dateTime),
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Update event failed (${res.statusCode}): ${res.body}',
      );
    }
  }

  Future<void> deleteEvent(int id) async {
    await http.delete(Uri.parse('$base/delete_event/$id'));
  }

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:00';
}
