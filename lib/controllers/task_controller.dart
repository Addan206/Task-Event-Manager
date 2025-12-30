import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_api_service.dart';

class TaskController extends ChangeNotifier {
  final _api = TaskApiService();

  List<Task> tasks = [];
  bool isLoading = false;

  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    tasks = await _api.fetchTasks();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title, String desc, String loc) async {
    final t = await _api.createTask(
      title: title,
      description: desc,
      location: loc,
    );
    tasks.add(t);
    notifyListeners();
  }

  Future<void> toggleTask(Task t) async {
    t.isCompleted = !t.isCompleted;
    notifyListeners();
    await _api.updateTask(t.id, t.isCompleted);
  }

  Future<void> deleteTask(Task t) async {
    tasks.remove(t);
    notifyListeners();
    await _api.deleteTask(t.id);
  }

  /// NO EDIT API → LOCAL ONLY
  void editTask(Task t, String title, String desc, String loc) {
    t.title = title;
    t.description = desc;
    t.location = loc;
    notifyListeners();
  }
}
