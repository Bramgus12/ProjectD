import 'package:flutter/material.dart';

import '../MenuNavigation.dart';

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
      body: ListView.builder(
          itemBuilder: (_, index) =>
          PlantItem(
              name: 'Garlic Boi',
              image: 'assets/images/garlic_boi.png',
              temp: index,
          ),
        itemCount: 15,
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
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: temp & 1 == 0 ? Colors.red : Colors.blue,
      child: new Column(
        children: <Widget>[
          Text(name),
          Image.asset(image,
              height: 150.0, width: 150.0)
        ],
      ),
    );
  }
}
