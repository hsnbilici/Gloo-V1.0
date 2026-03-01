/// Engel paketi broadcast payload'u.
class BroadcastObstacle {
  final String? userId;
  final String type;
  final int count;
  final int? areaSize;

  const BroadcastObstacle({
    required this.userId,
    required this.type,
    required this.count,
    this.areaSize,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'type': type,
        'count': count,
        'area_size': areaSize,
      };

  factory BroadcastObstacle.fromMap(Map<String, dynamic> map) =>
      BroadcastObstacle(
        userId: map['user_id'] as String?,
        type: map['type'] as String? ?? 'ice',
        count: map['count'] as int? ?? 1,
        areaSize: map['area_size'] as int?,
      );
}
