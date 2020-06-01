import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getLoggedInUser() async {
  /// Returns the username logged in user, or null if the user is not logged in.
  String username;
  try {
    User user = await ApiConnection().fetchUser();
    username = user.username;
  } on InvalidCredentialsException {
    return null;
  } on StatusCodeException catch(e) {
    return null;
  } on ApiConnectionException {
    // Connection to server failed, check if a username and password are saved in shared preferences.
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString("username");
    String password = sharedPreferences.getString("password");
    if(username == null || password == null) {
      return null;
    }
  }
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