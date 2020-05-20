import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/pages/account/LoginInputField.dart';
import 'package:plantexpert/widgets/StatusBox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget{
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 350),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Login", style: TextStyle(fontSize: 18)),
              ),
              LoginInputField(usernameController, hintText: "Username", enabled: _status != Status.loading),
              LoginInputField(passwordController, hintText: "Password", enabled: _status != Status.loading, obfuscated: true),
              StatusBox(status: _status, message: _statusMessage),
              RaisedButton(
                color: theme.accentColor,
                onPressed: login,
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
    try{
      setState(() {
        _status = Status.loading;
      });
      bool validCredentials = await apiConnection.verifyCredentials(usernameController.text, passwordController.text);
      if (validCredentials) {
        print("Credentials are valid.");
        // Save username and password to shared preferences. This not a secure approach for a login system and should be changed later.
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString("username", usernameController.text);
        sharedPreferences.setString("password", passwordController.text);
        hideErrorMessage();
        Navigator.pop(context);
      }
      else {
        print("Invalid Credentials.");
        showErrorMessage("Incorrect password.");
      }
    }
    on ApiConnectionException catch(e) {
      print(e);
      showErrorMessage("Error connecting to server.");
    }
    on StatusCodeException catch(e) {
      print(e);
      if(e.reponse.statusCode == 404) {
        showErrorMessage("User '${usernameController.text}' does not exist.");
      } else {
        showErrorMessage("Server error: ${e.reponse.statusCode}");
      }
    }
  }
}