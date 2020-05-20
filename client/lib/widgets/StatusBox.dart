import 'package:flutter/material.dart';
import 'package:plantexpert/Theme.dart';

enum Status {
  none,
  loading,
  error,
  message
}

class StatusBox extends StatelessWidget {
  /// Creates a box used for indicating the status of the current page.
  /// Usefull for letting the user know the app is waiting for a response of the server.
  final String message;
  final Status status;
  final double _padding = 15.0; 

  StatusBox({this.status=Status.none, this.message="Test"});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case Status.loading:
        return Container(
          padding: EdgeInsets.all(_padding),
          child: CircularProgressIndicator()
        );
        break;
      case Status.error:
      case Status.message:
        return Container(
          padding: EdgeInsets.all(_padding),
          margin: EdgeInsets.symmetric(vertical: 10),
          color: status == Status.error ? ThemeColors.errorBackground : null,
          child: Text(
            message,
            style: TextStyle(color: status == Status.error ? Colors.white : null),
            textAlign: TextAlign.center,
          )
        );
        break;
      default:
        return Container(padding: EdgeInsets.all(_padding));
    }
  }
}