class AppSettings {
  const AppSettings({
    this.revealRadiusMeters = 70,
    this.minDistanceMeters = 8,
    this.maxAccuracyMeters = 60,
    this.keepScreenAwake = false,
    this.backgroundTracking = true,
  });

  final double revealRadiusMeters;
  final double minDistanceMeters;
  final double maxAccuracyMeters;
  final bool keepScreenAwake;
  final bool backgroundTracking;

  AppSettings copyWith({
    double? revealRadiusMeters,
    double? minDistanceMeters,
    double? maxAccuracyMeters,
    bool? keepScreenAwake,
    bool? backgroundTracking,
  }) {
    return AppSettings(
      revealRadiusMeters: revealRadiusMeters ?? this.revealRadiusMeters,
      minDistanceMeters: minDistanceMeters ?? this.minDistanceMeters,
      maxAccuracyMeters: maxAccuracyMeters ?? this.maxAccuracyMeters,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      backgroundTracking: backgroundTracking ?? this.backgroundTracking,
    );
  }
}
