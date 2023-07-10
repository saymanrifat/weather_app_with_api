class WeatherData {
  // final String myCity;
  final String weatherDesc;
  final String time;
  final String temp;
  final String maxTemp;
  final String minTemp;
  final String iconCode;

  WeatherData(this.weatherDesc, this.time, this.temp, this.maxTemp,
      this.minTemp, this.iconCode);

  factory WeatherData.toJson(Map<String, dynamic> e) {
    return WeatherData(
      e['weather'][0]['description'],
      e['time'],
      e['main']['temp'],
      e['main']['temp_max'],
      e['main']['temp_min'],
      e['weather'][0]['icon'],
    );
  }
}
