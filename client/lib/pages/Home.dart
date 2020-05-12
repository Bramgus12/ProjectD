import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';

import '../MenuNavigation.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiConnection apiConnection = ApiConnection();

  @override
  Widget build(BuildContext context) {
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
              onPressed: plantsButtonTest,
              child: Text('Plants Test'),
            )
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
    try{
      Plant newPlant = Plant(
        id:0, 
        name: "Post Test Plant", 
        waterScale: 2.3, 
        waterNumber: 3.4, 
        waterText: "Requires water.", 
        sunScale: 4.0, 
        sunNumber: 4.1, 
        sunText: "Requires sunlight.", 
        description: "Plant to test post functionality.",
        optimalTemp: 30
      );

      await apiConnection.postPlant(newPlant);
    } on ApiConnectionException catch(e) {
      print(e);
    }
  }
}
