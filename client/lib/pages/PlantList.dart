import 'package:flutter/material.dart';

import '../MenuNavigation.dart';

class PlantList extends StatelessWidget {
  final List<String> plantNames = <String>["croton", "dracaena_lemon_lime", "peace_lily", "pothos", "snake_plant"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuNavigation(),
      bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Plant list", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemBuilder: (_, index) {
            final PlantInfo plantInfo = new PlantInfo(
              name: plantNames[index % 5],
              imageName: 'assets/images/' + plantNames[index % 5] + '.jpg',
              plantDescription: "Omschrijving van de plant.",
              waterDescription: "Informatie over hoeveel water de plant nodig heeft.",
              sunLightDescription: "Informatie over hoeveel zonlicht de plant nodig heeft.",
              waterAmount: (index % 5) + 1,
              sunLightAmount: (index % 5) + 1,
            );
            return PlantListItem(plantInfo: plantInfo);
          },
        itemCount: 25,
      )
    );
  }
}

class PlantInfo {
  final String name;
  final String imageName;
  final String plantDescription;
  final String waterDescription;
  final String sunLightDescription;
  final int waterAmount;
  final int sunLightAmount;

  PlantInfo({
    this.name, this.imageName, this.plantDescription, this.waterDescription,
    this.sunLightDescription, this.waterAmount, this.sunLightAmount
  });
}

class PlantListItem extends StatelessWidget {
  final PlantInfo plantInfo;

  final double _imageWidth = 150.0;
  final double _imageHeight = 150.0;

  PlantListItem({this.plantInfo});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: Colors.white
            )
          ),
          color: Colors.black
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                plantInfo.imageName,
                width: _imageWidth,
                height: _imageHeight,
              ),
            ),
            Positioned(
              left: 200,
              top: 0,
              child: Text(
                'Naam',
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
            ),
            Positioned(
              left: 200,
              top: 20,
              child: Text(
                plantInfo.name,
              ),
            ),
            Positioned(
              left: 200,
              top: 50,
              child: Text(
                'Hoeveelheid zonlicht',
                style: TextStyle(
                    color: Colors.grey
                ),
              ),
            ),
            Positioned(
              left: 200,
              top: 70,
              child: RatingRow(
                count: plantInfo.sunLightAmount,
                filledIcon: Icons.star,
                unfilledIcon: Icons.star_border
              )
            ),
            Positioned(
              left: 200,
              top: 100,
              child: Text(
                'Hoeveelheid water',
                style: TextStyle(
                    color: Colors.grey
                ),
              ),
            ),
            Positioned(
                left: 200,
                top: 120,
                child: RatingRow(
                    count: plantInfo.waterAmount,
                    filledIcon: Icons.star,
                    unfilledIcon: Icons.star_border
                )
            ),
          ],
        ),
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
          color: Colors.white
        )
      )
    );
  }
}