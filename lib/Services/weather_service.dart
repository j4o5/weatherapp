import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const baseUrl = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else{
      throw Exception('Failed to load weather data!');
    }
  }

  Future<String> getCurrentCity() async {

    //get permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    //fetch current location
    if (permission == LocationPermission.deniedForever) {
      // You might want to log this with _serviceLogger.e as well
      throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, 
      distanceFilter: 100,
      
    );

    // fetch current location using the new locationSettings parameter
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings, // <--- RESOLVED THE DEPRECATION WARNING HERE
    );

    //convert location into a placemark objects
    List<Placemark> placemarks = 
    await placemarkFromCoordinates(position.latitude, position.longitude);
    //extract the cityname from the first placemark
    String? city = placemarks[0].locality;

    return city ?? "";
  }
}