import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/api/JsonSerializeable.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/api/WeatherStation.dart';
import 'dart:convert';

import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Future<http.Response> RequestFunction();

class ApiConnection {

  final String baseUrl;

  ApiConnection()
    : baseUrl = 'http://${GlobalConfiguration().getString("server")}:${GlobalConfiguration().getInt("port")}/';

  // Basic headers
  Future<Map<String, String>> _createJsonHeader({Map<String, String> headers, type="GET"}) async {
    if(headers == null) headers = Map();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString('username');
    String password = sharedPreferences.getString('password');
    if( headers['Authorization'] == null && username != null && password != null ){
      headers['Authorization'] = "Basic " + base64.encode(utf8.encode("$username:$password")).replaceAll("=", "");
    }
    headers.putIfAbsent('Accept', () => 'application/json');
    if(type == "POST") headers['Content-Type'] = "application/json";
    return headers;
  }

  // Sending requests
  Future<http.Response> _sendRequest(String url, {Map<String, String> headers, String type="GET", String body=""}) async {
    headers = await _createJsonHeader( headers: headers);
    try {
      
      // Send request to server
      http.Response response;
      switch(type) {
        case "GET":
          response = await http.get(
            url, 
            headers: headers
          );
          break;
        case "POST":
          response = await http.post(
            url,
            headers: headers,
            body: body
          );
          break;
        case "PUT":
          response = await http.put(
            url,
            headers: headers,
            body: body
          );
          break;
        case "DELETE":
          response = await http.delete(
            url,
            headers: headers
          );
          break;
        default:
          throw ApiConnectionException("Unknown request type: $type while requesting url: $url");
          break;
      }

      // Handle response code
      if (response.statusCode == 401) {
        print("Status code ${response.statusCode} - Server Response: ${response.body}");
        throw InvalidCredentialsException("Invalid credentials provided while trying to access url: $url");
      }
      else if(response.statusCode >= 400){
        print("Status code ${response.statusCode} - Server Response: ${response.body}");
        throw StatusCodeException(response);
      }
      return response;

    } on SocketException catch(e) {
      print(e);
      throw ApiConnectionException("SocketException occured while trying to fetch url: $url");
    } on TimeoutException catch(e) {
      print(e);
      throw ApiConnectionException("Timed out while trying to fetch url: $url");
    }
  }

  // Fetch json
  Future<dynamic> _fetchJson(String url, { Map<String, String> headers } ) async {
    http.Response response = await _sendRequest(url, headers: headers, type: "GET");

    try {
      if (response.statusCode == 204) {
        return {};
      }
      return json.decode(response.body);
    } on FormatException catch(e) {
      print(e);
      throw ApiConnectionException("Invalid json received from url: $url");
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
    return await _sendRequest(url, headers: headers, type: "POST", body: json.encode(jsonObject.toJson()));
  }

  // Put json
  Future<http.Response> _putJson(String url, JsonSerializeable jsonObject, { Map<String, String> headers }) async {
    return await _sendRequest(url, headers: headers, type: "PUT", body: json.encode(jsonObject.toJson()));
  }

  // Delete json
  Future<http.Response> _deleteJson(String url, { Map<String, String> headers } ) async {
    return await _sendRequest(url, headers: headers, type: "DELETE");
  }
  
  // Weather stations
  Future<List<WeatherStation>> fetchWeatherStations(String region) async {
    Iterable jsonWeatherStations = await _fetchJsonList('${baseUrl}weather/$region/');
    return jsonWeatherStations.map<WeatherStation>((jsonWeatherStation) => WeatherStation.fromJson(jsonWeatherStation)).toList();
  }

  Future<WeatherStation> fetchWeatherStation(double latitude, double longitude) async {
    Map<String, dynamic> jsonWeatherStation = await _fetchJson('${baseUrl}weather/latlon/?lat=$latitude&lon=$longitude');
    return WeatherStation.fromJson(jsonWeatherStation);
  }

  // Plants
  Future<List<Plant>> fetchPlants() async {
    Iterable jsonPlants = await _fetchJsonList('${baseUrl}plants/');
    return jsonPlants.map<Plant>((jsonPlant) => Plant.fromJson(jsonPlant)).toList();
  }

  Future<Plant> fetchPlant(int id) async {
    Map<String, dynamic> jsonPlant = await _fetchJsonObject('${baseUrl}plants/$id/');
    return Plant.fromJson(jsonPlant);
  }

  // User plants
  Future<List<UserPlant>> fetchUserPlants() async {
    Iterable jsonUserPlants = await _fetchJsonList('${baseUrl}user/userplants/');
    return jsonUserPlants.map<UserPlant>((jsonUserPlant) => UserPlant.fromJson(jsonUserPlant)).toList();
  }

// Not yet implemented on server
  // Future<UserPlant> fetchUserPlant(int id) async {
  //   Map<String, dynamic> jsonUserPlant = await _fetchJsonObject('${baseUrl}userplants/$id');
  //   return UserPlant.fromJson(jsonUserPlant);
  // }

  Future<http.Response> postUserPlant(UserPlant userPlant) async {
    return await _postJson("${baseUrl}user/userplants/", userPlant);
  }

  Future<http.Response> putUserPlant(UserPlant userPlant) async {
    return await _putJson("${baseUrl}user/userplants?id=${userPlant.id}", userPlant);
  }

  Future<http.Response> deleteUserPlant(UserPlant userPlant) async {
    return await _deleteJson("${baseUrl}user/userplants?id=${userPlant.id}");
  }

  // Login
  Future<bool> verifyCredentials(String username, String password) async {
    try{
      Map<String, String> headers = Map();
      String base64Authorisation = base64.encode(utf8.encode("$username:$password")).replaceAll("=", "");
      headers['Authorization'] = "Basic $base64Authorisation";
      await _fetchJson("${baseUrl}users/checkpassword?userName=$username&password=$password", headers: headers);
      return true;
    }
    on InvalidCredentialsException catch(e) {
      print(e);
      return false;
    }
  }

}