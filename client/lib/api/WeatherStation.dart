class WeatherStation {

  String code;
  String name;
  String region;
  double sunIntensity;
  double airPressure;
  double airHumidity;
  double latitude;
  double longitude;

  WeatherStation({
    this.code,
    this.name,
    this.region,
    this.sunIntensity,
    this.airPressure,
    this.airHumidity,
    this.latitude,
    this.longitude
  });

  factory WeatherStation.fromJson(Map<String, dynamic> jsonWeatherStation) {
    return WeatherStation(
      code: jsonWeatherStation['stationcode'],
      name: jsonWeatherStation['stationnaam']['value'],
      region: jsonWeatherStation['stationnaam']['regio'],
      sunIntensity: double.tryParse(jsonWeatherStation['zonintensiteitWM2']),
      airPressure: double.tryParse(jsonWeatherStation['luchtdruk']),
      airHumidity: double.tryParse(jsonWeatherStation['luchtvochtigheid']),
      latitude: double.tryParse(jsonWeatherStation['latGraden']),
      longitude: double.tryParse(jsonWeatherStation['lonGraden']),
    );
  }

}