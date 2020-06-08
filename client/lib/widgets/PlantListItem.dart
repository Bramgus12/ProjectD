import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/Utility.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/pages/plant-detail.dart';
import 'package:plantexpert/pages/plant-list.dart';

class PlantListItem extends StatelessWidget {
  final UserPlant userPlant;
  final Future<CachedNetworkImage> plantImage;
  final Plant plant;


  PlantListItem({this.userPlant, this.plantImage, this.plant});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return DefaultTextStyle(
      child: GestureDetector(
          onTap: () {
            FocusScopeNode focusNode = FocusScope.of(context);

            if (!focusNode.hasPrimaryFocus)
              focusNode.unfocus();

            Navigator.pushNamed(context, '/plant-detail', arguments: PlantDetail(userPlant, plant, getUserPlantImage) );
          },
          child: Container(
            padding: EdgeInsets.all(10.0),
            height: 250,
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1.0,
                      color: theme.accentColor
                  )
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  //child: SizedBox.shrink(),
                  child:
                  Container(
                      height: 200,
                      child: FutureBuilder (
                          future: plantImage,
                          builder: (context, snapshot) {
                            if(snapshot.hasData)
                              return snapshot.data;
                            return Text("");
                          }

                      )
                  ),
                ),
                // space between image and text
                Expanded(
                  flex: 1,
                  child: SizedBox.shrink(),
                ),
                Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            'Naam',
                            style: TextStyle(color: theme.accentColor)
                        ),
                        Text(userPlant.nickname ?? 'leeg', style: TextStyle(color: Colors.black)),
                        SizedBox(height: 10),

                        Text(
                          'Heeft voor het laatst water gekregen op',
                          style: TextStyle(color: theme.accentColor),
                        ),
                        SizedBox(height: 5),
                        Text(
                            userPlant.lastWaterDate != null
                                ? formatDate(userPlant.lastWaterDate)
                                : 'Niet van toepassing',
                            style: TextStyle(color: Colors.black)
                        ),
                        SizedBox(height: 10),

                        Text(
                          'Plantsoort',
                          style: TextStyle(color: theme.accentColor),
                        ),
                        Text(plant.name, style: TextStyle(color: Colors.black)),
                      ],
                    )
                )
              ],
            ),
          )
      ),
      style: TextStyle(
          fontFamily: 'Libre Baskerville',
          color: Colors.white
      ),
    );
  }
}