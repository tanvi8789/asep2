class PomodoroSession {
  int? id;
  DateTime startTime;
  DateTime endTime;
  int sessionDuration;
  int breakDuration;
  int? taskId; // ✅ new field to link to a to-do item

  PomodoroSession({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.sessionDuration,
    required this.breakDuration,
    this.taskId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'sessionDuration': sessionDuration,
      'breakDuration': breakDuration,
      'taskId': taskId,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      sessionDuration: map['sessionDuration'],
      breakDuration: map['breakDuration'],
      taskId: map['taskId'],
    );
  }
}
