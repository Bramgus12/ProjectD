String validateEmail(String email) {
  if(email.isEmpty) {
    return "Geen email ingevuld.";
  }
  else if(!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(email)){
    // regex source: https://stackoverflow.com/a/16888554
    return "Ongeldig email address.";
  }
  return null;
}

String validateUsername(String username) {
  if(username.isEmpty)
    return "Geen gebruikersnaam ingevuld.";
  return null;
}

String validateName(String username) {
  if(username.isEmpty)
    return "Geen naam ingevuld.";
  return null;
}

String validatePassword(String password, {bool canBeEmpty=false, bool simple=false}) {
  // Password can be empty if editing existing user
  if(canBeEmpty && password.isEmpty)
    return null;

  if(password.isEmpty)
    return "Geen wachtwoord ingevuld.";
  else if(simple) {
    return null;
  }

  // Check if password contains valid characters,
  // only show requirements that haven't been met yet.
  String errorMessage = "";
  if(password.length < 8)
    errorMessage += "\n• minimaal 8 tekens.";
  if(password.length > 64)
    errorMessage += "\n• maximaal 64 tekens.";
  if(!RegExp(r"[a-z]").hasMatch(password))
    errorMessage += "\n• minimaal 1 kleine letter";
  if(!RegExp(r"[A-Z]").hasMatch(password))
    errorMessage += "\n• minimaal 1 hoofdletter";
  if(!RegExp(r"\d").hasMatch(password))
    errorMessage += "\n• minimaal 1 getal";
  if(!RegExp(r"[@#$%!;]").hasMatch(password))
    errorMessage += "\n• minimaal 1 speciaal teken (@#\$%!;)";
  if(RegExp(r":").hasMatch(password))
    errorMessage += "\n• mag geen : bevatten";
  
  if(errorMessage.length > 0)
    return "Wachtwoord voldoet niet aan alle eisen:" + errorMessage;
  return null;
}

String validateBirthday(DateTime birthday) {
  if(birthday == null) 
    return "Geen geboortedatum gekozen.";
  return null;
}

String validateStreet(String street) {
  if(street.isEmpty)
    return "Geen straatnaam ingevuld.";
  return null;
}

String validateHomeNumber(String homeNumber) {
  if(homeNumber.isEmpty)
    return "Geen huisnummer ingevuld.";
  else if(int.tryParse(homeNumber) == null)
    return "Huisnummer moet een nummer zijn.";
  return null;
}

String validateCity(String city) {
  if(city.isEmpty)
    return "Geen stad ingevuld.";
  return null;
}

String validateZipCode(String zipCode) {
  if(zipCode.isEmpty)
    return "Geen postcode ingevuld.";
  else if(!RegExp(r"^[1-9][0-9]{3}[\s]?[A-Za-z]{2}$").hasMatch(zipCode))
    // regex source: https://murani.nl/blog/2015-09-28/nederlandse-reguliere-expressies/
    return "Ongeldige postcode.";
  return null;
}