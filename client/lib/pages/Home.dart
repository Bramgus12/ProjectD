import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/UserPlant.dart';

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
    List<UserPlant> userPlants = await widget.apiConnection.fetchUserPlants();
    if(userPlants == null)
      return;
    for (var userPlant in userPlants) {
      print(userPlant);
    }
    // Plant plant = await widget.apiConnection.fetchPlant(5);
    // print(plant);
  }
}
