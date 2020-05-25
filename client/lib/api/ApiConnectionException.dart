import 'dart:io';

import 'package:http/http.dart';

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

class StatusCodeException implements IOException {

  // TODO: fix typo
  final Response reponse;

  StatusCodeException(this.reponse);

  @override
  String toString() {
    return "StatusCodeException: ${reponse.statusCode}";
  }

}