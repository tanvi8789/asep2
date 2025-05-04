import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/todo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ToDo> todos = [];

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    final data = await DBHelper().getTodos();
    setState(() {
      // Sort: incomplete tasks at top
      todos = List.from(data)
        ..sort((a, b) => a.isDone == b.isDone ? 0 : (a.isDone ? 1 : -1));
    });
  }

  Widget buildTaskCard(ToDo todo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(todo.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: todo.isDone ? Colors.green : Colors.grey),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('Pomodoros: ${todo.completedPomodoros}/${todo.requiredPomodoros}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FocusBot Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Tasks', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Expanded(
              child: todos.isEmpty
                  ? const Center(child: Text('No tasks yet'))
                  : ListView(
                      children: todos.map((todo) => buildTaskCard(todo)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}