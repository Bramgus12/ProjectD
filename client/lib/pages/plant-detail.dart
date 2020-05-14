import 'package:flutter/material.dart';
import 'package:plantexpert/api/Plant.dart';

import '../MenuNavigation.dart';
import '../pages/plant-list.dart';

class PlantDetail extends StatelessWidget {
  final Plant plantInfo;

  PlantDetail({this.plantInfo}) 
    : assert(plantInfo != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuNavigation(),
      // FIXME: Failed assertion: line 196 pos 15: '0 <= currentIndex && currentIndex < items.length': is not true.
      // bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Plant detail", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Libre Baskerville',
          color: Colors.white
        ),
        child: Container(
          padding: EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: ListView(
            children: <Widget>[
              Image.asset(
                plantInfo.imageName,
                width: 300,
                height: 300,
              ),
              SizedBox(height: 20),

              Text('Naam', style: TextStyle(color: Colors.grey)),
              Text(plantInfo.name),
              SizedBox(height: 20),

              Row(
                children: <Widget>[
                  Text('Hoeveelheid zonlight    ', style: TextStyle(color: Colors.grey)),
                  RatingRow(
                      count: plantInfo.sunScale.toInt(),
                      filledIcon: Icons.star,
                      unfilledIcon: Icons.star_border
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(plantInfo.sunText),
              SizedBox(height: 20),

              Row(
                children: <Widget>[
                  Text('Hoeveelheid water         ', style: TextStyle(color: Colors.grey)),
                  RatingRow(
                      count: plantInfo.waterScale.toInt(),
                      filledIcon: Icons.star,
                      unfilledIcon: Icons.star_border
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(plantInfo.waterText),
              SizedBox(height: 20),

              Text('Omschrijving', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 5),
              Text(plantInfo.description)
            ],
          ),
        ),
      ),
    );
  }
}
