import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/JsonSerializeable.dart';

import 'Plant.dart';

class UserPlant implements JsonSerializeable {

  int id;
  int userId;
  String nickname;
  double potVolume;
  double latitude;
  double longitude;
  String imageName;
  DateTime lastWaterDate;
  double distanceToWindow;
  int maxTemp;
  int minTemp;
  int plantId;

  UserPlant({
    this.id,
    this.userId,
    this.nickname,
    this.potVolume,
    this.latitude,
    this.longitude,
    this.imageName,
    this.lastWaterDate,
    this.distanceToWindow,
    this.maxTemp,
    this.minTemp,
    this.plantId
  });

  factory UserPlant.fromJson(Map<String, dynamic> jsonUserPlant) {
    return UserPlant(
      id: jsonUserPlant['id'],
      userId: jsonUserPlant['userId'],
      nickname: jsonUserPlant['nickname'],
      potVolume: jsonUserPlant['potVolume'],
      latitude: jsonUserPlant['lat'],
      longitude: jsonUserPlant['lon'],
      imageName: jsonUserPlant['imageName'],
      lastWaterDate: DateTime.tryParse(jsonUserPlant['lastWaterDate']),
      distanceToWindow: jsonUserPlant['distanceToWindow'],
      maxTemp: jsonUserPlant['maxTemp'],
      minTemp: jsonUserPlant['minTemp'],
      plantId: jsonUserPlant['plantId']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "userId" : userId,
      "nickname" : nickname,
      "potVolume" : potVolume,
      "lat" : latitude,
      "lon" : longitude,
      "imageName" : imageName,
      "lastWaterDate" : lastWaterDate.toIso8601String(),
      "distanceToWindow" : distanceToWindow,
      "maxTemp" : maxTemp,
      "minTemp" : minTemp,
      "plantId" : plantId
    };
  }

  Future<Plant> getPlant() async {
    ApiConnection apiConnection = ApiConnection();

    return await apiConnection.fetchPlant(plantId);
  }

  @override
  String toString() {
  return
'''[ User Plant $id ]
userId:\t\t$userId
nickname:\t\t$nickname
potVolume:\t\t$potVolume
latitude:\t\t$latitude
longitude:\t\t$longitude
imageName:\t\t$imageName
lastWaterDate:\t$lastWaterDate
distanceToWindow:\t$distanceToWindow
maxTemp:\t\t$maxTemp
minTtemp:\t\t$minTemp
plantId:\t\t$plantId
''';
  }

  Plant toPlant() {
    return new Plant(
      id: id,
      name: nickname,
      imageName: imageName,
      waterScale: 2,
      sunScale: 2,
      waterText: 'Plant needs water.',
      sunText: 'Plant needs sun.',
      description: 'This is a plant.'
    );
  }

}