// File for utility functions that might be usefull anywhere in the code.abstract
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
BehaviorSubject<String>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

// Generate a random string of a given length
String randomString(int length) {
  const possibleCharacters = "abcdefghijklmnopqrstuvwxyz0123456789";
  Random random = Random(DateTime.now().millisecondsSinceEpoch);
  String generatedString = "";
  for (int i = 0; i < length; i++) {
    generatedString += possibleCharacters[random.nextInt(possibleCharacters.length)];
  }
  return generatedString;
}


Future<void> initializeNotifications() async {
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      });
}

/// Schedules a notification that specifies a different icon, sound and vibration pattern
Future<void> scheduleNotification(int seconds, String title, String body,
    String channelName, String channelDesc, ) async {
  var scheduledNotificationDateTime =
  DateTime.now().add(Duration(seconds: seconds));
//
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'nl.bylivingart.plantexpert', channelName, channelDesc,
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(
      DateTime.now().hour + DateTime.now().minute + DateTime.now().second
          + DateTime.now().millisecond,
      title,
      body,
      scheduledNotificationDateTime,
      platformChannelSpecifics);
}