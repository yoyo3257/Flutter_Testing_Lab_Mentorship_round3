import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_testing_lab/weather_cubit/weather_state.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherService weatherService;
  String _currentCity = 'New York';
  bool _useFahrenheit = false;

  WeatherCubit({required this.weatherService}) : super(WeatherInitial());

  String get currentCity => _currentCity;
  bool get useFahrenheit => _useFahrenheit;

  Future<void> loadWeather(String city) async {
    _currentCity = city;
    emit(WeatherLoading());

    try {
      final data = await weatherService.fetchWeatherData(city);

      if (data == null) {
        emit(WeatherError('Unable to fetch weather data for $city'));
        return;
      }

      final weatherData = WeatherData.fromJson(data);
      emit(
        WeatherLoaded(weatherData: weatherData, useFahrenheit: _useFahrenheit),
      );
    } catch (e) {
      emit(WeatherError('Error loading weather: ${e.toString()}'));
    }
  }

  Future<void> refreshWeather() async {
    await loadWeather(_currentCity);
  }

  void toggleTemperatureUnit() {
    _useFahrenheit = !_useFahrenheit;

    final currentState = state;
    if (currentState is WeatherLoaded) {
      emit(currentState.copyWith(useFahrenheit: _useFahrenheit));
    }
  }

  double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  double getDisplayTemperature(double celsius) {
    return _useFahrenheit ? celsiusToFahrenheit(celsius) : celsius;
  }

  String getTemperatureUnit() {
    return _useFahrenheit ? '°F' : '°C';
  }
}
