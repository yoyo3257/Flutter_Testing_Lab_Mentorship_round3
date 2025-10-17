
class WeatherData {
  final String city;
  final double temperatureCelsius;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;

  const WeatherData({
    required this.city,
    required this.temperatureCelsius,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON data cannot be null');
    }

    // Validate required fields
    if (!json.containsKey('city') || json['city'] == null) {
      throw ArgumentError('Missing required field: city');
    }
    if (!json.containsKey('temperature') || json['temperature'] == null) {
      throw ArgumentError('Missing required field: temperature');
    }

    return WeatherData(
      city: json['city'] as String,
      temperatureCelsius: (json['temperature'] as num).toDouble(),
      description: json['description'] as String? ?? 'No description',
      humidity: json['humidity'] as int? ?? 0,
      windSpeed: json['windSpeed'] != null
          ? (json['windSpeed'] as num).toDouble()
          : 0.0,
      icon: json['icon'] as String? ?? '🌡️',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperatureCelsius,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'icon': icon,
    };
  }

  List<Object?> get props => [
    city,
    temperatureCelsius,
    description,
    humidity,
    windSpeed,
    icon,
  ];
}