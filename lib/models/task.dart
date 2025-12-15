import 'package:hive/hive.dart';

class Task extends HiveObject {
  String title;
  String note;
  final DateTime createdAt;
  bool isCompleted;

  Task({
    required this.title,
    this.note = '',
    DateTime? createdAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader r) {
    final title = r.readString();
    final note = r.readString();
    final created = r.readInt();
    final completed = r.readBool();
    return Task(
      title: title,
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(created),
      isCompleted: completed,
    );
  }

  @override
  void write(BinaryWriter w, Task t) {
    w.writeString(t.title);
    w.writeString(t.note);
    w.writeInt(t.createdAt.millisecondsSinceEpoch);
    w.writeBool(t.isCompleted);
  }
}
