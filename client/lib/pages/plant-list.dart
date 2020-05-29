import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';

import '../MenuNavigation.dart';



class PlantList extends StatelessWidget {
  bool failedFetchingPlants = false;
  // save the fetched plants so they don't have to get fetched multiple times in a row 
  List<PlantListItem> plantListItems;

  Future<List<UserPlant>> _fetchUserPlants() async {
    try {
      return await PlantenApi.instance.connection.fetchUserPlants();
    }
    on ApiConnectionException catch (e) {
      failedFetchingPlants = true;
      print(e);
    }
    on TimeoutException catch (e) {
      failedFetchingPlants = true;
      print(e);
    }
    on InvalidCredentialsException catch (e) {
      failedFetchingPlants = true;
      print(e);
    }
    on SocketException catch (e) {
      failedFetchingPlants = true;
      print(e);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuNavigation(),
      bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Plant list", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: _fetchUserPlants(),
          builder: (BuildContext context, AsyncSnapshot<List<UserPlant>> snapshot) {
            if (snapshot.hasData && plantListItems == null) {
              List<UserPlant> userPlants = snapshot.data;
              plantListItems = snapshot.data.map((p) => PlantListItem(userPlant: p)).toList();
              // FIXME: the database contains plants without a nickname
              plantListItems = plantListItems.where((item) => item.userPlant.nickname != null).toList();
              //plantListItems = plantListItems.sublist(0, 10);
            }
            else if (snapshot.hasError) {
              print(snapshot.error);
            }

            if (plantListItems == null) {
              if (failedFetchingPlants) {
                return Center(
                  child: Text('Planten konden niet worden opehaald'),
                );
              }
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Planten worden opgehaald')
                    ],
                  )
              );
            }

            return ListView(
              children: plantListItems
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-plant'),
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.control_point
        ),
    ),
    );
  }
}

class PlantListItem extends StatelessWidget {
  final UserPlant userPlant;

  final double _imageWidth = 150.0;
  final double _imageHeight = 150.0;

  PlantListItem({this.userPlant});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DefaultTextStyle(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/plant-detail', arguments: userPlant),
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
                child: FutureBuilder(
                  future: getUserPlantImage(userPlant),
                  builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                    if (snapshot.hasData) {
                      try {
                        Image image = snapshot.data;
                        return image;
                      }
                      on NetworkImageLoadException catch(e) {
                        print('There was a proble fetching ${userPlant.imageName}');
                      }
                    }

                    return Center(
                        child: CircularProgressIndicator(backgroundColor: theme.accentColor)
                    );
                  },
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
                      FutureBuilder(
                        future: getPlantTypeName(userPlant),
                        builder: (_, AsyncSnapshot<String> snapshot) {
                          String name = 'Plantsoort wordt opgehaald';

                          if (snapshot.hasData) {
                            name = snapshot.data;
                          }
                          else if (snapshot.hasError) {
                            name = 'Plantsoort kon niet worden opgehaald.';
                          }

                          return Text(name, style: TextStyle(color: Colors.black));
                        },
                      ),
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

class RatingRow extends StatelessWidget {
  final int count;
  final IconData filledIcon;
  final IconData unfilledIcon;

  RatingRow({this.count, this.filledIcon, this.unfilledIcon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) =>
        Icon(
          index < count ? filledIcon : unfilledIcon,
          color: Colors.black
        )
      )
    );
  }
}