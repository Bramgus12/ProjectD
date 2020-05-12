import 'package:plantexpert/api/JsonSerializeable.dart';

class Plant implements JsonSerializeable {

  int id;
  String name;
  double waterScale;
  double waterNumber;
  String waterText;
  double sunScale;
  double sunNumber;
  String sunText;
  String description;
  int optimalTemp;

  Plant({
    this.id,
    this.name,
    this.waterScale,
    this.waterNumber,
    this.waterText,
    this.sunScale,
    this.sunNumber,
    this.sunText,
    this.description,
    this.optimalTemp
  });

  factory Plant.fromJson(Map<String, dynamic> jsonPlant) {
    return Plant(
      id: jsonPlant['id'],
      name: jsonPlant['name'],
      waterScale: jsonPlant['waterScale'],
      waterNumber: jsonPlant['waterNumber'],
      waterText: jsonPlant['waterText'],
      sunScale: jsonPlant['sunScale'],
      sunNumber: jsonPlant['sunNumber'],
      sunText: jsonPlant['sunText'],
      description: jsonPlant['description'],
      optimalTemp: jsonPlant['optimumTemp']
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "name" : name,
      "waterScale" : waterScale,
      "waterNumber" : waterNumber,
      "waterText" : waterText,
      "sunScale" : sunScale,
      "sunNumber" : sunNumber,
      "sunText" : sunText,
      "description" : description,
      "optimumTemp" : optimalTemp
    };
  }

  @override
  String toString() {
  return
'''[ Plant $id ]
name:\t$name
waterNumber:\t$waterNumber
waterscale:\t$waterScale
waterText:\t$waterText
sunScale:\t$sunScale
sunNumber:\t$sunNumber
sunText:\t$sunText
description:\t$description
optimalTemp:\t$optimalTemp
''';
  }

}