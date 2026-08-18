class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final double latitude;
  final double longitude;
  final String? label;

  String get displayLabel {
    if (label != null && label!.isNotEmpty) {
      return label!;
    }
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
}
