import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_testing_lab/models/weather_model.dart';
import 'package:flutter_testing_lab/services/weather_service.dart';
import 'package:flutter_testing_lab/weather_cubit/weather_cubit.dart';
import 'package:flutter_testing_lab/weather_cubit/weather_state.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockWeatherService extends Mock implements WeatherService {}

void main() {
  group('WeatherCubit', () {
    late WeatherService mockWeatherService;
    late WeatherCubit weatherCubit;

    setUp(() {
      mockWeatherService = MockWeatherService();
      weatherCubit = WeatherCubit(weatherService: mockWeatherService);
    });

    tearDown(() {
      weatherCubit.close();
    });

    test('initial state is WeatherInitial', () {
      expect(weatherCubit.state, isA<WeatherInitial>());
      expect(weatherCubit.currentCity, 'New York');
      expect(weatherCubit.useFahrenheit, false);
    });

    group('loadWeather', () {
      final mockWeatherData = {
        'city': 'London',
        'temperature': 15.0,
        'description': 'Rainy',
        'humidity': 85,
        'windSpeed': 8.5,
        'icon': '🌧️',
      };

      blocTest<WeatherCubit, WeatherState>(
        'emits [WeatherLoading, WeatherLoaded] when weather loads successfully',
        build: () {
          when(
            () => mockWeatherService.fetchWeatherData('London'),
          ).thenAnswer((_) async => mockWeatherData);
          return weatherCubit;
        },
        act: (cubit) => cubit.loadWeather('London'),
        expect: () => [
          isA<WeatherLoading>(),
          isA<WeatherLoaded>()
              .having((state) => state.weatherData.city, 'city', 'London')
              .having(
                (state) => state.weatherData.temperatureCelsius,
                'temperature',
                15.0,
              )
              .having((state) => state.useFahrenheit, 'useFahrenheit', false),
        ],
        verify: (_) {
          verify(() => mockWeatherService.fetchWeatherData('London')).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [WeatherLoading, WeatherError] when service returns null',
        build: () {
          when(
            () => mockWeatherService.fetchWeatherData('Invalid City'),
          ).thenAnswer((_) async => null);
          return weatherCubit;
        },
        act: (cubit) => cubit.loadWeather('Invalid City'),
        expect: () => [
          isA<WeatherLoading>(),
          isA<WeatherError>().having(
            (state) => state.message,
            'message',
            'Unable to fetch weather data for Invalid City',
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [WeatherLoading, WeatherError] when parsing fails',
        build: () {
          when(
            () => mockWeatherService.fetchWeatherData('TestCity'),
          ).thenAnswer((_) async => {'invalid': 'data'});
          return weatherCubit;
        },
        act: (cubit) => cubit.loadWeather('TestCity'),
        expect: () => [
          isA<WeatherLoading>(),
          isA<WeatherError>().having(
            (state) => state.message,
            'message',
            contains('Error loading weather'),
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'updates current city when loading weather',
        build: () {
          when(
            () => mockWeatherService.fetchWeatherData('Tokyo'),
          ).thenAnswer((_) async => {'city': 'Tokyo', 'temperature': 25.0});
          return weatherCubit;
        },
        act: (cubit) => cubit.loadWeather('Tokyo'),
        verify: (cubit) {
          expect(cubit.currentCity, 'Tokyo');
        },
      );
    });

    group('refreshWeather', () {
      blocTest<WeatherCubit, WeatherState>(
        'reloads weather for current city',
        build: () {
          when(
            () => mockWeatherService.fetchWeatherData('New York'),
          ).thenAnswer(
            (_) async => {
              'city': 'New York',
              'temperature': 22.5,
              'description': 'Sunny',
              'humidity': 65,
              'windSpeed': 12.3,
              'icon': '☀️',
            },
          );
          return weatherCubit;
        },
        act: (cubit) => cubit.refreshWeather(),
        expect: () => [isA<WeatherLoading>(), isA<WeatherLoaded>()],
        verify: (_) {
          verify(
            () => mockWeatherService.fetchWeatherData('New York'),
          ).called(1);
        },
      );
    });

    group('toggleTemperatureUnit', () {
      blocTest<WeatherCubit, WeatherState>(
        'toggles temperature unit when in WeatherLoaded state',
        build: () {
          when(() => mockWeatherService.fetchWeatherData('London')).thenAnswer(
            (_) async => {
              'city': 'London',
              'temperature': 15.0,
              'description': 'Rainy',
              'humidity': 85,
              'windSpeed': 8.5,
              'icon': '🌧️',
            },
          );
          return weatherCubit;
        },
        seed: () => WeatherLoaded(
          weatherData: const WeatherData(
            city: 'London',
            temperatureCelsius: 15.0,
            description: 'Rainy',
            humidity: 85,
            windSpeed: 8.5,
            icon: '🌧️',
          ),
          useFahrenheit: false,
        ),
        act: (cubit) => cubit.toggleTemperatureUnit(),
        expect: () => [
          isA<WeatherLoaded>().having(
            (state) => state.useFahrenheit,
            'useFahrenheit',
            true,
          ),
        ],
        verify: (cubit) {
          expect(cubit.useFahrenheit, true);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'does not emit when not in WeatherLoaded state',
        build: () => weatherCubit,
        seed: () => WeatherLoading(),
        act: (cubit) => cubit.toggleTemperatureUnit(),
        expect: () => [],
        verify: (cubit) {
          expect(cubit.useFahrenheit, true);
        },
      );
    });

    group('Temperature conversion methods', () {

      test('celsiusToFahrenheit converts correctly', () {
        expect(weatherCubit.celsiusToFahrenheit(0), 32);
        expect(weatherCubit.celsiusToFahrenheit(100), 212);
        expect(weatherCubit.celsiusToFahrenheit(37), closeTo(98.6, 0.1));
        expect(weatherCubit.celsiusToFahrenheit(-40), -40);
        expect(weatherCubit.celsiusToFahrenheit(25), 77);
      });

      test('fahrenheitToCelsius converts correctly', () {
        expect(weatherCubit.fahrenheitToCelsius(32), 0);
        expect(weatherCubit.fahrenheitToCelsius(212), 100);
        expect(weatherCubit.fahrenheitToCelsius(98.6), closeTo(37, 0.1));
        expect(weatherCubit.fahrenheitToCelsius(-40), -40);
        expect(weatherCubit.fahrenheitToCelsius(77), 25);
      });

      test('getDisplayTemperature returns correct value based on unit', () {
        expect(weatherCubit.getDisplayTemperature(25), 25);

        weatherCubit.toggleTemperatureUnit();
        expect(weatherCubit.getDisplayTemperature(25), 77);
      });

      test('getTemperatureUnit returns correct unit', () {
        expect(weatherCubit.getTemperatureUnit(), '°C');

        weatherCubit.toggleTemperatureUnit();
        expect(weatherCubit.getTemperatureUnit(), '°F');
      });
    });

    group('Edge cases', () {

      blocTest<WeatherCubit, WeatherState>(
        'handles service exception gracefully',
        build: () {
          when(
            () => mockWeatherService.fetchWeatherData(any()),
          ).thenThrow(Exception('Network error'));
          return weatherCubit;
        },
        act: (cubit) => cubit.loadWeather('Paris'),
        expect: () => [
          isA<WeatherLoading>(),
          isA<WeatherError>().having(
            (state) => state.message,
            'message',
            contains('Network error'),
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'handles malformed JSON with missing optional fields',
        build: () {
          when(
            () => mockWeatherService.fetchWeatherData('Paris'),
          ).thenAnswer((_) async => {'city': 'Paris', 'temperature': 20.0});
          return weatherCubit;
        },
        act: (cubit) => cubit.loadWeather('Paris'),
        expect: () => [
          isA<WeatherLoading>(),
          isA<WeatherLoaded>()
              .having((state) => state.weatherData.city, 'city', 'Paris')
              .having(
                (state) => state.weatherData.description,
                'description',
                'No description',
              )
              .having((state) => state.weatherData.humidity, 'humidity', 0)
              .having((state) => state.weatherData.windSpeed, 'windSpeed', 0.0),
        ],
      );
    });
  });

  group('WeatherData', () {

    test('creates instance from complete JSON', () {
      final json = {
        'city': 'London',
        'temperature': 15.0,
        'description': 'Rainy',
        'humidity': 85,
        'windSpeed': 8.5,
        'icon': '🌧️',
      };

      final weatherData = WeatherData.fromJson(json);

      expect(weatherData.city, 'London');
      expect(weatherData.temperatureCelsius, 15.0);
      expect(weatherData.description, 'Rainy');
      expect(weatherData.humidity, 85);
      expect(weatherData.windSpeed, 8.5);
      expect(weatherData.icon, '🌧️');
    });

    test('creates instance with default values for optional fields', () {
      final json = {'city': 'Paris', 'temperature': 20};

      final weatherData = WeatherData.fromJson(json);

      expect(weatherData.city, 'Paris');
      expect(weatherData.temperatureCelsius, 20.0);
      expect(weatherData.description, 'No description');
      expect(weatherData.humidity, 0);
      expect(weatherData.windSpeed, 0.0);
      expect(weatherData.icon, '🌡️');
    });

    test('throws error when city is missing', () {
      final json = {'temperature': 20.0};

      expect(() => WeatherData.fromJson(json), throwsA(isA<ArgumentError>()));
    });

    test('throws error when temperature is missing', () {
      final json = {'city': 'Madrid'};

      expect(() => WeatherData.fromJson(json), throwsA(isA<ArgumentError>()));
    });

    test('throws error when JSON is null', () {
      expect(() => WeatherData.fromJson(null), throwsA(isA<ArgumentError>()));
    });

    test('toJson converts to map correctly', () {
      const weatherData = WeatherData(
        city: 'Tokyo',
        temperatureCelsius: 25.0,
        description: 'Cloudy',
        humidity: 70,
        windSpeed: 5.2,
        icon: '☁️',
      );

      final json = weatherData.toJson();

      expect(json['city'], 'Tokyo');
      expect(json['temperature'], 25.0);
      expect(json['description'], 'Cloudy');
      expect(json['humidity'], 70);
      expect(json['windSpeed'], 5.2);
      expect(json['icon'], '☁️');
    });

    test('equality works correctly', () {
      const weatherData1 = WeatherData(
        city: 'London',
        temperatureCelsius: 15.0,
        description: 'Rainy',
        humidity: 85,
        windSpeed: 8.5,
        icon: '🌧️',
      );

      const weatherData2 = WeatherData(
        city: 'London',
        temperatureCelsius: 15.0,
        description: 'Rainy',
        humidity: 85,
        windSpeed: 8.5,
        icon: '🌧️',
      );

      const weatherData3 = WeatherData(
        city: 'Paris',
        temperatureCelsius: 20.0,
        description: 'Sunny',
        humidity: 65,
        windSpeed: 10.0,
        icon: '☀️',
      );

      expect(weatherData1, equals(weatherData2));
      expect(weatherData1, isNot(equals(weatherData3)));
    });
  });
}
