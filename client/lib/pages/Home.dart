import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';

import '../MenuNavigation.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiConnection apiConnection = ApiConnection();
  Image userPlantImageWidget;

  @override
  Widget build(BuildContext context) {
    int plantTimer = 5;
    return Scaffold(
      drawer: MenuNavigation(),
      bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text('Plant Expert', style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () =>  scheduleNotification(5, "Plant $plantTimer heeft water nodig",
                  "Het is al weer een paar dagen geleden en de plant heeft wel weer zin in wat water, geef hem snel water!",
              "Water geven", "Notificaties voor het geven van water. "),
              child: Text('Schedule notifcation for $plantTimer seconds from now. '),
            ),
            RaisedButton(
              onPressed: plantsButtonTest,
              child: Text('UserPlant Image Test'),
            ),
            (){
              if(userPlantImageWidget == null){
                return Container();
              }
              else{
                return userPlantImageWidget;
              }
            }()
          ],
        ),
      ),
    );
  }

  Future<void> plantsButtonTest() async {
    // List<Plant> plants = await widget.apiConnection.fetchPlants();
    // for (var plant in plants) {
    //   print(plant);
    // }
    // try {
    //   Plant plant = await widget.apiConnection.fetchPlant(5);
    //   print(plant);
    // } on ApiConnectionException catch(e) {
    //   print(e);
    // }
    // try{
    //   UserPlant newUserPlant = UserPlant(
    //     userId: 1337,
    //     distanceToWindow: 5.5,
    //     id: 0,
    //     imageName: "testPostPlant.jpg",
    //     lastWaterDate: DateTime.parse("2020-05-12T20:32:47.389Z"),
    //     latitude: 53.534676,
    //     longitude: 6.506173,
    //     maxTemp: 2,
    //     minTemp: 4,
    //     nickname: "Pedro's Post Test Plant",
    //     plantId: 5,
    //     potVolume: 3.2
    //   );

    //   await apiConnection.postUserPlant(newUserPlant);

    //   print("Successfull UserPlant post");
    // } on ApiConnectionException catch(e) {
    //   print(e);
    // } on InvalidCredentialsException catch(e) {
    //   print(e);
    // }

    try {
      print("Sending request");
      // List<Plant> plants = await apiConnection.fetchPlants();
      List<UserPlant> userPlants = await apiConnection.fetchUserPlants();
      for (UserPlant userPlant in userPlants) {
        if(userPlant.id == 22) {
          print(userPlant);
          Image fetchedUserPlantImage = await apiConnection.fetchUserPlantImage(userPlant);
          setState(() {
            userPlantImageWidget = fetchedUserPlantImage;
          });
        }
      }
      print("Request done");
    } on StatusCodeException catch(e) {
      // handle exception
      print(e);
    }
    on InvalidCredentialsException catch(e) {
      // handle exception
      print(e);
    } catch(e) {
      // handle exception
      print(e);
    } 
  }
}
