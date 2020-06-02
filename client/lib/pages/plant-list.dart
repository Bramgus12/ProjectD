import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';
import 'package:plantexpert/pages/plant-detail.dart';
import 'package:plantexpert/widgets/stateful-wrapper.dart';

import '../MenuNavigation.dart';

Future<CachedNetworkImage> _getUserPlantImage(UserPlant userPlant) async {
  try {
    CachedNetworkImage img = await PlantenApi.instance.connection.fetchCachedPlantImage(userPlant);
    return img;
  }
  on ApiConnectionException catch (e) {
    print("API image fetch error: " + e.toString());
  }
  on InvalidCredentialsException catch (e) {
    print('Not logged in.');
  }
  on NetworkImageLoadException catch (e) {
    print('There was a problem loading `${userPlant.imageName}`.');
  }

  return null;
}

class PlantList extends StatefulWidget {
  PlantList({Key key}) : super(key: key);

  @override
  _PlantListState createState() => _PlantListState();

}

class _PlantListState extends State<PlantList> {
  String failedFetchingPlants;

  // save the fetched plants so they don't have to get fetched multiple times in a row 
  List<PlantListItem> plantListItems;

  void initState() {
    super.initState();
    _fetchUserPlants();
  }

  Future<void> _reloadUserPlants() async {
    return _fetchUserPlants();
  }

  Future<List<Plant>> _fetchPlants() async {
    return PlantenApi.instance.connection.fetchPlants();
  }

  void _fetchUserPlants() async {
    failedFetchingPlants = null;

    try {
      List<UserPlant> pli = await PlantenApi.instance.connection.fetchUserPlants();
        _fetchPlants().then((listOfPlants) {
          setState(() {
            plantListItems = pli
                        // FIXME: the database contains plants without a nickname
              .where((p) => p.nickname != null)
              .map((p) => PlantListItem(userPlant: p, plantImage: _getUserPlantImage(p), plant: listOfPlants.elementAt(listOfPlants.indexWhere((element) => element.id == p.plantId)),))
              .toList();
        });
      });
    }
    on ApiConnectionException catch (e) {
      setState(() {
        failedFetchingPlants = "Het lijkt er op dat er momenteel geen verbinding met de server gemaakt kan worden, probeer het later nog een keer.";
      });
      print(e);
    }
    on InvalidCredentialsException catch (e) {
      setState(() {
        failedFetchingPlants = "Het lijkt er op dat u niet bent ingelogd, log in of maak een nieuw account aan.";
      });
      print(e);
    }

    //return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuNavigation(),
      bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Mijn Planten Lijst", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: StatefulWrapper(
        onInit: null,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: new RefreshIndicator(
              child: Container(
                width: MediaQuery.of(context).size.width,
                  child:
                  (){
                    if(plantListItems != null){
                      return ListView(
                        children: plantListItems,
                      );
                    }

                    if(failedFetchingPlants != null){
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(failedFetchingPlants),
                        ),
                      );
                    }

                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('Even geduld terwijl wij opzoek zijn naar uw planten. ')
                          ],
                        )
                    );
                  }(),
              ),
              onRefresh: _reloadUserPlants)

        ),
      ),
      floatingActionButton: failedFetchingPlants == null ? FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-plant').then((value) => _fetchUserPlants()),
        backgroundColor: Colors.blue,
        child: Icon(
            Icons.control_point
        ),
      ) : null,
    );
  }
}

class PlantListItem extends StatelessWidget {
  final UserPlant userPlant;
  final Future<CachedNetworkImage> plantImage;
  final Plant plant;


  PlantListItem({this.userPlant, this.plantImage, this.plant});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return StatefulWrapper(
      onInit: () {
      },
      child: DefaultTextStyle(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/plant-detail', arguments: PlantDetail(userPlant, plant, _getUserPlantImage) ),
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