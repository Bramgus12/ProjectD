class Forecast {

  String dateString;
  String weekday;
  int sunChanse;
  int rainChanse;
  int minMmRain;
  int maxMmRain;
  int minTemp;
  int maxTemp;
  String windDirection;
  int windForce;

  Forecast({
    this.dateString,
    this.weekday,
    this.sunChanse,
    this.rainChanse,
    this.minMmRain,
    this.maxMmRain,
    this.minTemp,
    this.maxTemp,
    this.windDirection,
    this.windForce,
  });

  factory Forecast.fromJson(Map<String, dynamic> jsonForecast) {
    return Forecast(
      dateString: jsonForecast['datum'],
        weekday: jsonForecast['dagweek'],
        sunChanse: int.tryParse(jsonForecast['kanszon']),
        rainChanse: int.tryParse(jsonForecast['kansregen']),
        minMmRain: int.tryParse(jsonForecast['minmmregen']),
        maxMmRain: int.tryParse(jsonForecast['maxmmregen']),
        minTemp: int.tryParse(jsonForecast['mintemp']),
        maxTemp: int.tryParse(jsonForecast['maxtempmax']),
        windDirection: jsonForecast['windrichting'],
        windForce: int.tryParse(jsonForecast['windkracht']),
    );
  }

  @override
  String toString() {
    return
      '''[ Forecast $dateString ]
date:\t\t$dateString
weekday:\t\t$weekday
sunChanse:\t\t$sunChanse
rainChanse:\t\t$rainChanse
minMmRain:\t\t$minMmRain
maxMmRain:\t\t$maxMmRain
minTemp:\t\t$minTemp
maxTemp:\t\t$maxTemp
windDirection:\t\t$windDirection
windForce:\t\t$windForce
''';
  }
}


//"sneeuwcms": "0"
//}