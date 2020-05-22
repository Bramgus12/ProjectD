import 'package:plantexpert/api/JsonSerializeable.dart';

import 'UserPlant.dart';

class User implements JsonSerializeable {
  int id;
  String username;
  String password;
  String authority;
  bool enabled;
  String name;
  String email;
  DateTime dateOfBirth;
  String streetName;
  int houseNumber;
  String addition;
  String city;
  String postalCode;

  User({
    this.id,
    this.username,
    this.password,
    this.authority = "ROLE_USER",
    this.enabled = true,
    this.name,
    this.email,
    this.dateOfBirth,
    this.streetName,
    this.houseNumber,
    this.addition,
    this.city,
    this.postalCode,
  });

  factory User.fromJson(Map<String, dynamic> jsonUser) {
    return User(
      id : jsonUser['id'],
      username : jsonUser['user_name'],
      password : jsonUser['password'],
      authority : jsonUser['authority'],
      enabled : jsonUser['enabled'],
      name : jsonUser['name'],
      email : jsonUser['email'],
      dateOfBirth : DateTime.tryParse(jsonUser['dateOfBirth']),
      streetName : jsonUser['streetName'],
      houseNumber : jsonUser['houseNumber'],
      addition : jsonUser['addition'],
      city : jsonUser['city'],
      postalCode : jsonUser['postalCode'],
    );
  }



  static List<UserPlant> plants;

  @override
  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "user_name" : username,
      "password" : password,
      "authority" : authority,
      "enabled" : enabled,
      "name" : name,
      "email" : email,
      "dateOfBirth" : dateOfBirth.toIso8601String(),
      "streetName" : streetName,
      "houseNumber" : houseNumber,
      "addition" : addition,
      "city" : city,
      "postalCode" : postalCode,
    };
  }

  @override
  String toString() {
  return
'''[ User $id ]
id:\t$id
username:\t$username
password:\t$password
authority:\t$authority
enabled:\t$enabled
name:\t$name
email:\t$email
dateOfBirth:\t${dateOfBirth.toIso8601String()}
streetName:\t$streetName
houseNumber:\t$houseNumber
addition:\t$addition
city:\t$city
postalCode:\t$postalCode
''';
  }
}