class Task {
  final int id;
  String title;
  String description;
  String location;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      isCompleted: json['completed'] as bool,
    );
  }
}
