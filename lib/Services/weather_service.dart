import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/weather_data.dart'; 
import '../utils/app_constants.dart'; 

final Logger _serviceLogger = Logger(); 

class WeatherService {
  static const baseUrl = 'http://api.openweathermap.org/data/2.5/weather';
     final http.Client _httpClient;
  WeatherService(this._httpClient) {
    _serviceLogger.i("WeatherService initialized with http.Client.");
  }

  Future<WeatherData> getWeather(String cityName) async {
    _serviceLogger.i("Fetching weather for city: $cityName");
    final uri = Uri.parse(
        '$baseUrl?q=$cityName&appid=${AppConstants.openWeatherMapApiKey}&units=metric');

    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      _serviceLogger.i("Weather data successfully received for $cityName.");
      return WeatherData.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      _serviceLogger.e('City not found for: $cityName (Status: 404)');
      throw Exception('City not found. Please check the spelling.');
    } else {
      _serviceLogger.e('Failed to load weather data for $cityName: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load weather data! Status: ${response.statusCode}');
    }
  }

  Future<WeatherData> getWeatherByCoordinates(double latitude, double longitude) async {
    _serviceLogger.i("Fetching weather for coordinates: Lat=$latitude, Lon=$longitude");
    final uri = Uri.parse(
        '$baseUrl?lat=$latitude&lon=$longitude&appid=${AppConstants.openWeatherMapApiKey}&units=metric');

    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      _serviceLogger.i("Weather data successfully received for coordinates.");
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      _serviceLogger.e('Failed to load weather data by coordinates: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load weather data by coordinates! Status: ${response.statusCode}');
    }
  }

  Future<String> getCurrentCity() async {
    _serviceLogger.i("Attempting to get current city.");

    // get permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _serviceLogger.w("Location permission denied. Requesting permission...");
      permission = await Geolocator.requestPermission();
    }

    // fetch current location
    if (permission == LocationPermission.deniedForever) {
      _serviceLogger.e('Location permissions are permanently denied. Cannot get current city.');
      throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _serviceLogger.e('Location services are disabled.');
      throw Exception('Location services are disabled. Please enable them.');
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      _serviceLogger.i("Geolocation successful: Lat=${position.latitude}, Lon=${position.longitude}");
    } catch (e, stackTrace) {
      _serviceLogger.e("Failed to get current position: $e", error: e, stackTrace: stackTrace);
      throw Exception('Failed to get current location: $e');
    }

    // convert location into a placemark objects
    List<Placemark> placemarks;
    try {
      placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    } catch (e, stackTrace) {
      _serviceLogger.e("Failed to get placemarks from coordinates: $e", error: e, stackTrace: stackTrace);
      throw Exception('Failed to determine city from coordinates: $e');
    }


    // extract the cityname from the first placemark
    String? city = placemarks.isNotEmpty ? placemarks[0].locality : null;

    if (city == null || city.isEmpty) {
      _serviceLogger.w("Could not determine city name from placemarks. Placemarks count: ${placemarks.length}");
      return "Unknown City"; 
    }

    _serviceLogger.i("Current city determined: $city");
    return city;
  }
}