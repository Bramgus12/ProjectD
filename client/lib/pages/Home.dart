import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/WeatherStation.dart';

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
              onPressed: weatherButtonTest,
              child: Text('Weather Station Test'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> weatherButtonTest() async {
    List<WeatherStation> weatherStations = await widget.apiConnection.fetchWeatherStations('Rotterdam');
    if(weatherStations == null)
      return;
    for (var weatherStation in weatherStations) {
      print(weatherStation.code);
    }
  }
}
