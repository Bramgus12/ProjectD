import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/User.dart';
import 'package:plantexpert/pages/account/AccountValidationFunctions.dart';
import 'package:plantexpert/pages/account/LoginInputField.dart';
import 'package:plantexpert/widgets/StatusBox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterTab extends StatefulWidget {

  final User loggedInUser;

  RegisterTab({this.loggedInUser});

  @override
  _RegisterTabState createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ApiConnection apiConnection = new ApiConnection();

  Status _status = Status.none;
  String _statusMessage = "";

  TextEditingController emailController;
  TextEditingController nameController;
  TextEditingController usernameController;
  TextEditingController passwordController;
  TextEditingController streetController;
  TextEditingController homeNumberController;
  TextEditingController homeAdditionController;
  TextEditingController cityController;
  TextEditingController zipController;
  DateTime birthDay;

  bool birthdayError = false;
  String birthdayErrorMessage = "";

  bool editingExistingUser;

  @override
  void initState() {
    super.initState();  
    editingExistingUser = widget.loggedInUser != null && widget.loggedInUser.id != null;
    emailController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.email: null);
    nameController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.name : null);
    usernameController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.username : null);
    passwordController = new TextEditingController();
    streetController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.streetName : null);
    homeNumberController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.houseNumber.toString() : null);
    homeAdditionController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.addition : null);
    cityController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.city : null);
    zipController = new TextEditingController(text: editingExistingUser ? widget.loggedInUser.postalCode : null);
    birthDay = editingExistingUser ? widget.loggedInUser.dateOfBirth : null;
  }

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
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(20),
        child: (){
          if (widget.loggedInUser == null || widget.loggedInUser.id != null )
            return Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text( widget.loggedInUser == null ? "Registreer" : "Gegevens aanpassen", style: TextStyle(fontSize: 18)),
                  ),
                  LoginInputField(emailController, hintText: "Email", keyboardType: TextInputType.emailAddress, validator: validateEmail, ),
                  LoginInputField(usernameController, hintText: "Gebruikersnaam", validator: validateUsername, ),
                  LoginInputField(passwordController, hintText: "Wachtwoord", obfuscated: true, validator: editingExistingUser ? null : validatePassword, ),
                  LoginInputField(nameController, hintText: "Naam", validator: validateName, ),
                  LoginDatePicker((date) => setState((){ birthDay = date; }), label: "Geboortedatum", validationError: birthdayError, validationMessage: birthdayErrorMessage, initialDate: birthDay, ),
                  LoginInputField(streetController, hintText: "Straat", validator: validateStreet, ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(right: 15), 
                          child: LoginInputField(homeNumberController, hintText: "Huisnummer", keyboardType: TextInputType.number, inputType: int, validator: validateHomeNumber, )
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: LoginInputField(homeAdditionController, hintText: "Toevoeging", )
                      ),
                    ]
                  ),
                  LoginInputField(cityController, hintText: "Stad", validator: validateCity, ),
                  LoginInputField(zipController, hintText: "Postcode", validator: validateZipCode, ),
                  StatusBox(message: _statusMessage, status: _status),
                  RaisedButton(
                    color: theme.accentColor,
                    onPressed: _status == Status.loading ? null : register,
                    child: Text(
                      editingExistingUser ? "Opslaan" : "Registreer",
                      style: theme.accentTextTheme.button
                      )
                  ),
                ],
              ),
            );
          else
            return Center(
              child: Text("Fout bij verbinden met server, account gegevens konden niet worden opgehaald."),
            );
        }()
      ),
    );
  }

  Future<void> register() async {
    setState(() {
      _status = Status.loading;
    });
    // Client side validation
    bool formValid = _formKey.currentState.validate();
    String birthdayValidationMessage = validateBirthday(birthDay);
    setState(() {
      this.birthdayError = birthdayValidationMessage != null;
      this.birthdayErrorMessage = birthdayValidationMessage == null ? "" : birthdayValidationMessage;
    });

    if(!formValid || birthdayValidationMessage != null){
      setState(() {
        _status = Status.none;
      });
      return;
    }
    
    // Create user object from form data
    User user = User(
      id: editingExistingUser ? widget.loggedInUser.id : 0,
      username: usernameController.text,
      password: passwordController.text,
      name: nameController.text,
      email: emailController.text,
      dateOfBirth: birthDay,
      streetName: streetController.text,
      houseNumber: int.parse(homeNumberController.text),
      addition: homeAdditionController.text,
      city: cityController.text,
      postalCode: zipController.text
    );

    if (editingExistingUser)
      user.authority = widget.loggedInUser.authority;

    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      if (editingExistingUser){
        if (user.password == null || user.password == "")
          user.password = sharedPreferences.getString("password");
        if (user.authority == "ROLE_ADMIN")
          await apiConnection.putAdminUser(user);
        else
          await apiConnection.putUser(user);
      }
      else
        await apiConnection.postUser(user);
      
      if(!this.mounted)
        return;

      // Save username and password to shared preferences.
      sharedPreferences.setString("username", user.username);
      if(user.password != null && user.password != "")
        sharedPreferences.setString("password", user.password);

      hideErrorMessage();
      if (editingExistingUser) {
        setState(() {
          _status = Status.message;
          _statusMessage = "Account gegevens zijn bijgewerkt.";
        });
      }
      else
        Navigator.pop(context);

    } on ApiConnectionException catch(e) {
      print(e);
      showErrorMessage("Error connecting to server.");
    } on StatusCodeException catch(e) {
      print(e);

      if(e.reponse.statusCode == 400){
        try{
          Map<String, dynamic> serverResponse = json.decode(e.reponse.body);
          if(serverResponse['message'] == "User already exists.")
            showErrorMessage("De gebruikersnaam '${usernameController.text}' is al in gebruik.");
          else
            showErrorMessage("Server response: ${serverResponse['message']}");
        } catch(jsonException) {
          print(jsonException);
          showErrorMessage("Server response: ${e.reponse.statusCode}");
        }
      }
      else
        showErrorMessage("Server response: ${e.reponse.statusCode}");
    }

  }
}