class WeatherStation {

  String code;
  String name;
  String region;
  double sunIntensity;
  double airPressure;
  double airHumidity;
  double latitude;
  double longitude;
  String dateString;
  double windSpeed;
  String windDirection;
  double temperature;
  WeatherStationIcon icoonactueel;

  WeatherStation({
    this.code,
    this.name,
    this.region,
    this.sunIntensity,
    this.airPressure,
    this.airHumidity,
    this.latitude,
    this.longitude,
    this.dateString,
    this.windSpeed,
    this.windDirection,
    this.temperature,
    this.icoonactueel
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
      dateString: jsonWeatherStation['datum'],
      windSpeed: double.tryParse(jsonWeatherStation['windsnelheidMS']),
      windDirection: jsonWeatherStation['windrichting'],
      temperature: double.tryParse(jsonWeatherStation['temperatuurGC']),
      icoonactueel: WeatherStationIcon(
        value: jsonWeatherStation['icoonactueel']['value'],
        id: jsonWeatherStation['icoonactueel']['id'],
        zin: jsonWeatherStation['icoonactueel']['zin'],
      ) ,

    );
  }

  @override
  String toString() {
    return
'''[ Weather Station $code ]
name:\t\t$name
region:\t\t$region
sun intensity:\t$sunIntensity
air pressure:\t$airPressure
air humudity:\t$airHumidity
latitude:\t\t$latitude
longitude:\t\t$longitude
date:\t\t$dateString
wind speed:\t\t$windSpeed
wind direction:\t$windDirection
temperature:\t\t$temperature
icoonactueel:
\tvalue:\t\t${icoonactueel.value}
\tid:\t\t${icoonactueel.id}
\tzin:\t\t${icoonactueel.zin}
''';
  }

}

class WeatherStationIcon {
  String value;
  String id;
  String zin;

  WeatherStationIcon({
    this.value, 
    this.id, 
    this.zin});
}