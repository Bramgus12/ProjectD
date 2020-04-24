import 'package:http/http.dart' as http;
import 'package:plantexpert/api/WeatherStation.dart';
import 'dart:convert';

class ApiConnection {

  final String url = 'http://192.168.178.29:8080/api/';
  
  Future<List<WeatherStation>> fetchWeatherStations(String region) async {
    http.Response response = await http.get('${url}weather/$region');
    if(response.statusCode != 200) {
      return null;
    }
    Iterable jsonWeatherStations = json.decode(response.body);
    return jsonWeatherStations.map<WeatherStation>((jsonWeatherStation) => WeatherStation.fromJson(jsonWeatherStation)).toList();
  }

}