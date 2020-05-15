import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:plantexpert/pages/Login.dart';

import 'pages/Camera.dart';
import 'pages/Home.dart';
import 'pages/plant-list.dart';
import 'pages/plant-detail.dart';
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Expert',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/plant-detail': (context) => PlantDetail(plantInfo: ModalRoute.of(context).settings.arguments),
        '/login' : (context) => Login(),
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return SlideRightRoute(widget: HomePage(), settings:settings);
          case '/camera':
            return SlideRightRoute(widget: Camera(), settings:settings);
          case '/my-plants':
            return SlideRightRoute(widget: PlantList(), settings:settings);
          case '/add-plant':
            return SlideRightRoute(widget: AddPlant(), settings:settings);
          default:
            return null;
        }
      },
    );
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget widget;
  final RouteSettings settings;
  SlideRightRoute({this.widget, this.settings})
      : super(
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {
      return new SlideTransition(
        position: new Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
    settings: settings
  );
}
