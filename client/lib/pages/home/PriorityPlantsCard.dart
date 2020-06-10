import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/Utility.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:http/http.dart' as http;

class PriorityPlantsCard extends StatefulWidget {
  @override
  _PriorityPlantsCardState createState() => _PriorityPlantsCardState();
}

enum _Status {
  loading,
  error,
  notLoggedIn,
  noPlantsYet,
  allPlantsFine,
  done
}

class _PriorityPlantsCardState extends State<PriorityPlantsCard> {
  final ApiConnection apiConnection = ApiConnection();
  _Status status = _Status.loading;
  List<UserPlant> userPlants;
  String errorMessage;

  @override
  void initState() {
    super.initState();
    
    getUserPlants();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon( Icons.priority_high ),
            title: Text("Planten berichten"),
            subtitle: Text("Geef deze planten zo snel mogelijk water."),
          ),
          (){
            if (status == _Status.done) {
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: userPlants.length <= 5 ? userPlants.length : 5,
                itemBuilder: (context, index) {
                  // String dateString = DateFormat('d MMMM', 'nl_NL').format(userPlants[index].lastWaterDate );
                  Duration sinceLastWaterTime = DateTime.now().difference(userPlants[index].lastWaterDate);
                  // String sinceLastWaterText = sinceLastWater.
                  return ListTile(
                    leading: Container(
                      width: 30,
                      height: 30,
                      child: Center(child: 
                        Text(
                          (index+1).toString(),
                          style: TextStyle(color: Colors.white),
                        )
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accentColor
                      ),
                    ),
                    title: Text(userPlants[index].nickname),
                    subtitle: Text("${sinceLastWaterTime.inDays} dagen geleden."),
                    trailing: OutlineButton(
                      onPressed: () => updateLastWaterDate(userPlants[index], context), 
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Geef\nWater",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/images/watering-can.png",
                              // Icon credit: https://www.flaticon.com/free-icon/watering-can_3043714?term=garden%20watering%20can&page=1&position=2
                              width: 30,
                            ),
                          ),
                        ],
                      )
                    ),
                  );
                },
              );
            }
            else {
              return Container(
                padding: EdgeInsets.only(top: 15, bottom: 30),
                child: (){
                  switch (status) {
                    case _Status.notLoggedIn:
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text("Je bent niet ingelogd. Log in om planten toe te voegen."),
                          ),
                          RaisedButton(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/account');
                              // The current page needs to be refreshed after returning from the login page,
                              // this will reload all widgets which require the user to be logged in.
                              Navigator.pushReplacementNamed(context, ModalRoute.of(context).settings.name);
                            },
                            child: Text("Inloggen"),
                          ),
                        ],
                      );
                      break;
                    case _Status.noPlantsYet:
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text("Je hebt nog geen planten."),
                          ),
                          RaisedButton(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/add-plant');
                              getUserPlants();
                            },
                            child: Text("Voeg een plant toe"),
                          )
                        ],
                      );
                      break;
                    case _Status.allPlantsFine:
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Icon(
                              Icons.check_circle,
                              color: theme.accentColor,
                            ),
                          ),
                          Text("Al je planten hebben voldoende water.")
                        ],
                      );
                      break;
                    case _Status.error:
                      return Text("Error: $errorMessage");
                      break;
                    default:
                      return CircularProgressIndicator();
                  }
                }(),
              );
            }
          }(),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: getUserPlants, 
                child: Text("Vernieuw"),
                textColor: theme.accentColor,
              )
            ],
          )
        ],
      ),
    );
  }

  void updateLastWaterDate(UserPlant userPlant, BuildContext context) async {
    userPlant.lastWaterDate = DateTime.now();
    http.Response response;
    try {
      response = await apiConnection.putUserPlant(userPlant);
    } on InvalidCredentialsException catch(e) {
      if(!this.mounted)
        return;
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Niet ingelogd.")));
      return;
    } on StatusCodeException catch(e) {
      if(!this.mounted)
        return;
      if (e.reponse.statusCode == 404) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Plant '${userPlant.nickname}' bestaat niet.")));
        setState(() {
          userPlants = List.from(userPlants)..remove(userPlant);
        });
        return;
      }
      print(e);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Server response: ${e.reponse.statusCode}")));
      print(userPlant.toJson());
      return;
    } on ApiConnectionException catch(e) {
      if(!this.mounted)
        return;
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Server error.")));
      print(e);
      return;
    }

    if(!this.mounted)
      return;

    if (response != null && response.statusCode < 300) {
      setState(() {
        userPlants = List.from(userPlants)..remove(userPlant);
        if(userPlants.length == 0){
          status = _Status.allPlantsFine;
        }
      });
    }
  }

  void getUserPlants() async {
    setState(() {
        userPlants = null;
        status = _Status.loading;
    });
    List<UserPlant> allUserPlants;
    List<Plant> allPlants;
    try {
      allUserPlants = await ApiConnection().fetchUserPlants();
      allPlants = await ApiConnection().fetchPlants();
    } on InvalidCredentialsException catch(e) {
      if(!this.mounted)
        return;
      setState(() {
        status = _Status.notLoggedIn;
      });
      return;
    } on StatusCodeException catch(e) {
      if(!this.mounted)
        return;
      if (e.reponse.statusCode == 404) {
        setState(() {
          status = _Status.noPlantsYet;
        });
        return;
      }
      print(e);
      setState(() {
        status = _Status.error;
        errorMessage = "Server error: ${e.reponse.statusCode}";
      });
      return;
    } on ApiConnectionException catch(e) {
      print(e);
      if(!this.mounted)
        return;
      setState(() {
        status = _Status.error;
        errorMessage = "Fout bij verbinden met server.";
      });
      return;
    }

    if(!this.mounted)
      return;

    // Filter list, keep only user plants that haven't received water in the last 24 hours.
    // TODO: Change this to be calculated per plant type with a formula.
    DateTime tooLongWithoutWater = DateTime.now().subtract(Duration(days: 1));


//    List<UserPlant> urgentUserPlants = allUserPlants.where((userPlant) => userPlant.lastWaterDate.millisecondsSinceEpoch < tooLongWithoutWater.millisecondsSinceEpoch ).toList();
    // TODO: Make this generation faster, this will take very long with a large allUserPlants
    List<UserPlant> urgentUserPlants = List<UserPlant>();
      for(var userPlant in allUserPlants) {
        Plant plant = allPlants.firstWhere((plant) => plant.id == userPlant.plantId);
        if(plant != null){
          var nextWaterDate =  await calculateNextWateringDate(plant.waterNumber.toInt(), userPlant.potVolume, userPlant.distanceToWindow.toInt(), plant.waterScale.toInt(), date: userPlant.lastWaterDate);
          if(DateTime.now().difference(nextWaterDate).inDays >= 0)
            urgentUserPlants.add(userPlant);
        }
      }

    if(urgentUserPlants.length == 0) {
      setState(() {
        userPlants = urgentUserPlants;
        status = _Status.allPlantsFine;
      });
      return;
    }
    urgentUserPlants.sort((userPlant1, userPlant2) => userPlant1.lastWaterDate.millisecondsSinceEpoch > userPlant2.lastWaterDate.millisecondsSinceEpoch ? 1 : 0 );

    setState(() {
      userPlants = urgentUserPlants;
      status = _Status.done;
    });
  }
}