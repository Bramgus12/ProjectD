class User {
  static List<UserPlant> plants;
}

class PlantInfo {
  final String name;
  // the name of the image in the assets/images folder
  final String imageName;
  // the wireframes show multiple descriptions
  final String plantDescription;
  final String waterDescription;
  final String sunLightDescription;
  // amount 1-5
  final int waterAmount;
  final int sunLightAmount;

  PlantInfo({
    this.name, this.imageName, this.plantDescription, this.waterDescription,
    this.sunLightDescription, this.waterAmount, this.sunLightAmount
  });
}

class UserPlant {
  String imageName;
  String nickName;
  int volumeInMM;
  DateTime lastTimeWater;
  int sunLightAmount;
  int minTemp;
  int maxTemp;

  @override
  String toString() {
    return '''
    {
        nickname: "$nickName",
        volume: $volumeInMM,
        lastTimeWater: "$lastTimeWater",
        sunLightNeeded: $sunLightAmount,
        minTempLocation: $maxTemp,
        maxTempLocation: $maxTemp
    }
    ''';
  }

  PlantInfo toPlantInfo() {
    return new PlantInfo(
      name: nickName,
      imageName: imageName,
      plantDescription: '',
      sunLightDescription: '',
      waterDescription: '',
      sunLightAmount: sunLightAmount,
      // ?
      waterAmount: 2
    );
  }
}