// File for utility functions that might be usefull anywhere in the code.abstract
import 'dart:async';
import 'dart:math';
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
    generatedString += possibleCharacters[random.nextInt(possibleCharacters.length)];
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