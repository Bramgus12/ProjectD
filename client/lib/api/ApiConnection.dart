import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/Utility.dart';
import 'package:plantexpert/api/JsonSerializeable.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/User.dart';
import 'package:plantexpert/api/Forecast.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/api/WeatherStation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Future<http.Response> RequestFunction();

class ApiConnection {

  final String baseUrl;

  ApiConnection()
    : baseUrl = 'http${GlobalConfiguration().getBool("ssl") ? "s" : ""}://${GlobalConfiguration().getString("server")}:${GlobalConfiguration().getInt("port")}/';

  // Basic headers
  Future<Map<String, String>> _createHeaders({Map<String, String> headers, String type="GET", String accept="application/json", contentType="application/json"}) async {
    if(headers == null) headers = Map();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString('username');
    String password = sharedPreferences.getString('password');
    if( headers['Authorization'] == null && username != null && password != null ){
      headers['Authorization'] = "Basic " + base64.encode(utf8.encode("$username:$password")).replaceAll("=", "");
    }
    headers.putIfAbsent('Accept', () => accept);
    if(type == "POST" || type == "PUT") headers['Content-Type'] = contentType;
    return headers;
  }

  // Sending basic requests
  Future<http.Response> _sendRequest(String url, {Map<String, String> headers, String type="GET", dynamic body="", File file}) async {
    headers = await _createHeaders( headers: headers, type: type);
    String fullUrl = baseUrl + url;
    try {
      
      // Send request to server
      http.Response response;
      switch(type) {
        case "GET":
          response = await http.get(
            fullUrl, 
            headers: headers
          );
          break;
        case "POST":
          response = await http.post(
            fullUrl,
            headers: headers,
            body: body
          );
          break;
        case "PUT":
          response = await http.put(
            fullUrl,
            headers: headers,
            body: body
          );
          break;
        case "DELETE":
          response = await http.delete(
            fullUrl,
            headers: headers
          );
          break;
        case "MULTIPART":
          http.MultipartRequest request = new http.MultipartRequest("POST", Uri.parse(fullUrl));
          request.headers.addAll(headers);
          request.files.add(await http.MultipartFile.fromPath(
            "file", 
            file.path,
            contentType: MediaType('image', 'jpeg')
          ));
          http.StreamedResponse streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
          break;
        default:
          throw ApiConnectionException("Unknown request type: $type while requesting url: $fullUrl");
          break;
      }

      // Handle response code
      if (response.statusCode == 401) {
        print("Status code ${response.statusCode} - Server Response: ${response.body}");
        throw InvalidCredentialsException("Invalid credentials provided while trying to access url: $fullUrl");
      }
      else if(response.statusCode >= 400){
        print("Status code ${response.statusCode} - Server Response: ${response.body}");
        throw StatusCodeException(response);
      }
      return response;

    } on SocketException catch(e) {
      print(e);
      throw ApiConnectionException("SocketException occured while trying to fetch url: $fullUrl");
    } on TimeoutException catch(e) {
      print(e);
      throw ApiConnectionException("Timed out while trying to fetch url: $fullUrl");
    }
  }

  // Fetch image from api
  Future<Image> _fetchImage(String url, { Map<String, String> headers }) async {
    headers = await _createHeaders(headers: headers, accept: "image/jpeg", contentType: "image/jpeg");
    String fullUrl = baseUrl + url;
    return Image.network(fullUrl, headers: headers);
  }

  // ----------
  // The following problem seems to be related to a "false positive" for the dart framework and could be fully ignored
  // I/flutter (15227): CacheManager: Failed to download file from https://hrplanner.nl:443/user/userplants/9/2020-05-31-194029-t1glxowr.jpg/ with error:
  // I/flutter (15227): HttpException: Invalid statusCode: 404, uri = https://hrplanner.nl/user/userplants/9/2020-05-31-194029-t1glxowr.jpg/
  // https://github.com/Baseflow/flutter_cached_network_image/issues/144
  // ----------
  // Fetch image from api and return a (cached) resource.
  Future<CachedNetworkImage> _fetchCachedImage(String url, { Map<String, String> headers, double height = 400, double width }) async {
    headers = await _createHeaders(headers: headers, accept: "image/jpeg", contentType: "image/jpeg");
    String fullUrl = baseUrl + url;
    return CachedNetworkImage(
      imageUrl: fullUrl,
      httpHeaders: headers,
      height: height,
      width: width,
      alignment: Alignment.centerLeft,
      placeholder: (BuildContext context, String url) =>
          Image.asset("assets/images/image-placeholder.png"),
      errorWidget: (context, url, error) =>
          Image.asset("assets/images/image-placeholder.png"),
    );
  }

  // Convert http response body to json with error handling.
  dynamic _jsonFromResponse(http.Response response) {
    try {
      if (response.statusCode == 204) {
        return {};
      }
      return json.decode(utf8.decode(response.bodyBytes));
    } on FormatException catch(e) {
      print(e);
      throw ApiConnectionException("Invalid json received from url: ${response.request.url}");
    }
  }

  // Fetch json
  Future<dynamic> _fetchJson(String url, { Map<String, String> headers } ) async {
    http.Response response = await _sendRequest(url, headers: headers, type: "GET");
    return _jsonFromResponse(response);
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

  // User 
  Future<User> fetchUser() async {
    /// Fetches the user data of the logged in user.
    Map<String, dynamic> jsonUser = await _fetchJson("user/users/");
    return User.fromJson(jsonUser);
  }

  Future<http.Response> postUser(User user) async {
    return await _postJson("users/", user);
  }

  Future<http.Response> putUser(User user) async {
    return await _putJson("user/users/${user.id}/", user);
  }

  Future<http.Response> putAdminUser(User user) async {
    return await _putJson("admin/users/${user.id}/", user);
  }

  // Weather forecast
  Future<List<Forecast>> fetchWeatherForecast() async {
    Map<String, dynamic> jsonWeatherStations = await _fetchJsonObject('weather/forecast/');
    List<Forecast> forecasts = List<Forecast>();
    jsonWeatherStations.forEach((key, value) {
      if(key.toLowerCase().contains('dagplus')){
        forecasts.add(Forecast.fromJson( value ));
      }
    });
    return forecasts;
  }

  // Weather stations
  Future<List<WeatherStation>> fetchWeatherStations(String region) async {
    Iterable jsonWeatherStations = await _fetchJsonList('weather/$region/');
    return jsonWeatherStations.map<WeatherStation>((jsonWeatherStation) => WeatherStation.fromJson(jsonWeatherStation)).toList();
  }

  Future<WeatherStation> fetchWeatherStation(double latitude, double longitude) async {
    Map<String, dynamic> jsonWeatherStation = await _fetchJson('weather/latlon/?lat=$latitude&lon=$longitude');
    return WeatherStation.fromJson(jsonWeatherStation);
  }

  // Plants
  Future<List<Plant>> fetchPlants() async {
    Iterable jsonPlants = await _fetchJsonList('plants/');
    return jsonPlants.map<Plant>((jsonPlant) => Plant.fromJson(jsonPlant)).toList();
  }

  Future<Plant> fetchPlant(int id) async {
    Map<String, dynamic> jsonPlant = await _fetchJsonObject('plants/$id/');
    return Plant.fromJson(jsonPlant);
  }

  // User plants
  Future<List<UserPlant>> fetchUserPlants() async {
    Iterable jsonUserPlants = await _fetchJsonList('user/userplants/');
    return jsonUserPlants.map<UserPlant>((jsonUserPlant) =>
        UserPlant.fromJson(jsonUserPlant)).toList();
  }

// Not yet implemented on server
  // Future<UserPlant> fetchUserPlant(int id) async {
  //   Map<String, dynamic> jsonUserPlant = await _fetchJsonObject('userplants/$id');
  //   return UserPlant.fromJson(jsonUserPlant);
  // }

  String _generateImageFileName() {
    return DateFormat("yyyy-MM-dd-HHmmss-").format(DateTime.now()) + randomString(8) + ".jpg";
  }

  Future<UserPlant> postUserPlant(UserPlant userPlant, File imageFile) async {
    userPlant.imageName = _generateImageFileName();
    http.Response response = await _postJson("user/userplants/", userPlant);
    Map<String, dynamic> jsonUserPlant = _jsonFromResponse(response);
    UserPlant responseUserPlant = UserPlant.fromJson(jsonUserPlant);
    // Copy the user plant id created by the server to the local user plant object
    userPlant.id = responseUserPlant.id;
    await uploadUserPlantImage(userPlant, imageFile);
    return userPlant;
  }

  Future<http.Response> putUserPlant(UserPlant userPlant) async {
    return await _putJson("user/userplants?id=${userPlant.id}", userPlant);
  }

  Future<List<dynamic>> putUserPlantWithImage(UserPlant userPlant, File imageFile) async {
    userPlant.imageName = _generateImageFileName();
    http.Response plantResponse = await putUserPlant(userPlant);
    // Copy the user plant id created by the server to the local user plant object
    http.Response imageResponse = await uploadUserPlantImage(userPlant, imageFile);
    return [plantResponse, imageResponse];
  }

  Future<http.Response> deleteUserPlant(UserPlant userPlant) async {
    return await _deleteJson("user/userplants?id=${userPlant.id}");
  }

  // Upload image of userplant
  Future<http.Response> uploadUserPlantImage(UserPlant userPlant, File imageFile) async {
    String imageName = userPlant.imageName == null ? _generateImageFileName() : userPlant.imageName;
    return await _sendRequest("user/userplants/image?imageName=$imageName&userPlantId=${userPlant.id}", type: "MULTIPART", file: imageFile);
  }

  Future<Image> fetchUserPlantImage(UserPlant userPlant) async {
    return await _fetchImage("user/userplants/${userPlant.id}/${userPlant.imageName}/");
  }

  Future<CachedNetworkImage> fetchCachedPlantImage(UserPlant userPlant,  { double height = 400, double width }) async {
    return _fetchCachedImage("user/userplants/${userPlant.id}/${userPlant.imageName}/", width: width, height: height);
  }

  // Login
  Future<bool> verifyCredentials(String username, String password) async {
    try{
      Map<String, String> headers = Map();
      String base64Authorisation = base64.encode(utf8.encode("$username:$password")).replaceAll("=", "");
      headers['Authorization'] = "Basic $base64Authorisation";
      await _fetchJson("users/checkpassword?userName=$username&password=$password", headers: headers);
      return true;
    }
    on InvalidCredentialsException catch(e) {
      print(e);
      return false;
    }
  }

}