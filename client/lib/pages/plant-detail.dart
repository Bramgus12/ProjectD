import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';

import '../MenuNavigation.dart';
import '../pages/plant-list.dart';

class PlantDetail extends StatelessWidget {
  final UserPlant userPlant;

  PlantDetail({this.userPlant})
    : assert(userPlant != null);

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
//              () {
//                if (userPlant.imageName.contains('assets/images')) {
//                  return Image.asset(
//                    userPlant.imageName,
//                    width: 300,
//                    height: 300,
//                  );
//                }
//
//                return Image.file(
//                  File(userPlant.imageName),
//                  width: 300,
//                  height: 300,
//                );
//              }(),
              FutureBuilder(
                future: getUserPlantImage(userPlant),
                builder: (_, AsyncSnapshot<Image> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        width: 300.0,
                        height: 300.0,
                        child: snapshot.data,
                    );
                  }

                  return CircularProgressIndicator(backgroundColor: theme.accentColor);
                },
              ),
              SizedBox(height: 20),

              Text('Naam', style: TextStyle(color: theme.accentColor)),
              Text(userPlant.nickname),
              SizedBox(height: 20),

              Text('Heeft voor het laatst water gekregen op', style: TextStyle(color: theme.accentColor)),
              Text(
                  userPlant.lastWaterDate != null
                      ? formatDate(userPlant.lastWaterDate)
                      : 'Niet van toepassing',
                  style: TextStyle(color: Colors.black)),
              SizedBox(height: 20),
              Text('Plantsoort', style: TextStyle(color: theme.accentColor)),
              FutureBuilder(
                future: getPlantTypeName(userPlant),
                builder: (_, AsyncSnapshot<String> snapshot) {
                  bool loading  = true;
                  String name;

                  if (snapshot.hasData) {
                    name = snapshot.data;
                    loading = false;
                  }

                  return loading
                      ? Center(
                        child: CircularProgressIndicator(backgroundColor: theme.accentColor)
                      )
                      : Text(name);
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
