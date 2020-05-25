import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/pages/account/LoginInputField.dart';
import 'package:plantexpert/widgets/StatusBox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AccountValidationFunctions.dart';

class LoginTab extends StatefulWidget {
  @override
  _LoginTabState createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  ApiConnection apiConnection = new ApiConnection();

  Status _status = Status.none;
  String _statusMessage = "";

  void showErrorMessage(String errorMessage) {
    setState(() {
      _statusMessage = errorMessage;
      _status = Status.error;
    });
  }

  void hideErrorMessage(){
    setState(() {
      _status = Status.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(maxWidth: 350),
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Login", style: TextStyle(fontSize: 18)),
              ),
              LoginInputField(usernameController, hintText: "Gebruikersnaam", enabled: _status != Status.loading, validator: validateUsername),
              LoginInputField(passwordController, hintText: "Wachtwoord", enabled: _status != Status.loading, obfuscated: true, validator: validatePassword),
              StatusBox(status: _status, message: _statusMessage),
              RaisedButton(
                color: theme.accentColor,
                onPressed: _status == Status.loading ? null : login,
                child: Text(
                  "Login",
                  style: theme.accentTextTheme.button
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    setState(() {
      _status = Status.loading;
    });
    // Client side validation
    if(!_formKey.currentState.validate()){
      setState(() {
        _status = Status.none;
      });
      return;
    }

    // Server side validation
    try{
      bool validCredentials = await apiConnection.verifyCredentials(usernameController.text, passwordController.text);
      if (validCredentials) {
        print("Credentials are valid.");
        // Save username and password to shared preferences.
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString("username", usernameController.text);
        sharedPreferences.setString("password", passwordController.text);
        hideErrorMessage();
        Navigator.pop(context);
      }
      else {
        print("Invalid Credentials.");
        showErrorMessage("Verkeerd wachtwoord.");
      }
    }
    on ApiConnectionException catch(e) {
      print(e);
      showErrorMessage("Fout bij verbinden met server.");
    }
    on StatusCodeException catch(e) {
      print(e);
      if(e.reponse.statusCode == 404) {
        showErrorMessage("Gebruikersnaam '${usernameController.text}' bestaat niet.");
      } else {
        showErrorMessage("Server fout: ${e.reponse.statusCode}");
      }
    }
  }
}