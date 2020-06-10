import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/pages/CameraPlantDetailScreen.dart';
import 'package:plantexpert/pages/account/Account.dart';
import 'package:plantexpert/widgets/NotificationManager.dart';

import 'pages/Camera.dart';
import 'pages/home/Home.dart';
import 'pages/plant-list.dart';
import 'pages/add-plant.dart';

Future<void> main() async {
  // Load configuration
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    // Running in release mode
    await GlobalConfiguration().loadFromAsset("release");
  } else {
    // Running in debug mode
    await GlobalConfiguration().loadFromAsset("debug");
  }
  initializeNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Plant Expert',
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Color(0xff119543),
      ),
      initialRoute: '/',
      routes: {
        '/plant-detail': (context) => ModalRoute.of(context).settings.arguments,
        '/camera-plant-detail': (context) => CameraPlantDetailScreen(plant: ModalRoute.of(context).settings.arguments),
        '/account' : (context) => Account(),
        '/add-plant' : (context) => AddPlant()
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return RouteWithoutTransition(widget: HomePage(), settings:settings);
          case '/camera':
            return RouteWithoutTransition(widget: Camera(), settings:settings);
          case '/my-plants':
            return RouteWithoutTransition(widget: PlantList(), settings:settings);
          default:
            return null;
        }
      },
    );
  }
}

class RouteWithoutTransition extends PageRouteBuilder {
  final Widget widget;
  final RouteSettings settings;
  RouteWithoutTransition({this.widget, this.settings}) 
    : super(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionDuration: Duration(seconds: 0)
  );
}
