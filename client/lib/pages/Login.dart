import 'package:flutter/material.dart';
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
                        color: Colors.blue
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
                        color: Colors.blue
                      )
                    ),
                    hintText: "Password"
                  ),
                  obscureText: true,
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
        Navigator.pop(context);
      }
      else {
        print("Invalid Credentials.");
        // TODO: handle invalid credentials, maybe display a message notifying the user.
      }
    }
    on ApiConnectionException catch(e) {
      print(e);
      // TODO: display message to user about connection error.
    }
  }
}