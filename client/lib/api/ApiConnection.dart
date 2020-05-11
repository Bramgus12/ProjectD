import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/api/WeatherStation.dart';
import 'dart:convert';

class ApiConnection {

  final String baseUrl;

  ApiConnection()
    : baseUrl = 'http://${GlobalConfiguration().getString("server")}:${GlobalConfiguration().getInt("port")}/api/';

  Future<dynamic> _fetchJson(String url) async {
    try {
      http.Response response = await http.get(url);
      if(response.statusCode != 200){
        print("Received response with status code no equal to 200 while fetching url: $url");
        print("Status Code: ${response.statusCode}");
        return null;
      }
      return json.decode(response.body);
    } on SocketException catch(e) {
      print("SocketException occured while trying to fetch url: $url");
      print(e);
      return null;
    } on FormatException catch(e) {
      print("Invalid json received from url: $url");
      print(e);
      return null;
    }
  }
  
  Future<List<WeatherStation>> fetchWeatherStations(String region) async {
    dynamic jsonWeatherStations = await _fetchJson('${baseUrl}weather/$region');
    if (jsonWeatherStations != null && jsonWeatherStations is Iterable)
      return jsonWeatherStations.map<WeatherStation>((jsonWeatherStation) => WeatherStation.fromJson(jsonWeatherStation)).toList();
    else
      print("Error: jsonWeatherStations is not a list.");
    return null;
  }

}