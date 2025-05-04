import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';
import '../models/pomodoro_session.dart';
import '../models/focus_level.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'focusbot.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isDone INTEGER,
            createdAt TEXT,
            requiredPomodoros INTEGER,
            completedPomodoros INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE pomodoro_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskId INTEGER,
            sessionDuration INTEGER,
            startTime TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE focus_levels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId INTEGER,
            focusLevel TEXT,
            startMinute INTEGER,
            endMinute INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertTodo(ToDo todo) async {
    final dbClient = await db;
    return await dbClient.insert('todos', todo.toMap());
  }

  Future<List<ToDo>> getTodos() async {
    final dbClient = await db;
    final result = await dbClient.query('todos');
    return result.map((e) => ToDo.fromMap(e)).toList();
  }

  Future<int> updateTodo(ToDo todo) async {
    final dbClient = await db;
    return await dbClient.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertSession(PomodoroSession session) async {
    final dbClient = await db;
    return await dbClient.insert('pomodoro_sessions', session.toMap());
  }

  Future<List<PomodoroSession>> getSessions() async {
    final dbClient = await db;
    final result = await dbClient.query('pomodoro_sessions');
    return result.map((e) => PomodoroSession.fromMap(e)).toList();
  }

  Future<int> insertFocusLevel(FocusLevel level) async {
    final dbClient = await db;
    return await dbClient.insert('focus_levels', level.toMap());
  }

  Future<List<FocusLevel>> getFocusLevelsForSession(int sessionId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'focus_levels',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
    return result.map((e) => FocusLevel.fromMap(e)).toList();
  }
}
