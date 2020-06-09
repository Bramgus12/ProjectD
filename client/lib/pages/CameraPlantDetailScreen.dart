import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';

import '../MenuNavigation.dart';
import '../pages/plant-list.dart';

class CameraPlantDetailScreen extends StatelessWidget {
  final Plant plant;
  final File plantImage;

  CameraPlantDetailScreen({
    this.plant,
    this.plantImage
  }) : assert(plant != null),
  assert(plantImage != null);

  Widget getIcon( String title, int numberOfStars, String icon) {
    var res = <Widget>[Container(child: Text(title))];
    for (int i = 0; i < numberOfStars; i++) {
      res.add(Container(child: Text(icon)));
    }

    return Container(child: Row(children: res,));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: BottomNavigation(),
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
              Image.asset(
                plant.imageName,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
              SizedBox(height: 20),

              Row(

                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: Column(
                      children: <Widget>[
                        Text('Plantsoort', style: TextStyle(color: theme.accentColor, fontSize: 18),),
                        Text(plant.name),
                      ],
                    ),
                  ),


                  Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: RawMaterialButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-plant',
                              arguments: {
                                "plant": new UserPlant(plantId: plant.id, imageName: plant.imageName),
                                "plantImage": plantImage,
                              }
                            ).then((value) {
                              if(value == "addedPlant")
                                Navigator.pushReplacementNamed(context, "/my-plants");
                            });
                          },
                          elevation: 2.0,
                          fillColor: theme.accentColor,
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                      )
                  )
                ],
              ),
              SizedBox(height: 20),
              Text('Temperatuur', style: TextStyle(color: theme.accentColor, fontSize: 18)),
              Text("De aangeraden temperatuur van de ruimte waar de plant zich bevind ligt rond de ${plant.optimalTemp}℃. "),
              SizedBox(height: 20),
              Text('Water', style: TextStyle(color: theme.accentColor, fontSize: 18)),
                plant.waterScale != null ?
                getIcon("Hoeveelheid water: ",plant.waterScale.toInt(),'💧')
                    : Text("Deze plant heeft geen water nodig"),
              SizedBox(height: 10),
              Text(plant.waterText),
              SizedBox(height: 20),

              Text('Zon', style: TextStyle(color: theme.accentColor, fontSize: 18)),
                plant.sunScale != null ?
                  getIcon("Hoeveelheid zonlicht: ",plant.sunScale.toInt(),'☀')
                    : Text("Deze plant heeft geen zon nodig"),
              SizedBox(height: 10),
              Text(plant.sunText),
              SizedBox(height: 20),


            ],
          ),
        ),
      ),
    );
  }
}
