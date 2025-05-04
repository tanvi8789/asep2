import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/todo.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  List<ToDo> todos = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  int selectedPomodoroCount = 4; // default

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    final db = DBHelper();
    final data = await db.getTodos();
    setState(() {
      todos = data;
    });
  }

  Future<void> addTodo() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();
    if (title.isEmpty) return;

    final todo = ToDo(
      title: title,
      description: desc,
      createdAt: DateTime.now(),
      requiredPomodoros: selectedPomodoroCount,
      completedPomodoros: 0,
    );

    await DBHelper().insertTodo(todo);
    titleController.clear();
    descController.clear();
    setState(() => selectedPomodoroCount = 4);
    loadTodos();
  }

  Future<void> toggleDone(ToDo todo) async {
    final updated = ToDo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      createdAt: todo.createdAt,
      isDone: !todo.isDone,
      requiredPomodoros: todo.requiredPomodoros,
      completedPomodoros: todo.completedPomodoros,
    );
    await DBHelper().updateTodo(updated);
    loadTodos();
  }

  Future<void> confirmDelete(ToDo todo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${todo.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await DBHelper().deleteTodo(todo.id!);
      loadTodos();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage To-Do List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Row(
              children: [
                const Text("Pomodoros:"),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: selectedPomodoroCount,
                  onChanged: (value) => setState(() => selectedPomodoroCount = value!),
                  items: List.generate(8, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                      .toList(),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: addTodo,
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${todo.description}\nPomodoros: ${todo.completedPomodoros} / ${todo.requiredPomodoros}',
                    ),
                    isThreeLine: true,
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) => toggleDone(todo),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmDelete(todo),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
