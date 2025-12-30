class Event {
  final int? id;
  String eventName;
  String location;
  DateTime dateTime;

  Event({
    this.id,
    required this.eventName,
    required this.location,
    required this.dateTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['event_name'] as String,
      location: json['location'] as String,
      dateTime: DateTime.parse(
        '${json['event_date']} ${json['event_time']}',
      ),
    );
  }

  /// EXACT FORMAT REQUIRED BY FASTAPI
  Map<String, String> toQuery() {
    final d = dateTime;
    return {
      'event_name': eventName,
      'location': location,
      'event_date':
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      'event_time':
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:00',
    };
  }

  Event copyWith({
    String? eventName,
    String? location,
    DateTime? dateTime,
  }) {
    return Event(
      id: id,
      eventName: eventName ?? this.eventName,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
