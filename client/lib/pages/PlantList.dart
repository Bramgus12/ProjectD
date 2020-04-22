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
              temp: index,
          ),
        itemCount: 25,
      )
    );
  }
}

class PlantItem extends StatelessWidget {
  final String name;
  final String image;
  final int temp;

  PlantItem({this.name, this.image, this.temp});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all()
          ),
          height: 200.0,
        ),
        Positioned(
          left: 225,
          top: 50,
          child: Text("Naam\n" + name)
        ),
        Positioned(
          left: 15,
          top: 25,
          child: Image.asset(
            image,
            width: 150.0,
            height: 150.0,
          )
        )
      ],
    );
  }
}
