/// Supabase `daily_tasks` tablosundan donen gunluk bulmaca kaydi.
class DailyPuzzle {
  final String? id;
  final String date;
  final String? userId;
  final bool completed;
  final int? score;
  final DateTime? completedAt;

  const DailyPuzzle({
    this.id,
    required this.date,
    this.userId,
    this.completed = false,
    this.score,
    this.completedAt,
  });

  factory DailyPuzzle.fromMap(Map<String, dynamic> map) {
    return DailyPuzzle(
      id: map['id'] as String?,
      date: map['date'] as String? ?? '',
      userId: map['user_id'] as String?,
      completed: map['completed'] as bool? ?? false,
      score: map['score'] as int?,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
    );
  }
}
