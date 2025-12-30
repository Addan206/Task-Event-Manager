import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../controllers/task_controller.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const primary = Color(0xFF6D4C41);
  static const surface = Color(0xFFD7CCC8);

  final Set<int> _selectedTasks = {};
  final _formKey = GlobalKey<FormState>();

  // ---------------- ADD TASK SHEET ----------------
  void _showAddSheet() {
    final titleCtl = TextEditingController();
    final descCtl = TextEditingController();
    final locCtl = TextEditingController();

    final controller = context.read<TaskController>();

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
                const Text(
                  "Add Task",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: titleCtl,
                  decoration: const InputDecoration(
                    labelText: "Task Name",
                    prefixIcon: Icon(Icons.task),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: descCtl,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: locCtl,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        await controller.addTask(
                          titleCtl.text.trim(),
                          descCtl.text.trim(),
                          locCtl.text.trim(),
                        );

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

  // ---------------- TASK TILE ----------------
  Widget _taskTile(Task t) {
    final controller = context.read<TaskController>();
    final isSelected = _selectedTasks.contains(t.id);

    return Dismissible(
      key: ValueKey(t.id),
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
      onDismissed: (_) => controller.deleteTask(t),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isSelected ? surface.withOpacity(0.5) : primary,
        child: ListTile(
          leading: Checkbox(
            value: isSelected,
            activeColor: primary,
            checkColor: Colors.white,
            onChanged: (val) {
              setState(() {
                val == true
                    ? _selectedTasks.add(t.id)
                    : _selectedTasks.remove(t.id);
              });
            },
          ),
          title: Text(
            t.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration:
              t.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: t.description.isNotEmpty
              ? Text(
            t.description,
            style: const TextStyle(color: Colors.white70),
          )
              : null,
          trailing: IconButton(
            icon: Icon(
              t.isCompleted ? Icons.undo : Icons.check_circle,
              color: Colors.white,
            ),
            onPressed: () => controller.toggleTask(t),
          ),
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, _) {
        final pending =
        controller.tasks.where((t) => !t.isCompleted).toList();
        final completed =
        controller.tasks.where((t) => t.isCompleted).toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: surface,
            appBar: AppBar(
              backgroundColor: primary,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Tasks",
                style: TextStyle(color: Colors.white),
              ),
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
                      for (final id in _selectedTasks) {
                        final task = controller.tasks
                            .firstWhere((t) => t.id == id);
                        await controller.deleteTask(task);
                      }
                      setState(() => _selectedTasks.clear());
                    },
                  ),
              ],
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.more_horiz), text: "Pending"),
                  Tab(
                    icon: Icon(Icons.check_circle_outline),
                    text: "Completed",
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                pending.isEmpty
                    ? const Center(child: Text("No pending tasks"))
                    : ListView(children: pending.map(_taskTile).toList()),
                completed.isEmpty
                    ? const Center(child: Text("No completed tasks"))
                    : ListView(children: completed.map(_taskTile).toList()),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primary,
              onPressed: _showAddSheet,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
