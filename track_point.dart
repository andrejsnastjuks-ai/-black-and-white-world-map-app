class TrackPoint {
  const TrackPoint({
    required this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.recordedAt,
  });

  final int? id;
  final int tripId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;
  final DateTime recordedAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'trip_id': tripId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'recorded_at': recordedAt.toIso8601String(),
      };

  factory TrackPoint.fromMap(Map<String, Object?> map) => TrackPoint(
        id: map['id'] as int?,
        tripId: map['trip_id'] as int,
        latitude: map['latitude'] as double,
        longitude: map['longitude'] as double,
        accuracy: (map['accuracy'] as num).toDouble(),
        speed: (map['speed'] as num).toDouble(),
        recordedAt: DateTime.parse(map['recorded_at'] as String),
      );
}
