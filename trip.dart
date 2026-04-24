class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.startedAt,
    this.endedAt,
    this.distanceMeters = 0,
  });

  final int? id;
  final String name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceMeters;

  bool get isActive => endedAt == null;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'distance_meters': distanceMeters,
      };

  factory Trip.fromMap(Map<String, Object?> map) => Trip(
        id: map['id'] as int?,
        name: map['name'] as String,
        startedAt: DateTime.parse(map['started_at'] as String),
        endedAt: map['ended_at'] == null ? null : DateTime.parse(map['ended_at'] as String),
        distanceMeters: (map['distance_meters'] as num).toDouble(),
      );
}
