
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Theme.dart';



class MenuNavigation extends StatefulWidget{
  MenuNavigation({Key key}) : super(key: key);

  @override
  _MenuNavigation createState() => _MenuNavigation();

}



class _MenuNavigation extends State<MenuNavigation> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              child: GestureDetector(
                child: ListTile(
                  title: Text( 'Menu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20
                  ),
                ),
                onTap: () => {
                  Navigator.pop(context)
                },
                leading: Icon(Icons.arrow_back),
              ),
            ),

            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/');
            },
            leading: Icon(Icons.home, color: ModalRoute.of(context).settings.name == '/' ? ThemeColors.selected : Colors.black,),
          ),
          ListTile(
            title: Text('Camera'),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/camera');
            },
            leading: Icon(Icons.camera_alt, color: ModalRoute.of(context).settings.name == '/camera' ? ThemeColors.selected : Colors.black,),
          ),
          ListTile(
            title: Text('Mijn planten'),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/my-plants');
            },
            leading: Icon(Icons.featured_play_list, color: ModalRoute.of(context).settings.name == '/my-plants' ? ThemeColors.selected : Colors.black,),

          ),
          ListTile(
            title: Text('Login'),
            onTap: (){
              Navigator.pushNamed(context, '/login');
            },
            leading: Icon(Icons.featured_play_list, color: ModalRoute.of(context).settings.name == '/login' ? ThemeColors.selected : Colors.black,),

          )

        ],
      ),

    );
  }
}


class BottomNavigation extends StatefulWidget{
  BottomNavigation({Key key}) : super(key: key);

  @override
  _BottomNavigation createState() => _BottomNavigation();

}

class _BottomNavigation extends State<BottomNavigation> {
  var indexes = ['/', '/camera', '/my-plants'];



  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          title: Text('Camera'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.featured_play_list),
          title: Text('Mijn planten'),
        ),
      ],
      currentIndex: indexes.indexOf(ModalRoute.of(context).settings.name),
      selectedItemColor: ThemeColors.selected,
      onTap: (int index) => {
        Navigator.pushReplacementNamed(
            context,
            indexes[index],
        )
      },
    );
  }
}
