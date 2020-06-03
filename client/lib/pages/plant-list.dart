import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';
import 'package:plantexpert/widgets/PlantListItem.dart';
import 'package:plantexpert/widgets/stateful-wrapper.dart';

import '../MenuNavigation.dart';

Future<CachedNetworkImage> getUserPlantImage(UserPlant userPlant) async {
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
              .map((p) => PlantListItem(userPlant: p, plantImage: getUserPlantImage(p), plant: listOfPlants.elementAt(listOfPlants.indexWhere((element) => element.id == p.plantId)),))
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