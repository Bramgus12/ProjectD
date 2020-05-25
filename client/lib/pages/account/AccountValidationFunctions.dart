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

String validatePassword(String password) {
  if(password.isEmpty)
    return "Geen wachtwoord ingevuld.";
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