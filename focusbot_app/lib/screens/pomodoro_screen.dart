import 'dart:async';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/todo.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _remainingSeconds = 1500; // default 25 mins
  Timer? _timer;
  bool _isRunning = false;
  bool _isFocusSession = true;
  int _sessionCount = 0;

  List<ToDo> todos = [];
  ToDo? selectedTask;

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    final data = await DBHelper().getTodos();
    setState(() {
      todos = data.where((t) => !t.isDone).toList();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _handleSessionComplete();
      }
    });
    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isFocusSession ? 1500 : (_sessionCount % 4 == 0 ? 900 : 300); // long or short break
    });
  }

  void _handleSessionComplete() async {
    if (_isFocusSession && selectedTask != null) {
      selectedTask!.completedPomodoros++;
      if (selectedTask!.completedPomodoros >= selectedTask!.requiredPomodoros) {
        selectedTask!.isDone = true;
      }
      await DBHelper().updateTodo(selectedTask!);
    }

    setState(() {
      _sessionCount += _isFocusSession ? 1 : 0;
      _isFocusSession = !_isFocusSession;
      _remainingSeconds = _isFocusSession
          ? 1500
          : (_sessionCount % 4 == 0 ? 900 : 300); // break logic
      _isRunning = false;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            DropdownButton<ToDo>(
              hint: const Text('Select a Task'),
              value: selectedTask,
              onChanged: (val) => setState(() => selectedTask = val),
              items: todos.map((task) {
                return DropdownMenuItem(
                  value: task,
                  child: Text(task.title),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Text(
              _isFocusSession ? 'Focus Session' : (_sessionCount % 4 == 0 ? 'Long Break' : 'Short Break'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              formatTime(_remainingSeconds),
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  child: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (selectedTask != null)
              Text('Pomodoros: ${selectedTask!.completedPomodoros}/${selectedTask!.requiredPomodoros}'),
          ],
        ),
      ),
    );
  }
}
