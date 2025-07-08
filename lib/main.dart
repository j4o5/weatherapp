

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'pages/weather_page.dart';
import 'providers/weather_provider.dart'; 

void main() {
  runApp(
    
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, 
          elevation: 0, 
        ),
        scaffoldBackgroundColor: Colors.grey[900], 
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WeatherPage(), 
    );
  }
}