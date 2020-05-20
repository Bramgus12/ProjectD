import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:quiver/collection.dart';
import '../MenuNavigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  File imageFile;
  List _recognitions;
  bool _busy = false;
  File predictionResultPlantImage;
  final List<String> plantNames = <String>[
    "croton",
    "dracaena_lemon_lime",
    "peace_lily",
    "pothos",
    "snake_plant"
  ];

  openGallery(BuildContext context) async {
    this.setState(() {
      _recognitions = null;
    });
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      predictImage(img);
      this.setState(() {
        imageFile = img;
      });
    }
    Navigator.of(context).pop();
  }

  openCamera(BuildContext context) async {
    this.setState(() {
      _recognitions = null;
    });
    var img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      predictImage(img);
      this.setState(() {
        imageFile = img;
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> imageSourceChoiceDialog(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Make a choice!"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Gallary"),
                    onTap: () {
                      openGallery(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Text("Camera"),
                    onTap: () {
                      openCamera(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void toPlantDetail(String plantName, double waterAmount, double sunAmount) {
    Navigator.pushNamed(context, '/plant-detail',
        arguments: new Plant(
          id: 0,
          name: plantName,
//            imageName: 'assets/images/' +
//                _recognitions
//                    .map((res) {
//                      return res["index"];
//                    })
//                    .toList()[0]
//                    .toString() +
//                '.jpg',
          imageName: imageFile.path,
          description: "Omschrijving van de plant.",
          waterText: "Informatie over hoeveel water de plant nodig heeft.",
          sunText: "Informatie over hoeveel zonlicht de plant nodig heeft.",
          waterScale: waterAmount,
          sunScale: sunAmount,
        ));
  }

  Widget selectedImageView() {
    if (imageFile == null) {
      return Text(" ");
    } else {
      return Image.file(
        imageFile,
        width: 150,
        height: 150,
      );
    }
  }

  Widget predictionView() {
    if (_recognitions == null) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                  padding: EdgeInsets.all(16.0),
                  height: 150,
                  child: Text(
                      "Select a plant image from your gallery or take a picture \nof a plant by clicking the floating button at the bottom \nleft of your screen.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20))),
            ),
          ]);
    } else {
      var plantNumber = _recognitions.map((res) {
        return res["index"];
      }).toList()[0];
      String plantName;
      double waterAmount;
      double sunAmount;

      if (plantNumber == 0) {
        plantName = "croton";
        waterAmount = 4;
        sunAmount = 2;
      } else if (plantNumber == 1) {
        plantName = "dracaena lemon lime";
        sunAmount = 3;
        waterAmount = 2;
      } else if (plantNumber == 2) {
        plantName = "peace lily";
        waterAmount = 3;
        sunAmount = 3;
      } else if (plantNumber == 3) {
        plantName = "pothos";
        waterAmount = 3;
        sunAmount = 2;
      } else if (plantNumber == 4) {
        plantName = "snake plant";
        waterAmount = 1;
        sunAmount = 5;
      } else if (plantNumber == 5) {
        plantName = "Name:";
        waterAmount = 0;
        sunAmount = 0;
      }
      return GestureDetector(
          onTap: () => toPlantDetail(plantName, waterAmount, sunAmount),
          child: Container(
              child: predictionCard(_recognitions.map((res) {
            return res["index"];
          }).toList()[0])));
    }
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
          model: "assets/m0_0.81.tflite", labels: "assets/label.txt");
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future plantModel(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 0.4526901778594428,
      imageStd: 0.3290300460265408,
    );
    print("----------------------------------------------------");
    print(recognitions);
    setState(() {
      _recognitions = recognitions;
    });
  }

  Future plantModelWithBinary(img.Image image) async {
    Uint8List imageToByteListFloat32(
        img.Image image, int inputSize, double mean, double std) {
      var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
      var buffer = Float32List.view(convertedBytes.buffer);
      int pixelIndex = 0;
      for (var i = 0; i < inputSize; i++) {
        for (var j = 0; j < inputSize; j++) {
          var pixel = image.getPixel(j, i);
          buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
          buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
          buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
        }
      }

      return convertedBytes.buffer.asUint8List();
    }

    var recognitions = await Tflite.runModelOnBinary(
        binary: imageToByteListFloat32(
            image, 200, 0.4526901778594428, 0.3290300460265408), // required
        numResults: 6, // defaults to 5
        threshold: 0.05, // defaults to 0.1
        asynch: true // defaults to true
        );
    print("----------------------------------------------------");
    print(recognitions);
    setState(() {
      _recognitions = recognitions;
    });
  }

  Future predictImage(File image) async {
    await plantModel(image);
  }

  Widget getIcon(String title, int numberOfStars, String icon) {
    var res = <Widget>[Container(child: Text(title))];
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < numberOfStars; i++) {
      res.add(Container(child: Text(icon)));
    }

    return Container(
        child: Row(
      children: res,
    ));
  }

  Widget getData(int plantNumber) {
    String plantName;
    int waterAmount;
    int sunAmount;
    if (plantNumber == 0) {
      plantName = "croton";
      waterAmount = 4;
      sunAmount = 2;
    } else if (plantNumber == 1) {
      plantName = "dracaena lemon lime";
      waterAmount = 2;
      sunAmount = 4;
    } else if (plantNumber == 2) {
      plantName = "peace lily";
      waterAmount = 3;
      sunAmount = 3;
    } else if (plantNumber == 3) {
      plantName = "pothos";
      waterAmount = 3;
      sunAmount = 2;
    } else if (plantNumber == 4) {
      plantName = "snake plant";
      waterAmount = 1;
      sunAmount = 5;
    } else if (plantNumber == 5) {
      plantName = "Name:";
      waterAmount = 0;
      sunAmount = 0;
    }
    return plantCardDetails(plantName, waterAmount, sunAmount);
  }

  Widget plantCardDetails(String plantName, int waterAmount, int sunAmount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 9.0),
          child: Container(
              child: Text(
            plantName,
            style: TextStyle(
                color: Color(0xffe6020a),
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Confidence : " +
              _recognitions
                  .map((res) {
                    return res["confidence"];
                  })
                  .toList()[0]
                  .toString()),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: getIcon("Hoeveelheid water: ", waterAmount, '💧'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: getIcon("Hoeveelheid zonlicht: ", sunAmount, '☀'),
        ),
      ],
    );
  }

  Widget predictionCard(int plantNumber) {
    var res = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            child: getData(plantNumber),
          ),
        ),
        Container(
          width: 250,
          height: 180,
          child: ClipRRect(
            borderRadius: new BorderRadius.circular(24.0),
            child: Image(
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
              image: AssetImage(
                  'assets/images/' + plantNumber.toString() + '.jpg'),
            ),
          ),
        )
      ],
    );
    return res;
  }

  @override
  void initState() {
    super.initState();

    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: MenuNavigation(),
      bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title:
            Text("Camera", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(12.0), child: selectedImageView()),
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Predictions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              )),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              child: FittedBox(
                child: Material(
                  color: Colors.white,
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(24.0),
                  shadowColor: Colors.grey,
                  child: predictionView(),
                ),
              ),
            ),
          ),
        ],
      ),

//
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          imageSourceChoiceDialog(context);
        },
        child: Icon(
          Icons.image,
          color: Colors.white,
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
