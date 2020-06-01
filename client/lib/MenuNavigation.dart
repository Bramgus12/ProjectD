
import 'package:flutter/material.dart';

class MenuNavigation extends StatefulWidget{
  MenuNavigation({Key key}) : super(key: key);

  @override
  _MenuNavigation createState() => _MenuNavigation();

}

class _MenuNavigation extends State<MenuNavigation> {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String currentRoute = ModalRoute.of(context).settings.name;
    // theme.accentColor : Colors.black
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: theme.accentColor
      ),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: ListTile(
                  title: Text( 'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
                onTap: () => {
                  Navigator.pop(context)
                },
                leading: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(
                color: theme.accentColor
              ),
            ),
            ListTile(
              selected: currentRoute == '/',
              title: Text('Home'),
              onTap: (){
                Navigator.pushReplacementNamed(context, '/');
              },
              leading: Icon(Icons.home),
            ),
            ListTile(
              selected: currentRoute == '/camera',
              title: Text('Camera'),
              onTap: (){
                Navigator.pushReplacementNamed(context, '/camera');
              },
              leading: Icon(Icons.camera_alt),
            ),
            ListTile(
              selected: currentRoute == '/my-plants',
              title: Text('Mijn planten'),
              onTap: (){
                Navigator.pushReplacementNamed(context, '/my-plants');
              },
              leading: Icon(Icons.featured_play_list),
            ),
            ListTile(
              selected: currentRoute == '/account',
              title: Text('Account'),
              onTap: () async{
                await Navigator.pushNamed(context, '/account');
                Navigator.pushReplacementNamed(context, ModalRoute.of(context).settings.name);
              },
              leading: Icon(Icons.account_box),
            )
          ],
        ),
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
      selectedItemColor: Theme.of(context).accentColor,
      onTap: (int index) => {
        Navigator.pushReplacementNamed(
          context,
          indexes[index],
        )
      },
    );
  }
}
