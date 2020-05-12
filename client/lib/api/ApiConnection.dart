import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/api/JsonSerializeable.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/api/WeatherStation.dart';
import 'dart:convert';

import 'ApiConnectionException.dart';

class ApiConnection {

  final String baseUrl;

  ApiConnection()
    : baseUrl = 'http://${GlobalConfiguration().getString("server")}:${GlobalConfiguration().getInt("port")}/api/';

  // Fetch json
  Future<dynamic> _fetchJson(String url, { Map<String, String> headers } ) async {
    if (headers == null) headers = HashMap();
    headers.putIfAbsent('Accept', () => 'application/json');
    try {
      http.Response response = await http.get(url, headers: headers)
        .timeout(const Duration(seconds: 15));

      if(response.statusCode != 200){
        throw ApiConnectionException("Received response with status code ${response.statusCode} while fetching url: $url");
      }
      return json.decode(response.body);

    } on SocketException catch(e) {
      print(e);
      throw ApiConnectionException("SocketException occured while trying to fetch url: $url");
    } on TimeoutException catch(e) {
      print(e);
      throw ApiConnectionException("Timed out while trying to fetch url: $url");
    }
    on FormatException catch(e) {
      print(e);
      throw ApiConnectionException("Invalid json received from url: $url");
    } catch(e) {
      print(e);
      throw ApiConnectionException("Exception occured while trying to fetch url: $url");
    }
  }

  Future<Map<String, dynamic>> _fetchJsonObject(String url) async {
    dynamic jsonObject = await _fetchJson(url);
    if (jsonObject is Map<String, dynamic>)
      return jsonObject;
    throw ApiConnectionException("jsonObject is not of type Map<String, dynamic>. Url: $url");
  }

  Future<Iterable> _fetchJsonList(String url) async {
    Iterable jsonList = await _fetchJson(url);
    if (jsonList is Iterable)
      return jsonList;
    throw ApiConnectionException("jsonList is not of type Iterable. Url: $url");
  }

  // Post json
  Future<http.Response> _postJson(String url, JsonSerializeable jsonObject, { Map<String, String> headers }) async {
    if (headers == null) headers = HashMap();
    headers.putIfAbsent('Accept', () => 'application/json');
    try {
      http.Response response = await http.post(
        url,
        body: json.encode(jsonObject.toJson())
      );

      if(response.statusCode != 200){
        throw ApiConnectionException("Received response with status code ${response.statusCode} while fetching url: $url");
      }
      return response;

    } on SocketException catch(e) {
      print(e);
      throw ApiConnectionException("SocketException occured while posting to url: $url");
    } on TimeoutException catch(e) {
      print(e);
      throw ApiConnectionException("Timed out while posting to url: $url");
    }
    on FormatException catch(e) {
      print(e);
      throw ApiConnectionException("Invalid json url: $url");
    } catch(e) {
      print(e);
      throw ApiConnectionException("Exception occured while trying to post json to url: $url");
    }
  }
  
  // Weather stations
  Future<List<WeatherStation>> fetchWeatherStations(String region) async {
    Iterable jsonWeatherStations = await _fetchJsonList('${baseUrl}weather/$region');
    return jsonWeatherStations.map<WeatherStation>((jsonWeatherStation) => WeatherStation.fromJson(jsonWeatherStation)).toList();
  }

  // Plants
  Future<List<Plant>> fetchPlants() async {
    Iterable jsonPlants = await _fetchJsonList('${baseUrl}plants');
    return jsonPlants.map<Plant>((jsonPlant) => Plant.fromJson(jsonPlant)).toList();
  }

  Future<Plant> fetchPlant(int id) async {
    Map<String, dynamic> jsonPlant = await _fetchJsonObject('${baseUrl}plants/$id');
    return Plant.fromJson(jsonPlant);
  }

  Future<http.Response> postPlant(Plant plant) async {
    // TODO: add authentication headers
    return await _postJson("${baseUrl}admin/plants", plant);
  }

  // User plants
  Future<List<UserPlant>> fetchUserPlants() async {
    Iterable jsonUserPlants = await _fetchJsonList('${baseUrl}userplants');
    return jsonUserPlants.map<UserPlant>((jsonUserPlant) => UserPlant.fromJson(jsonUserPlant)).toList();
  }

// Not yet implemented on server
  // Future<UserPlant> fetchUserPlant(int id) async {
  //   Map<String, dynamic> jsonUserPlant = await _fetchJsonObject('${baseUrl}userplants/$id');
  //   return UserPlant.fromJson(jsonUserPlant);
  // }

}