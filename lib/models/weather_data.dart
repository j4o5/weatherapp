class WeatherData {
  final String cityName;
  final double temperature;
  final String mainCondition; 
  final String iconCode;      
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'], 
      iconCode: json['weather'][0]['icon'],     
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}