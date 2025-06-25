import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/Services/weather_service.dart';
import 'package:my_app/models/weather_model.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState () => _WeatherPageState();

}

class _WeatherPageState extends State<WeatherPage> {

  //api key
  final _weatherService = WeatherService('d05d4bc447bf874eabdb0ed74ea840f4');
  Weather? _weather;
  //fetch weather
  _fetchWeather() async {
    //get current city
    String cityName = await _weatherService.getCurrentCity();
    //get the weather for the city
    try{
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
      _logger.i("Weather fetched successfully for $cityName: ${_weather?.mainCondition}, ${_weather?.temperature.round()}°C");
    }
    //any errors
    catch (e, stackTrace) {
      _logger.e("Failed to fetch weather for $cityName: $e", error: e, stackTrace: stackTrace);

      if (mounted) { // Check if the widget is still in the tree before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching weather: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  //weather animations
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json'; //default to sunny

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dusty':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/sunclody.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';

    }
  }
  //initial state
  @override
  void initState() {
    super.initState();

    //fetch weather on startup
     _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           // city name
           Text(_weather?.cityName ?? "loading city..."),

           // animation
           Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
        
           // temperature
           Text('${_weather?.temperature.round()}°C'),

           // weather condition
           Text(_weather?.mainCondition ?? "")
         ],
        ),
      ),
    );
  }
}