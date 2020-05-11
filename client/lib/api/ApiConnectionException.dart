import 'dart:io';

class ApiConnectionException implements IOException {

  final String message;

  ApiConnectionException([this.message]);

  @override
  String toString() {
    if (message == null) return "ApiConnectionException";
    return "ApiConnectionException: $message";
  }

}