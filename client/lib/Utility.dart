// File for utility functions that might be usefull anywhere in the code.abstract
import 'dart:math';

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