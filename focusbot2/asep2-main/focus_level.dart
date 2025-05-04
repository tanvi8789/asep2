class FocusLevel {
  int? id;
  int sessionId; // Foreign key from PomodoroSession
  String level;  // e.g., "Mildly Alert"
  int startMinute;
  int endMinute;

  FocusLevel({
    this.id,
    required this.sessionId,
    required this.level,
    required this.startMinute,
    required this.endMinute,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'level': level,
      'startMinute': startMinute,
      'endMinute': endMinute,
    };
  }

  factory FocusLevel.fromMap(Map<String, dynamic> map) {
    return FocusLevel(
      id: map['id'],
      sessionId: map['sessionId'],
      level: map['level'],
      startMinute: map['startMinute'],
      endMinute: map['endMinute'],
    );
  }
}
