import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../providers/weather_provider.dart';

final Logger _pageLogger = Logger();

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    
  }

  
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      case 'snow':
        return 'assets/snowy.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          // Search Icon Button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showCitySearchDialog(context);
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              weatherProvider.fetchWeatherForCurrentLocation();
            },
          ),
        ],
      ),
      body: Center(
        child: _buildBodyContent(weatherProvider),
      ),
    );
  }

  
  Widget _buildBodyContent(WeatherProvider weatherProvider) {
    if (weatherProvider.isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blueAccent),
          SizedBox(height: 20),
          Text('Loading weather...',
              style: TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      );
    } else if (weatherProvider.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              'Error: ${weatherProvider.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                weatherProvider.fetchWeatherForCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry Current Location'),
            ),
          ],
        ),
      );
    } else if (weatherProvider.currentWeather == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_city, size: 60, color: Colors.white70),
            SizedBox(height: 20),
            Text(
              'Search for a city or use current location to get weather updates.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      );
    } else {
      // Display weather data
      final weather = weatherProvider.currentWeather!;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // City name
          Text(
            weather.cityName,
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),

          // Animation
          Lottie.asset(getWeatherAnimation(weather.mainCondition)),
          const SizedBox(height: 10),

          // Temperature
          Text(
            '${weather.temperature.round()}°C',
            style: const TextStyle(
                fontSize: 60, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 5),

          // Weather condition description
          Text(
            weather.mainCondition.toUpperCase(),
            style: const TextStyle(
                fontSize: 22, fontStyle: FontStyle.italic, color: Colors.white70),
          ),
          const SizedBox(height: 30),

          // Humidity and Wind Speed 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetail(Icons.water_drop, '${weather.humidity}%', 'Humidity'),
              _buildWeatherDetail(Icons.air, '${weather.windSpeed.toStringAsFixed(1)} m/s', 'Wind Speed'),
            ],
          ),
        ],
      );
    }
  }

  
  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 35, color: Colors.white),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 18, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  // Dialog for city search
  void _showCitySearchDialog(BuildContext context) {
    String cityNameInput = ''; 
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Search City', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[850],
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter city name (e.g., London, Nairobi)',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            
            onChanged: (value) {
              cityNameInput = value;
            },
            onSubmitted: (value) {
              cityNameInput = value;
              if (cityNameInput.isNotEmpty) {
                _pageLogger.i("City search dialog submitted: $cityNameInput");
                // Using .of(context, listen: false) as we only call a method
                Provider.of<WeatherProvider>(context, listen: false)
                    .fetchWeatherForCity(cityNameInput);
              }
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                if (cityNameInput.isNotEmpty) {
                  _pageLogger.i("City search dialog button pressed: $cityNameInput");
                  
                  Provider.of<WeatherProvider>(context, listen: false)
                      .fetchWeatherForCity(cityNameInput);
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Search', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}