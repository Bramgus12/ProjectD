import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<User> getLoggedInUser({fromDevice=false}) async {
  /// Returns a user object if logged in, or null if the user is not logged in.
  User user;

  if (fromDevice) {
    // Retrieving the user object from shared preferences will only fill the username field.
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString("username");
    if (username != null) {
      user = User(
        username: username,
      );
      return user;
    }
  }

  try {
    user = await ApiConnection().fetchUser();
  } on InvalidCredentialsException {
    return null;
  } on StatusCodeException catch(e) {
    return null;
  } on ApiConnectionException {
    // Connection to server failed, check if a username and password are saved in shared preferences.
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString("username");
    String password = sharedPreferences.getString("password");
    if(username == null || password == null) {
      return null;
    }
    user = User(
      username: username,
    );
  }

  return user;
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