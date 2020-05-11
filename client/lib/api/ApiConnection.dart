import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/api/Plant.dart';
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

  Future<Map<String, dynamic>> _fetchJsonObject(String url) async {
    dynamic jsonObject = await _fetchJson(url);
    if (jsonObject != null && jsonObject is Map<String, dynamic>)
      return jsonObject;
    else
      print("Error: json fetched from url: $url is not a list.");
    return null;
  }

  Future<Iterable> _fetchJsonList(String url) async {
    Iterable jsonList = await _fetchJson(url);
    if (jsonList != null && jsonList is Iterable)
      return jsonList;
    else
      print("Error: json fetched from url: $url is not a list.");
    return null;
  }
  
  // Weather stations
  Future<List<WeatherStation>> fetchWeatherStations(String region) async {
    Iterable jsonWeatherStations = await _fetchJsonList('${baseUrl}weather/$region');
    if (jsonWeatherStations != null)
      return jsonWeatherStations.map<WeatherStation>((jsonWeatherStation) => WeatherStation.fromJson(jsonWeatherStation)).toList();
    else
      print("Error: jsonWeatherStations is null");
    return null;
  }

  // Plants
  Future<List<Plant>> fetchPlants() async {
    Iterable jsonPlants = await _fetchJsonList('${baseUrl}plants');
    if (jsonPlants != null)
      return jsonPlants.map<Plant>((jsonPlant) => Plant.fromJson(jsonPlant)).toList();
    else
      print("Error: jsonPlants is null.");
    return null;
  }

  Future<Plant> fetchPlant(int id) async {
    Map<String, dynamic> jsonPlant = await _fetchJsonObject('${baseUrl}plants/$id');
    if (jsonPlant != null)
      return Plant.fromJson(jsonPlant);
    else
      print("Error: jsonPlant is null.");
    return null;
  }

}