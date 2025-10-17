import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/weather_service.dart';
import '../weather_cubit/weather_cubit.dart';
import '../weather_cubit/weather_state.dart';

class WeatherDisplay extends StatelessWidget {
  const WeatherDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WeatherCubit(weatherService: MockWeatherService())
            ..loadWeather('New York'),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatelessWidget {
  const WeatherView({super.key});

  final List<String> _cities = const [
    'New York',
    'London',
    'Tokyo',
    'Invalid City',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCitySelection(context),
          const SizedBox(height: 16),
          _buildTemperatureUnitToggle(context),
          const SizedBox(height: 16),
          _buildWeatherContent(context),
        ],
      ),
    );
  }

  Widget _buildCitySelection(BuildContext context) {
    final cubit = context.read<WeatherCubit>();

    return Row(
      children: [
        const Text('City: '),
        const SizedBox(width: 8),
        Expanded(
          child: BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) {
              return DropdownButton<String>(
                value: cubit.currentCity,
                isExpanded: true,
                items: _cities.map((city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    cubit.loadWeather(value);
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state is WeatherLoading
                  ? null
                  : () {
                      cubit.refreshWeather();
                    },
              child: const Text('Refresh'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTemperatureUnitToggle(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final cubit = context.read<WeatherCubit>();

        return Row(
          children: [
            const Text('Temperature Unit:'),
            const SizedBox(width: 10),
            Switch(
              value: cubit.useFahrenheit,
              onChanged: (value) {
                cubit.toggleTemperatureUnit();
              },
            ),
            Text(cubit.useFahrenheit ? 'Fahrenheit' : 'Celsius'),
          ],
        );
      },
    );
  }

  Widget _buildWeatherContent(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WeatherError) {
          return _buildErrorCard(context, state.message);
        } else if (state is WeatherLoaded) {
          return _buildWeatherCard(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorCard(BuildContext context, String errorMessage) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<WeatherCubit>().refreshWeather();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherLoaded state) {
    final cubit = context.read<WeatherCubit>();
    final weatherData = state.weatherData;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(weatherData.icon, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherData.city,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weatherData.description,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${cubit.getDisplayTemperature(weatherData.temperatureCelsius).toStringAsFixed(1)}${cubit.getTemperatureUnit()}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherDetail(
                  'Humidity',
                  '${weatherData.humidity}%',
                  Icons.water_drop,
                ),
                _buildWeatherDetail(
                  'Wind Speed',
                  '${weatherData.windSpeed} km/h',
                  Icons.air,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
