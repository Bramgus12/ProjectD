import 'package:flutter/material.dart';

import '../MenuNavigation.dart';
import '../Plants.dart';

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
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemBuilder: (_, index) {
            final PlantInfo plantInfo = new PlantInfo(
              name: plantNames[index % plantNames.length],
              imageName: 'assets/images/' + plantNames[index % plantNames.length] + '.jpg',
              plantDescription: "Omschrijving van de plant.",
              waterDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque varius dui venenatis eros dictum, sit amet fringilla lorem iaculis. Vivamus porttitor lacus ante, nec rhoncus nisi vestibulum ut. Nam interdum, purus condimentum sagittis vulputate, libero tortor viverra velit, et mollis leo ipsum quis tellus. Aenean tristique felis sapien, sed faucibus augue fringilla at. Nunc efficitur nibh id mollis mattis. Donec neque risus, molestie eget urna a, pellentesque feugiat magna. Curabitur facilisis id libero nec aliquam. Ut sit amet sollicitudin sapien, iaculis condimentum nulla. Donec consequat placerat venenatis.",
              sunLightDescription: "Informatie over hoeveel zonlicht de plant nodig heeft.",
              waterAmount: (index % plantNames.length) + 1,
              sunLightAmount: (index % plantNames.length) + 1,
            );
            return PlantListItem(plantInfo: plantInfo);
          },
          itemCount: 5,
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