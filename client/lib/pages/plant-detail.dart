import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';

import '../MenuNavigation.dart';
import '../pages/plant-list.dart';

class PlantDetail extends StatelessWidget {
  final UserPlant userPlant;
  final Plant plant;
  final Function getUserPlantImage;

  PlantDetail(
    this.userPlant,
    this.plant,
    this.getUserPlantImage
  ) : assert(userPlant != null),
        assert(plant != null),
        assert(getUserPlantImage != null);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    print(userPlant);
    print(plant);
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
              FutureBuilder(
                future: getUserPlantImage(userPlant),
                builder: (builder, snapshot) {
                  if (snapshot.hasData) {
                    CachedNetworkImage img = snapshot.data;
                    return Container(
                      height: img.height != null && MediaQuery.of(context).size.height * 0.4 > img.height ? img.height : MediaQuery.of(context).size.height * 0.4,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: snapshot.data,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: 20),

              Row(

                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: Column(
                      children: <Widget>[
                        Text('Bijnaam', style: TextStyle(color: theme.accentColor, fontSize: 18),),
                        Text(userPlant.nickname),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),


                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: RawMaterialButton(
                        onPressed: () { },
                        elevation: 2.0,
                        fillColor: theme.accentColor,
                        child: Icon(
                          Icons.edit,
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

              Text('Water gegeven op', style: TextStyle(color: theme.accentColor, fontSize: 18)),
              Text(
                  userPlant.lastWaterDate != null
                      ? formatDate(userPlant.lastWaterDate)
                      : 'Niet van toepassing',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 20),
              Text('Plantsoort', style: TextStyle(color: theme.accentColor, fontSize: 18)),
              Text(plant.name),
              SizedBox(height: 20),
              Text('Temperatuur', style: TextStyle(color: theme.accentColor, fontSize: 18)),
              Text("De temperatuur van de ruimte waar de plant zich bevind liggen tussen de ${userPlant.minTemp}℃ en de ${userPlant.maxTemp}℃."),
              Text("De aangeraden temperatuur van de ruimte waar de plant zich bevind ligt rond de ${plant.optimalTemp}℃. "),
              SizedBox(height: 20),
              Text('Plant pot', style: TextStyle(color: theme.accentColor, fontSize: 18)),
              Text("De inhoud van de pot waar de plant in zit is ${userPlant.potVolume} liter."),
              SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
