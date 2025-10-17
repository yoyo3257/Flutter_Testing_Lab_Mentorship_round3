import '../models/weather_model.dart';

abstract class WeatherState {
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherData weatherData;
  final bool useFahrenheit;

  WeatherLoaded({required this.weatherData, this.useFahrenheit = false});

  WeatherLoaded copyWith({WeatherData? weatherData, bool? useFahrenheit}) {
    return WeatherLoaded(
      weatherData: weatherData ?? this.weatherData,
      useFahrenheit: useFahrenheit ?? this.useFahrenheit,
    );
  }

  @override
  List<Object?> get props => [weatherData, useFahrenheit];
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}


