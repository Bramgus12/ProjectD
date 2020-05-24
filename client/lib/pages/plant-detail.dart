import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plantexpert/api/Plant.dart';

import '../MenuNavigation.dart';
import '../pages/plant-list.dart';

class PlantDetail extends StatelessWidget {
  final Plant plant;

  PlantDetail({this.plant})
    : assert(plant != null);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

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
          color: Colors.black
        ),
        child: Container(
          padding: EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              () {
                if (plant.imageName.contains('assets/images')) {
                  return Image.asset(
                    plant.imageName,
                    width: 300,
                    height: 300,
                  );
                }

                return Image.file(
                  File(plant.imageName),
                  width: 300,
                  height: 300,
                );
              }(),
              SizedBox(height: 20),

              Text('Naam', style: TextStyle(color: theme.accentColor)),
              Text(plant.name),
              SizedBox(height: 20),

              Row(
                children: <Widget>[
                  Text('Hoeveelheid zonlight    ', style: TextStyle(color: theme.accentColor)),
                  RatingRow(
                      count: plant.sunScale.toInt(),
                      filledIcon: Icons.star,
                      unfilledIcon: Icons.star_border
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(plant.sunText),
              SizedBox(height: 20),

              Row(
                children: <Widget>[
                  Text('Hoeveelheid water         ', style: TextStyle(color: theme.accentColor)),
                  RatingRow(
                      count: plant.waterScale.toInt(),
                      filledIcon: Icons.star,
                      unfilledIcon: Icons.star_border
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(plant.waterText),
              SizedBox(height: 20),

              Text('Omschrijving', style: TextStyle(color: theme.accentColor)),
              SizedBox(height: 5),
              Text(plant.description)
            ],
          ),
        ),
      ),
    );
  }
}
