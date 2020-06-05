import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/WeatherStation.dart';
import 'package:url_launcher/url_launcher.dart';

class WeatherStationCard extends StatefulWidget {
  @override
  _WeatherStationCardState createState() => _WeatherStationCardState();
}

class _WeatherStationCardState extends State<WeatherStationCard> {
  final ApiConnection apiConnection = ApiConnection();
  _Status status = _Status.loading;
  String errorMessage;
  _LocationStatus locationStatus = _LocationStatus.unknown;
  WeatherStation weatherStation;

  static LocationData lastLocationData; // Static variable used to cache last location for performance improvements

  @override
  void initState() {
    super.initState();

    getWeatherStation();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon( Icons.cloud ),
            title: Text("Weer"),
            subtitle: (){
              if(status == _Status.error)
                return Text(errorMessage);
              else if(status == _Status.loading)
                return Text("Weer data wordt opgehaald...");
              else if (weatherStation != null) {
                return Text("Regio ${weatherStation.region}");
              }
              else {
                return Container();
              }
            }(),
          ),
          (){
            if (status == _Status.loading || locationStatus == _LocationStatus.unknown)
              return CircularProgressIndicator();
            else if(weatherStation != null)
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "${weatherStation.temperature} °C",
                          style: theme.textTheme.headline3,
                        ),
                        Image.network(weatherStation.icoonactueel.value)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(weatherStation.icoonactueel.zin),
                  ),
                  Center(
                    child:
                      GestureDetector(
                        onTap: () { launch("https://www.buienradar.nl/"); },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Weer gegevens van Buienradar.\n",
                                style: theme.textTheme.caption
                              ),
                              TextSpan(
                                text: "www.buienradar.nl",
                                style: theme.textTheme.caption.copyWith(color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      )
                  )
                ],
              );
            else
              return Container();
          }(),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: () => getWeatherStation(promptUser: true, userRefresh: true), 
                child: Text("Vernieuw"),
                textColor: theme.accentColor,
              ),
              Visibility(
                visible: locationStatus == _LocationStatus.disabled || locationStatus == _LocationStatus.denied,
                child: FlatButton(
                  onPressed: () => getWeatherStation(promptUser: true), 
                  child: Text("Inschakelen"),
                  textColor: theme.accentColor
                )
              )
            ],
          )
        ],
      )
    );
  }

  Future<_LocationStatus> enableLocation(bool promptUser) async {

    Location location = new Location();
    // Check if location service is enabled
    bool locationServiceEnabled = await location.serviceEnabled();
    if(!locationServiceEnabled) {
      if(promptUser)
        locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled){
        setState(() {
          locationStatus = _LocationStatus.disabled;
          errorMessage = "Locatie service is uitgeschakeld.\n\nInformatie over het weer voor de huidige locatie kan niet worden opgehaald.";
          status = _Status.error;
        });
        return locationStatus;
      }
    }

    // Check if location permission is granted
    PermissionStatus locationPermission = await location.hasPermission();
    if (locationPermission != PermissionStatus.granted) {
      if(promptUser)
        locationPermission = await location.requestPermission();
      if (locationPermission != PermissionStatus.granted) {
        setState(() {
          locationStatus = _LocationStatus.denied;
          errorMessage = "De app heeft geen toestemming om de locatie service te gebruiken.\n\nInformatie over het weer voor de huidige locatie kan niet worden opgehaald.";
          status = _Status.error;
        });
        return locationStatus;
      }
    }

    // Location service is enabled and permission is granted
    setState(() {
      locationStatus = _LocationStatus.working;
    });
    return locationStatus;
  }

  void getWeatherStation({bool promptUser=false, bool userRefresh=false}) async {
    /// Retrieves the weatherstation closest to the current location and updated the weatherStation property
    setState(() {
      status = _Status.loading;
    });
    weatherStation = null;

    _LocationStatus currentLocationStatus = await enableLocation(promptUser);
    if( currentLocationStatus != _LocationStatus.working ) {
      return;
    }

    // Get the location
    if ( userRefresh || lastLocationData == null || lastLocationData.time < DateTime.now().millisecondsSinceEpoch - 300000 ) {
      // only retrieve a new location if it hasn't been retrieved in the last 5 minutes, or if the user presses the refresh button.
      Location location = new Location();
      lastLocationData = await location.getLocation();
    }
    
    // Fetch closest weather station from api
    try {
      weatherStation = await apiConnection.fetchWeatherStation(lastLocationData.latitude, lastLocationData.longitude);
      if(!this.mounted)
        return;

      setState(() {
        status = _Status.done;
      });
    } on ApiConnectionException catch(e) {
      print(e);
      setState(() {
        errorMessage = "Fout bij verbinden met de server.";
        status = _Status.error;
      });
    } on StatusCodeException catch(e) {
      print(e);
      setState(() {
        errorMessage = "Server geeft foutmelding: ${e.reponse.statusCode}";
        status = _Status.error;
      });
    }
  }
}

enum _Status {
  loading,
  error,
  done
}

enum _LocationStatus {
  unknown,
  disabled,
  denied,
  working
}
