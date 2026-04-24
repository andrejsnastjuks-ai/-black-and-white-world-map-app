class DiscoveredCell {
  const DiscoveredCell({
    required this.key,
    required this.latIndex,
    required this.lngIndex,
    required this.discoveredAt,
  });

  final String key;
  final int latIndex;
  final int lngIndex;
  final DateTime discoveredAt;

  Map<String, Object?> toMap() => {
        'cell_key': key,
        'lat_index': latIndex,
        'lng_index': lngIndex,
        'discovered_at': discoveredAt.toIso8601String(),
      };

  factory DiscoveredCell.fromMap(Map<String, Object?> map) => DiscoveredCell(
        key: map['cell_key'] as String,
        latIndex: map['lat_index'] as int,
        lngIndex: map['lng_index'] as int,
        discoveredAt: DateTime.parse(map['discovered_at'] as String),
      );
}
