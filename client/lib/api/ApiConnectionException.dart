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

class InvalidCredentialsException implements IOException {

  final String message;

  InvalidCredentialsException([this.message]);

  @override
  String toString() {
    if (message == null) return "InvalidCredentialsException";
    return "InvalidCredentialsException: $message";
  }

}