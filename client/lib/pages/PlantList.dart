import 'package:flutter/material.dart';

import '../MenuNavigation.dart';

class PlantList extends StatelessWidget {
  // plants with images in assets/folder
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
              name: plantNames[index % plantNames.length],
              imageName: 'assets/images/' + plantNames[index % plantNames.length] + '.jpg',
              plantDescription: "Omschrijving van de plant.",
              waterDescription: "Informatie over hoeveel water de plant nodig heeft.",
              sunLightDescription: "Informatie over hoeveel zonlicht de plant nodig heeft.",
              waterAmount: (index % plantNames.length) + 1,
              sunLightAmount: (index % plantNames.length) + 1,
            );
            return PlantListItem(plantInfo: plantInfo);
          },
        itemCount: 16,
      )
    );
  }
}

class PlantInfo {
  final String name;
  // the name of the image in the assets/images folder
  final String imageName;
  // the wireframes show multiple descriptions
  final String plantDescription;
  final String waterDescription;
  final String sunLightDescription;
  // amount 1-5
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
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/plant-detail', arguments: plantInfo),
        child: Container(
          padding: EdgeInsets.all(10.0),
          height: _imageHeight * 1.1,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1.0,
                      color: Colors.white
                  )
              ),
              color: Colors.black
          ),
          child: Row(
            children: <Widget>[
              Image.asset(
                plantInfo.imageName,
                width: _imageWidth,
                height: _imageHeight,
              ),
              SizedBox(
                width: 50,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Naam',
                    style: TextStyle(color: Colors.grey)
                  ),
                  Text(plantInfo.name),
                  SizedBox(height: 10),

                  Text(
                      'Hoeveelheid zonlicht',
                      style: TextStyle(color: Colors.grey)
                  ),
                  RatingRow(
                    count: plantInfo.sunLightAmount,
                    // TODO: find better icons for sunlight
                    filledIcon: Icons.star,
                    unfilledIcon: Icons.star_border,
                  ),
                  SizedBox(height: 10),

                  Text(
                      'Hoeveelheid water',
                      style: TextStyle(color: Colors.grey)
                  ),
                  RatingRow(
                      count: plantInfo.waterAmount,
                      // TODO: find better icons for water
                      filledIcon: Icons.star,
                      unfilledIcon: Icons.star_border,
                  )
                ],
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
          color: Colors.white
        )
      )
    );
  }
}