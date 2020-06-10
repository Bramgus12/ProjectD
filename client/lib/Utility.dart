// File for utility functions that might be usefull anywhere in the code.abstract
import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:plantexpert/api/Forecast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';

// Generate a random string of a given length
String randomString(int length) {
  const possibleCharacters = "abcdefghijklmnopqrstuvwxyz0123456789";
  Random random = Random(DateTime.now().millisecondsSinceEpoch);
  String generatedString = "";
  for (int i = 0; i < length; i++) {
    generatedString +=
        possibleCharacters[random.nextInt(possibleCharacters.length)];
  }
  return generatedString;
}

// dd-MM-yyyy HH:mm
String formatDate(DateTime date) {
  if (date == null) {
    throw new ArgumentError('date is null');
  }
  var year = date.year;
  var month = date.month.toString().padLeft(2, '0');
  var day = date.day.toString().padLeft(2, '0');
  var hour = date.hour.toString().padLeft(2, '0');
  var minute = date.minute.toString().padLeft(2, '0');

  return '$day-$month-$year $hour:$minute';
}

// Verbruik water = (((waterhoeveelheid per dag van de plant * inhoud plant pot modifier) * dag) * (raam afstand modifier * zonkans))
/// Calculate the next date the plant will need water
/// [waterAmountPerDay] is in ml/day the plant needs
/// [potVolume] is the volume in liters
/// [windowDistance] is the distance of the plant from the window, on a scale of 1 to 5, where 5 is close to the window and 5 is far from the window
Future<DateTime> calculateNextWateringDate(int waterAmountPerDay, double potVolume, int windowDistance, int waterScale, { DateTime date}) async {
  var api = new ApiConnection();
  List<Forecast> forecasts = (await api.fetchWeatherForecast());
  double volumePlantPotModifier = 0;
  [{10: 2.6}, {8: 2.2}, {5: 1.8}, {3: 1.4}, {1: 1.0}].forEach((element) { element.forEach((key, value) { if(key <= potVolume.ceil()) { volumePlantPotModifier = value; } }); });
  double windowRangeModifier = 0;
  [{1: 0.8}, {2: 0.85}, {3: 0.9}, {4: 0.95}, {5: 1.0}].forEach((element) { if(element.containsKey(windowDistance)) windowRangeModifier = element[windowDistance]; });
  double sunChance = 0;
  double totalWaterNeeded = waterScale * 35.0; //35-175ml
  forecasts.forEach((element) { sunChance += element.sunChanse; });
  sunChance /= forecasts.length;
  int waterPerDay = ( ( (waterAmountPerDay * volumePlantPotModifier) * (windowRangeModifier + (sunChance ~/ 100) ) ) ).ceil();
  print('water per day: $waterPerDay');
  int daysToNextWatering =  totalWaterNeeded ~/ waterPerDay;
  print('days to next watering: $daysToNextWatering');
  if(date != null)
    return date.add(Duration(days: daysToNextWatering));
  return DateTime.now().add(Duration(days: daysToNextWatering));
}
