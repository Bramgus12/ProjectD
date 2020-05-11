import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';

import '../MenuNavigation.dart';

class HomePage extends StatefulWidget {
  ApiConnection apiConnection = ApiConnection();

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    try {
      Plant plant = await widget.apiConnection.fetchPlant(5);
      print(plant);
    } on ApiConnectionException catch(e) {
      print(e);
    }
  }
}
