import 'package:flutter/material.dart';
import 'package:plantexpert/Theme.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget{
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  ApiConnection apiConnection = new ApiConnection();

  String _errorMessage = "";
  bool _showError = false;

  void showErrorMessage(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
      _showError = true;
    });
  }

  void hideErrorMessage(){
    setState(() {
      _showError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ThemeColors.selected
                      )
                    ),
                    hintText: "Username"
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ThemeColors.selected
                      )
                    ),
                    hintText: "Password"
                  ),
                  obscureText: true,
                ),
              ),
              Visibility(
                visible: _showError,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                      _errorMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: ThemeColors.errorBackground
                ),
              ),
              RaisedButton(
                onPressed: login,
                child: const Text("Login")
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try{
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
        showErrorMessage("Incorrect username or password.");
      }
    }
    on ApiConnectionException catch(e) {
      print(e);
      showErrorMessage("Error connecting to server.");
    }
    on StatusCodeException catch(e) {
      print(e);
      showErrorMessage("Server responded with status code: ${e.reponse.statusCode}");
    }
  }
}