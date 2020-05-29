import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/ApiConnection.dart';

import '../MenuNavigation.dart';

class PlantList extends StatelessWidget {
  final ApiConnection api = ApiConnection();

  bool failedFetchingPlants = false;
  // save the fetched plants so they don't have to get fetched multiple times in a row 
  List<PlantListItem> plantListItems;

  Future<List<Plant>> _fetchPlants() async {
    try {
      return await api.fetchPlants();
    }
    on ApiConnectionException catch (e) {
      failedFetchingPlants = true;
    }
    on TimeoutException catch (e) {
      failedFetchingPlants = true;
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
          future: _fetchPlants(),
          builder: (BuildContext context, AsyncSnapshot<List<Plant>> snapshot) {
            if (snapshot.hasData && plantListItems == null) {
              plantListItems = snapshot.data.map((p) => PlantListItem(plant: p)).toList();
              plantListItems.forEach((p) {
                p.plant.imageName = 'assets/images/' + p.plant.id.toString() + '.jpg';
              });
            }
            else if (snapshot.hasError || failedFetchingPlants) {
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
  final Plant plant;

  final double _imageWidth = 150.0;
  final double _imageHeight = 150.0;

  PlantListItem({this.plant});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DefaultTextStyle(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/plant-detail', arguments: plant),
        child: Container(
          padding: EdgeInsets.all(10.0),
          height: _imageHeight * 1.2,
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
                child: () {
                  if (plant.imageName != null && plant.imageName.contains('assets/images')) {
                    return Image.asset(
                      plant.imageName,
                      width: _imageWidth,
                      height: _imageHeight,
                    );
                  }
                  else if (plant.imageName == null) {
                    return SizedBox.shrink();
                  }

                  return Image.file(
                    File(plant.imageName),
                    width: _imageWidth,
                    height: _imageHeight,
                  );
                }(),
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
                      Text(plant.name, style: TextStyle(color: Colors.black)),
                      SizedBox(height: 10),

                      Text(
                          'Hoeveelheid zonlicht',
                          style: TextStyle(color: theme.accentColor)
                      ),
                      RatingRow(
                        count: plant.sunScale.toInt(),
                        // TODO: find better icons for sunlight
                        filledIcon: Icons.star,
                        unfilledIcon: Icons.star_border,
                      ),
                      SizedBox(height: 10),

                      Text(
                          'Hoeveelheid water',
                          style: TextStyle(color: theme.accentColor)
                      ),
                      RatingRow(
                          count: plant.waterScale.toInt(),
                          // TODO: find better icons for water
                          filledIcon: Icons.star,
                          unfilledIcon: Icons.star_border,
                      )
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