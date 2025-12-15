import 'package:hive/hive.dart';

class Event extends HiveObject {
  String name;
  String location;
  DateTime dateTime;
  final DateTime createdAt;
  String note;

  Event({
    required this.name,
    this.location = '',
    required this.dateTime,
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Manual Hive adapter for Event (typeId = 1)
class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 1;

  @override
  Event read(BinaryReader r) {
    final name = r.readString();
    final location = r.readString();
    final dateMs = r.readInt();
    final note = r.readString();
    final createdMs = r.readInt();
    return Event(
      name: name,
      location: location,
      dateTime: DateTime.fromMillisecondsSinceEpoch(dateMs),
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdMs),
    );
  }

  @override
  void write(BinaryWriter w, Event obj) {
    w.writeString(obj.name);
    w.writeString(obj.location);
    w.writeInt(obj.dateTime.millisecondsSinceEpoch);
    w.writeString(obj.note);
    w.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
