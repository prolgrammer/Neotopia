class DailyTaskProgress {
  final String taskId;
  final String date;
  final bool isCompleted;

  DailyTaskProgress({
    required this.taskId,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'date': date,
      'isCompleted': isCompleted,
    };
  }

  factory DailyTaskProgress.fromMap(Map<String, dynamic> map) {
    return DailyTaskProgress(
      taskId: map['taskId'] as String,
      date: map['date'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}