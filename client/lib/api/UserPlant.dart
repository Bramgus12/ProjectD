class UserPlant {

  int id;
  String deviceId;
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
    this.deviceId,
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
      deviceId: jsonUserPlant['deviceId'],
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
  String toString() {
  return
'''[ User Plant $id ]
deviceId:\t\t$deviceId
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

}