class ToDo {
  int? id;
  String title;
  String description;
  bool isDone;
  DateTime createdAt;
  int requiredPomodoros;
  int completedPomodoros;

  ToDo({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    required this.createdAt,
    this.requiredPomodoros = 1,
    this.completedPomodoros = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'requiredPomodoros': requiredPomodoros,
      'completedPomodoros': completedPomodoros,
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      requiredPomodoros: map['requiredPomodoros'] ?? 1,
      completedPomodoros: map['completedPomodoros'] ?? 0,
    );
  }
}
