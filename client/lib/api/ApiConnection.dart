import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/api/WeatherStation.dart';
import 'dart:convert';

import '../pages/add-plant.dart';

class ApiConnection {

  final String baseUrl;

  ApiConnection()
    : baseUrl = 'http://${GlobalConfiguration().getString("server")}:${GlobalConfiguration().getInt("port")}/api/';

  Future<dynamic> _fetchJson(String url) async {
    http.Response response = await http.get(url);
    if(response.statusCode != 200)
      return null;
    return json.decode(response.body);
  }
  
  Future<List<WeatherStation>> fetchWeatherStations(String region) async {
    Iterable jsonWeatherStations = await _fetchJson('${baseUrl}weather/$region');
    if(jsonWeatherStations == null)
      return null;
    return jsonWeatherStations.map<WeatherStation>((jsonWeatherStation) => WeatherStation.fromJson(jsonWeatherStation)).toList();
  }

}