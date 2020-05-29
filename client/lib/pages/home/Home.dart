import 'package:flutter/material.dart';
import 'package:plantexpert/MenuNavigation.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/pages/home/WeatherStationCard.dart';

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              WeatherStationCard()
            ],
          ),
        ),
      ),
    );
  }
  
}
