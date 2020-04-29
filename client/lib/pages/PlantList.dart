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
          itemBuilder: (_, index) =>
          PlantItem(
              name: plantNames[index % 5],
              image: 'assets/images/' + plantNames[index % 5] + '.jpg',
              waterNeeded: (index % 5) + 1,
              sunlightNeeded: (index % 5) + 1,
          ),
        itemCount: 25,
      )
    );
  }
}

class PlantItem extends StatelessWidget {
  final String name;
  final String image;
  final int sunlightNeeded;
  final int waterNeeded;

  final double _imageWidth = 150.0;
  final double _imageHeight = 150.0;

  PlantItem({this.name, this.image, this.sunlightNeeded, this.waterNeeded});

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
                image,
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
                name,
              ),
            ),
            Positioned(
              left: 200,
              top: 50,
              child: Text(
                'Hoevelheid zonlicht',
                style: TextStyle(
                    color: Colors.grey
                ),
              ),
            ),
            Positioned(
              left: 200,
              top: 70,
              child: RatingRow(
                count: sunlightNeeded,
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
                    count: waterNeeded,
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
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) =>
        Icon(
          index < count ? filledIcon : unfilledIcon,
          color: Colors.white
        )
      )
    );
  }
}