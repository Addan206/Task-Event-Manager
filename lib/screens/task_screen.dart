import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final Box<Task> taskBox;

  static const primary = Color(0xFF6D4C41);   // Brown 700
  static const surface = Color(0xFFD7CCC8);   // Brown 100

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
  }




  void _showAddEditSheet({Task? task}) {
    final titleCtl = TextEditingController(text: task?.title ?? "");
    final noteCtl = TextEditingController(text: task?.note ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  task == null ? "Add Task" : "Edit Task",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: titleCtl,
                  decoration: InputDecoration(
                    labelText: "Task Name",
                    prefixIcon: const Icon(Icons.task),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: noteCtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description (optional)",
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                      onPressed: () async {
                        if (titleCtl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Task name required"),
                            ),
                          );
                          return;
                        }

                        if (task == null) {
                          taskBox.add(
                            Task(
                              title: titleCtl.text.trim(),
                              note: noteCtl.text.trim(),
                            ),
                          );
                        } else {
                          task.title = titleCtl.text.trim();
                          task.note = noteCtl.text.trim();
                          await task.save();
                        }

                        Navigator.pop(ctx);
                      },
                      child: Text(task == null ? "Add Task" : "Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  Future<void> _toggle(Task t) async {
    t.isCompleted = !t.isCompleted;
    await t.save();
  }

  Widget _taskTile(Task t) {
    return Dismissible(
      key: ValueKey(t.key),
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
      onDismissed: (_) => t.delete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: t.isCompleted
              ? null
              : () => _showAddEditSheet(task: t), //  EDIT HERE
          leading: Checkbox(
            value: t.isCompleted,
            activeColor: primary,
            onChanged: (_) => _toggle(t),
          ),
          title: Text(
            t.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration:
              t.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: t.note.isNotEmpty ? Text(t.note) : null,
          trailing: t.isCompleted
              ? const Icon(Icons.lock, size: 18, color: Colors.grey)
              : const Icon(Icons.edit, size: 18, color: primary),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: surface,
        appBar: AppBar(
          backgroundColor: primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Tasks", style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.more_horiz), text: "Pending"),
              Tab(icon: Icon(Icons.check_circle_outline), text: "Completed"),
            ],
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: taskBox.listenable(),
          builder: (_, Box<Task> box, _) {
            final all = box.values.toList();
            final pending = all.where((t) => !t.isCompleted).toList();
            final completed = all.where((t) => t.isCompleted).toList();

            return TabBarView(
              children: [
                pending.isEmpty
                    ? const Center(child: Text("No pending tasks"))
                    : ListView(children: pending.map(_taskTile).toList()),
                completed.isEmpty
                    ? const Center(child: Text("No completed tasks"))
                    : ListView(children: completed.map(_taskTile).toList()),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primary,
          onPressed: () => _showAddEditSheet(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
