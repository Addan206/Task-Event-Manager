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

  static const primary = Color(0xFF6D4C41);
  static const surface = Color(0xFFD7CCC8);

  final Set<int> _selectedTasks = {};
  final _formKey = GlobalKey<FormState>();

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
        return Form(
          key: _formKey,
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

                /// TASK TITLE (REQUIRED)
                TextFormField(
                  controller: titleCtl,
                  decoration: InputDecoration(
                    labelText: "Task Name",
                    prefixIcon: const Icon(Icons.task),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Task name is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                /// DESCRIPTION (OPTIONAL)
                TextFormField(
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
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        if (task == null) {
                          taskBox.add(Task(
                            title: titleCtl.text.trim(),
                            note: noteCtl.text.trim(),
                          ));
                        } else {
                          task.title = titleCtl.text.trim();
                          task.note = noteCtl.text.trim();
                          await task.save();
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text("Save"),
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

  Future<void> _toggleStatus(Task t) async {
    t.isCompleted = !t.isCompleted;
    await t.save();
  }

  Widget _taskTile(Task t) {
    final isSelected = _selectedTasks.contains(t.key);

    return Dismissible(
      key: ValueKey(t.key),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.brown.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        _selectedTasks.remove(t.key);
        await t.delete();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isSelected ? surface.withOpacity(0.5) : null,
        child: ListTile(
          onTap: t.isCompleted || isSelected
              ? null
              : () => _showAddEditSheet(task: t),
          leading: Checkbox(
            value: isSelected,
            activeColor: primary,
            onChanged: (val) {
              setState(() {
                val == true
                    ? _selectedTasks.add(t.key as int)
                    : _selectedTasks.remove(t.key);
              });
            },
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  t.isCompleted ? Icons.undo : Icons.check_circle,
                  color: primary,
                  size: 20,
                ),
                onPressed: () => _toggleStatus(t),
              ),
              Icon(
                t.isCompleted ? Icons.lock : Icons.edit,
                size: 18,
                color: t.isCompleted ? Colors.grey : primary,
              ),
            ],
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
        backgroundColor: surface,
        appBar: AppBar(
          backgroundColor: primary,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Tasks", style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                    (_) => false,
              ),
            ),
            if (_selectedTasks.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  for (final key in _selectedTasks) {
                    await taskBox.delete(key);
                  }
                  setState(() => _selectedTasks.clear());
                },
              ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.more_horiz, color: Colors.white),
                text: "Pending",
              ),
              Tab(
                icon: Icon(Icons.check_circle_outline, color: Colors.white),
                text: "Completed",
              ),
            ],
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: taskBox.listenable(),
          builder: (_, Box<Task> box, __) {
            final tasks = box.values.toList();
            final pending = tasks.where((t) => !t.isCompleted).toList();
            final completed = tasks.where((t) => t.isCompleted).toList();

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
