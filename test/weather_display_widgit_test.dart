import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_testing_lab/models/weather_model.dart';
import 'package:flutter_testing_lab/services/weather_service.dart';
import 'package:flutter_testing_lab/weather_cubit/weather_cubit.dart';
import 'package:flutter_testing_lab/weather_cubit/weather_state.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';
import 'package:mocktail/mocktail.dart';

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  group('WeatherDisplay Widget Tests', () {
    late WeatherService mockWeatherService;

    setUp(() {
      mockWeatherService = MockWeatherService();
    });

    Widget createTestWidget(WeatherCubit cubit) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const WeatherView()),
        ),
      );
    }

    testWidgets('displays loading indicator when state is WeatherLoading', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      cubit.emit(WeatherLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Card), findsNothing);

      cubit.close();
    });

    testWidgets('displays error message when state is WeatherError', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      cubit.emit(WeatherError('Test error message'));
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      cubit.close();
    });

    testWidgets('displays weather data when state is WeatherLoaded', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      const weatherData = WeatherData(
        city: 'London',
        temperatureCelsius: 15.0,
        description: 'Rainy',
        humidity: 85,
        windSpeed: 8.5,
        icon: '🌧️',
      );

      await tester.pumpWidget(createTestWidget(cubit));

      cubit.emit(WeatherLoaded(weatherData: weatherData));
      await tester.pump();

      expect(find.text('London'), findsOneWidget);
      expect(find.text('Rainy'), findsOneWidget);
      expect(find.text('15.0°C'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('8.5 km/h'), findsOneWidget);
      expect(find.text('🌧️'), findsOneWidget);

      cubit.close();
    });

    testWidgets('displays city dropdown with correct cities', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('New York'), findsOneWidget);

      cubit.close();
    });

    testWidgets('displays temperature unit toggle', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      expect(find.text('Temperature Unit:'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Celsius'), findsOneWidget);

      cubit.close();
    });

    testWidgets('displays refresh button', (WidgetTester tester) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      expect(find.text('Refresh'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);

      cubit.close();
    });

    testWidgets('refresh button is disabled during loading', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      cubit.emit(WeatherLoading());
      await tester.pump();

      final refreshButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Refresh'),
      );
      expect(refreshButton.onPressed, isNull);

      cubit.close();
    });

    testWidgets('refresh button is enabled when not loading', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      const weatherData = WeatherData(
        city: 'Tokyo',
        temperatureCelsius: 25.0,
        description: 'Cloudy',
        humidity: 70,
        windSpeed: 5.2,
        icon: '☁️',
      );

      await tester.pumpWidget(createTestWidget(cubit));

      cubit.emit(WeatherLoaded(weatherData: weatherData));
      await tester.pump();

      final refreshButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Refresh'),
      );
      expect(refreshButton.onPressed, isNotNull);

      cubit.close();
    });

    testWidgets('can select different cities from dropdown', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('London').hitTestable(), findsOneWidget);
      expect(find.text('Tokyo').hitTestable(), findsOneWidget);
      expect(find.text('Invalid City').hitTestable(), findsOneWidget);

      cubit.close();
    });

    testWidgets('retry button reloads weather data', (
      WidgetTester tester,
    ) async {
      when(
        () => mockWeatherService.fetchWeatherData('New York'),
      ).thenAnswer((_) async => {'city': 'New York', 'temperature': 22.5});

      final cubit = WeatherCubit(weatherService: mockWeatherService);

      await tester.pumpWidget(createTestWidget(cubit));

      cubit.emit(WeatherError('Test error'));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockWeatherService.fetchWeatherData('New York')).called(1);

      cubit.close();
    });

    testWidgets('handles default values for missing optional fields', (
      WidgetTester tester,
    ) async {
      final cubit = WeatherCubit(weatherService: mockWeatherService);

      const weatherData = WeatherData(
        city: 'TestCity',
        temperatureCelsius: 20.0,
        description: 'No description',
        humidity: 0,
        windSpeed: 0.0,
        icon: '🌡️',
      );

      await tester.pumpWidget(createTestWidget(cubit));

      cubit.emit(WeatherLoaded(weatherData: weatherData));
      await tester.pump();

      expect(find.text('TestCity'), findsOneWidget);
      expect(find.text('No description'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('0.0 km/h'), findsOneWidget);

      cubit.close();
    });
  });
}
