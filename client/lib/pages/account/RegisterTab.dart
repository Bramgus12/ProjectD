import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/User.dart';
import 'package:plantexpert/pages/account/LoginInputField.dart';

class RegisterTab extends StatefulWidget {
  @override
  _RegisterTabState createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ApiConnection apiConnection = new ApiConnection();

  TextEditingController emailController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController streetController = new TextEditingController();
  TextEditingController homeNumberController = new TextEditingController();
  TextEditingController homeAdditionController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController zipController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Registreer", style: TextStyle(fontSize: 18)),
              ),
              LoginInputField(emailController, hintText: "Email", keyboardType: TextInputType.emailAddress),
              LoginInputField(usernameController, hintText: "Gebruikersnaam"),
              LoginInputField(passwordController, hintText: "Wachtwoord", obfuscated: true),
              LoginDatePicker(),
              LoginInputField(streetController, hintText: "Straat"),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.only(right: 15), 
                      child: LoginInputField(homeNumberController, hintText: "Huisnummer", keyboardType: TextInputType.number, inputType: int)
                    )
                  ),
                  Expanded(
                    flex: 1,
                    child: LoginInputField(homeAdditionController, hintText: "Toevoeging")
                  ),
                ]
              ),
              LoginInputField(cityController, hintText: "Stad"),
              LoginInputField(zipController, hintText: "Postcode"),
              RaisedButton(
                color: theme.accentColor,
                onPressed: register,
                child: Text(
                  "Login",
                  style: theme.accentTextTheme.button
                  )
              ),
            ],
          ),
        )
      ),
    );
  }

  Future<void> register() async {
    // TODO: add validation functions

    // TODO: create plant and post to api
    // User user = User(
    //   username: usernameController.text,
    //   password: passwordController.text,
    //   enabled: true,

    // );
  }
}