import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskApiService {
  static const base = 'http://192.168.1.11:9000/tasks';

  Future<List<Task>> fetchTasks() async {
    final res = await http.get(Uri.parse('$base/'));
    final List data = json.decode(res.body);
    return data.map((e) => Task.fromJson(e)).toList();
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required String location,
  }) async {
    final res = await http.post(
      Uri.parse('$base/create_task'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'location': location,
      }),
    );

    if (res.statusCode == 201) {
      return Task.fromJson(json.decode(res.body));
    }

    throw Exception(
      'Create task failed (${res.statusCode}): ${res.body}',
    );
  }




  Future<void> updateTask(int id, bool completed) async {
    await http.put(
      Uri.parse('$base/update_task/$id?completed=$completed'),
    );
  }

  Future<void> deleteTask(int id) async {
    final res = await http.delete(
      Uri.parse('$base/delete_task/$id'),
    );

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Delete failed: ${res.statusCode}');
    }
  }
}
