import 'package:shared_preferences/shared_preferences.dart';

Future<bool> userLoggedIn() async {
  /// Returns true if the user is logged in, false otherwise.
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String username = sharedPreferences.getString('username');
  String password = sharedPreferences.getString('password');
  if(username == null || password == null)
    return false;
  return true;
}

Future<String> getLoggedInUser() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String username = sharedPreferences.getString('username');
  String password = sharedPreferences.getString('password');
  if(username == null || password == null)
    return null;
  return username;
}

void userLogin(String username, String password) async {
  /// Logs in the user.
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("username", username);
  sharedPreferences.setString("password", password);
}

void userLogout() async {
  /// Logs out the user.
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove("username");
  sharedPreferences.remove("password");
}