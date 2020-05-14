import 'package:flutter/material.dart';

import '../MenuNavigation.dart';
import '../Plants.dart';

class PlantList extends StatelessWidget {
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
        child: ListView.builder(
          itemBuilder: (_, index) {
            return PlantListItem(
              plantInfo: User.plants.elementAt(index).toPlantInfo()
            );
          },
          itemCount: User.plants.length,
        )
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
          height: _imageHeight * 1.2,
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
              Expanded(
                flex: 4,
                child: Image.asset(
                  plantInfo.imageName,
                  width: _imageWidth,
                  height: _imageHeight,
                ),
              ),
              // space between image and text
              Expanded(
                flex: 1,
                child: SizedBox(width: 1),
              ),
              Expanded(
                flex: 5,
                child: Column(
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