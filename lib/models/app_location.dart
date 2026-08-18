class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
    this.label,
    this.isManual = false,
  });

  final double latitude;
  final double longitude;
  final String? city;
  final String? country;
  final String? label;
  final bool isManual;

  String get displayCity {
    if (city != null && city!.isNotEmpty) return city!;
    if (label != null && label!.isNotEmpty) return label!;
    return 'Current Location';
  }

  String get displayCountry {
    if (country != null && country!.isNotEmpty) return country!;
    return isManual ? '' : 'Current Location';
  }

  String get displayLabel {
    if (city != null && country != null && city!.isNotEmpty && country!.isNotEmpty) {
      return '$city, $country';
    }
    if (label != null && label!.isNotEmpty) {
      return label!;
    }
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'country': country,
        'label': label,
        'isManual': isManual,
      };

  factory AppLocation.fromJson(Map<String, dynamic> json) => AppLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        city: json['city'] as String?,
        country: json['country'] as String?,
        label: json['label'] as String?,
        isManual: json['isManual'] as bool? ?? false,
      );
}
