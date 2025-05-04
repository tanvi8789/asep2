import 'dart:async';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/pomodoro_session.dart';
import '../models/focus_level.dart';

class PomodoroManager {
  Timer? _sessionTimer;
  Timer? _focusTrackingTimer;
  List<FocusLevel> _focusLogs = [];

  void startPomodoro(int focusMinutes, int breakMinutes, {int? taskId}) {
    final startTime = DateTime.now();
    final int focusSeconds = focusMinutes * 60;
    int elapsedMinutes = 0;

    print("Pomodoro started for $focusMinutes mins!");

    // Simulate focus tracking every 2 minutes
    _focusTrackingTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      elapsedMinutes += 2;

      // Fake focus level, you can replace this with actual detection
      String level = (elapsedMinutes % 4 == 0) ? 'distracted' : 'mildly alert';

      _focusLogs.add(FocusLevel(
        sessionId: -1, // We'll update this later
        level: level,
        startMinute: elapsedMinutes - 2,
        endMinute: elapsedMinutes,
      ));

      print("Logged focus level: $level (${elapsedMinutes - 2}–$elapsedMinutes mins)");
    });

    // Focus session timer
    _sessionTimer = Timer(Duration(seconds: focusSeconds), () async {
      _focusTrackingTimer?.cancel();
      final endTime = DateTime.now();

      // Save session to DB
      final session = PomodoroSession(
      startTime: startTime,
      endTime: endTime,
      sessionDuration: focusMinutes,
      breakDuration: breakMinutes,
      taskId: taskId, // ✅ pass taskId here
);
      final sessionId = await DBHelper().insertSession(session);
      print("Session saved with ID: $sessionId");

      // Update sessionId in focus logs and save them
      for (FocusLevel log in _focusLogs) {
        log.sessionId = sessionId;
        await DBHelper().insertFocusLevel(log);
      }

      _focusLogs.clear();

      // Start break
      _startBreak(breakMinutes);
    });
  }

  void _startBreak(int breakMinutes) {
    print("Break time! Relax for $breakMinutes minutes.");
    Timer(Duration(minutes: breakMinutes), () {
      print("Break over. Ready for the next session!");
    });
  }

  void stopPomodoro() {
    _sessionTimer?.cancel();
    _focusTrackingTimer?.cancel();
    _focusLogs.clear();
    print("Pomodoro session manually stopped.");
  }
}
