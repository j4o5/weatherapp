import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http; // Make sure this import is present
import '../models/weather_data.dart';
import '../services/weather_service.dart';

final Logger _providerLogger = Logger();

class WeatherProvider with ChangeNotifier {
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  
  final WeatherService _weatherService = WeatherService(http.Client() as String);

  WeatherProvider() {
    _providerLogger.i("WeatherProvider initialized. Attempting to fetch initial weather.");
    fetchWeatherForCurrentLocation();
  }

  Future<void> fetchWeatherForCity(String cityName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _providerLogger.i("Fetching weather for city: $cityName");
    try {
      _currentWeather = await _weatherService.getWeather(cityName);
      _errorMessage = null;
      _providerLogger.i("Weather fetched successfully for $cityName: ${_currentWeather?.mainCondition}, ${_currentWeather?.temperature.round()}°C");
    } catch (e, stackTrace) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _currentWeather = null;
      _providerLogger.e("Failed to fetch weather for $cityName: $_errorMessage", error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherForCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _providerLogger.i("Attempting to fetch weather for current location.");
    try {
      String cityName = await _weatherService.getCurrentCity();

      if (cityName.isEmpty || cityName == "Unknown City") {
        _errorMessage = 'Could not determine current city. Please search manually.';
        _providerLogger.w("Could not determine current city.");
        _currentWeather = null;
      } else {
        _currentWeather = await _weatherService.getWeather(cityName);
        _errorMessage = null;
        _providerLogger.i("Weather fetched successfully for current location ($cityName): ${_currentWeather?.mainCondition}, ${_currentWeather?.temperature.round()}°C");
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Could not get current location: ${e.toString().replaceFirst('Exception: ', '')}';
      _currentWeather = null;
      _providerLogger.e("Failed to fetch weather for current location: $_errorMessage", error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}