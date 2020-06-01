import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
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
                    trailing: OutlineButton(onPressed: () => updateLastWaterDate(userPlants[index], context), child: Text("Update")),
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
                            onPressed: () => Navigator.pushNamed(context, '/login'),
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
                            onPressed: null, // TODO: add route to add plant page
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
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Niet ingelogd.")));
      return;
    } on StatusCodeException catch(e) {
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
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Server error.")));
      print(e);
      return;
    }

    if (response != null && response.statusCode < 300) {
      setState(() {
        userPlants = List.from(userPlants)..remove(userPlant);
      });
    }
  }

  void getUserPlants() async {
    setState(() {
        userPlants = null;
        status = _Status.loading;
    });
    List<UserPlant> allUserPlants;
    try {
      allUserPlants = await ApiConnection().fetchUserPlants();
    } on InvalidCredentialsException catch(e) {
      setState(() {
        status = _Status.notLoggedIn;
      });
      return;
    } on StatusCodeException catch(e) {
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
      setState(() {
        status = _Status.error;
        errorMessage = "Server connection error.";
      });
      return;
    }

    // Filter list, keep only user plants that haven't received water in the last 24 hours.
    // This will later need to be calculated per plant type with a formula.
    DateTime tooLongWithoutWater = DateTime.now().subtract(Duration(days: 1));
    List<UserPlant> urgentUserPlants = allUserPlants.where((userPlant) => userPlant.lastWaterDate.millisecondsSinceEpoch < tooLongWithoutWater.millisecondsSinceEpoch ).toList();

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