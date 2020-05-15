import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/MenuNavigation.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:localstorage/localstorage.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera>
    with WidgetsBindingObserver{

  CameraController controller;
  String imagePath;

  File imageFile;
  List _recognitions;
  bool _busy = false;
  int activeCameraItem = 0;
  bool storageReady = false;
  final LocalStorage storage = new LocalStorage('by_living_art.json');
  File predictionResultPlantImage;
  final List<String> plantNames = <String>["croton", "dracaena_lemon_lime", "peace_lily", "pothos", "snake_plant"];
  List<CameraDescription> cameras = [];
  
  var plnts = [
    {"plantName":"croton", "waterAmount": 4.0, "sunAmount": 2.0},
    {"plantName":"dracaena lemon lime", "waterAmount": 2.0, "sunAmount": 0.0},
    {"plantName":"peace lily", "waterAmount": 3.0, "sunAmount": 3.0},
    {"plantName":"pothos", "waterAmount": 3.0, "sunAmount": 2.0},
    {"plantName":"snake plant", "waterAmount": 1.0, "sunAmount": 5.0},
  ];

  @override
  void initState() {
    super.initState();


  openGallery( BuildContext context) async {
    this.setState(() {
      _recognitions = null;
    });
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(img != null){
      predictImage(img);
      this.setState((){
        imageFile = img;
      });
    }
    Navigator.of(context).pop();

  }
  openCamera(BuildContext context) async{
    this.setState(() {
      _recognitions = null;
    });
    var img = await ImagePicker.pickImage(source: ImageSource.camera);
    if(img != null){
      predictImage(img);
      this.setState((){
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
                    onTap: (){
                      openGallery(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0),),
                  GestureDetector(
                    child: Text("Camera"),
                    onTap: (){
                      openCamera(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }


  Widget selectedImageView(){
    if(imageFile == null){
      return Text(" ");

    }else{
      return  Image.file(imageFile,width: 150, height: 150,);
    }
  }
  Widget predictionView(){

    if(_recognitions == null){
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(

              padding: EdgeInsets.all(16.0),
              height: 150,
              child: Text("Select a plant image from your gallery or take a picture \nof a plant by clicking the floating button at the bottom \nleft of your screen.", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
            ),
          ),]);
    }else{
      var plantNumber = _recognitions.map((res){ return res["index"];}).toList()[0];
      String plantName = plnts[plantNumber]["plantName"];
      double waterAmount = plnts[plantNumber]["waterAmount"];
      double sunAmount = plnts[plantNumber]["sunAmount"];

      return
        GestureDetector(
          onTap: () => {Navigator.pushNamed(context, '/plant-detail',
          arguments: new Plant(
              id: 0,
              name: plantName,
              imageName: 'assets/images/'+_recognitions.map((res){ return res["index"];}).toList()[0].toString()+'.jpg',
              description: "Omschrijving van de plant.",
              waterText: "Informatie over hoeveel water de plant nodig heeft.",
              sunText: "Informatie over hoeveel zonlicht de plant nodig heeft.",
              waterScale: waterAmount,
              sunScale: sunAmount))},
          child: Container(
            child: predictionCard(_recognitions.map((res){ return res["index"];}).toList()[0]))
          );
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

  Widget cameraUsage() {
    return AlertDialog(
        title: Text("Camera gebruik"),
        content: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: activeCameraItem == 0
                          ? Image.asset(
                              "assets/images/camera/usage-of-camera.jpg",
                              height: 250,
                              fit: BoxFit.scaleDown,
                            )
                          : activeCameraItem == 1
                              ? Image.asset(
                                  "assets/images/camera/probable-plants.jpg",
                                  height: 250,
                                  fit: BoxFit.scaleDown,
                                )
                              : activeCameraItem == 2
                                  ? Image.asset(
                                      "assets/images/camera/add-plant.jpg",
                                      height: 250,
                                      fit: BoxFit.scaleDown,
                                    )
                                  : activeCameraItem == 3
                                      ? Image.asset(
                                          "assets/images/camera/custom-plant.jpg",
                                          height: 250,
                                          fit: BoxFit.scaleDown,
                                        )
                                      : Image.asset(
                                          "assets/images/camera/swipe-to-hide.jpg",
                                          height: 250,
                                          fit: BoxFit.scaleDown,
                                        )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: activeCameraItem == 0
                          ? Text(
                              "De eerste stap is het maken van een foto die "
                                  "gebruikt kan worden voor het toevoegen van "
                                  "een plant aan de gebruikers plantenlijst. "
                                  "Dit kan gedaan worden vanuit de gallerij of "
                                  "door direct een foto te maken.",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 6,
                            )
                          : activeCameraItem == 1
                              ? Text(
                                  "De tweede stap is de plant die de gebruiker "
                                      "heeft uit de lijst van planten "
                                      "selecteren, deze lijst heeft de meest "
                                      "overeenkomende planten van de plant van "
                                      "de gebruiker. ",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                )
                              : activeCameraItem == 2
                                  ? Text(
                                      "De derde stap is kijken naar meer "
                                          "informatie over de plant die in de "
                                          "eerste stap geselecteerd is, bij "
                                          "dit scherm kan de plant ook "
                                          "geselecteerd worden om toe te voegen"
                                          " aan de gebruikers plantenlijst. ",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 6,
                                    )
                                  : activeCameraItem == 3
                                      ? Text(
                                          "De vierde stap is het toevoegen van "
                                              "planten aan de plantenlijst, dit"
                                              " wordt gedaan door een aantal "
                                              "gegevens die van belang voor de "
                                              "plant zijn in te vullen. ",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 6,
                                        )
                                      : Text(
                                          "Veeg deze pop-up naar links of naar "
                                              "rechts of druk op de volgende "
                                              "cirkel om de uitleg af te "
                                              "sluitern. ",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 6,
                                        )),
                ],
              ),
            ),

            //Dotted lines
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () => {
                    setState(() {
                      activeCameraItem = 0;
                    })
                  },
                  child: new Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeCameraItem == 0
                          ? Colors.grey[850]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    setState(() {
                      activeCameraItem = 1;
                    })
                  },
                  child: new Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeCameraItem == 1
                          ? Colors.grey[850]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    setState(() {
                      activeCameraItem = 2;
                    })
                  },
                  child: new Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeCameraItem == 2
                          ? Colors.grey[850]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    setState(() {
                      activeCameraItem = 3;
                    })
                  },
                  child: new Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeCameraItem == 3
                          ? Colors.grey[850]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    setState(() {
                      activeCameraItem = 4;
                    })
                  },
                  child: new Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeCameraItem == 4
                          ? Colors.grey[850]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (() {
                    setState(() {
                      activeCameraItem = 5;
                    });

                    storage.setItem("first_time_usage", true);
                  }),
                  child: new Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget getIcon( String title, int numberOfStars, String icon) {
    var res = <Widget>[Container(child: Text(title))];
    for (int i = 0; i < numberOfStars; i++) {
      res.add(Container(child: Text(icon)));
    }

    return Container(child: Row(children: res,));
  }

  Widget getData(int plantNumber) {
    String plantName = plnts[plantNumber]["plantName"];
    double waterAmount = plnts[plantNumber]["waterAmount"];
    double sunAmount = plnts[plantNumber]["sunAmount"];

    return plantCardDetails(plantName,  waterAmount.toInt(),  sunAmount.toInt());
  }

  Widget plantCardDetails(String plantName, int waterAmount, int sunAmount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB( 8.0,0,0,9.0),
          child: Container(child: Text(plantName,
            style: TextStyle(color: Color(0xffe6020a), fontSize: 24.0,fontWeight: FontWeight.bold),)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Confidence : "+_recognitions.map((res){ return res["confidence"];}).toList()[0].toString()),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: getIcon("Hoeveelheid water: ",waterAmount,'💧'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: getIcon("Hoeveelheid zonlicht: ",sunAmount,'☀'),
        ),
      ],
    );
  }

  Widget predictionCard(int plantNumber){
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
              image: AssetImage('assets/images/'+plantNumber.toString()+'.jpg'),
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
    List<Widget>  builder = [];

    if(storageReady && storage.getItem("first_time_usage") == null ){
      stackChildren.add(Dismissible(
        key: UniqueKey(),
        child: cameraUsage(),
        onDismissed: (dir) {
          if(DismissDirection.startToEnd == dir && activeCameraItem > 0 ){
            setState(() {
              activeCameraItem -= activeCameraItem == 0 ? 0 : 1;
            });
          }
          if(DismissDirection.endToStart == dir && activeCameraItem < 4 ){
            setState(() {
              activeCameraItem += activeCameraItem == 5 ? 0 : 1;
            });
          }

          var storage = new LocalStorage('by_living_art');
          storage.setItem("first_time_usage", true);
        },
      ));
    }





    return Scaffold(
      drawer: MenuNavigation(),
      bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Camera", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body:
          ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Padding(
                padding: const EdgeInsets.all(12.0),
                child: selectedImageView()
                ),
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("Predictions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),)
                ),

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
    floatingActionButton:FloatingActionButton(
      onPressed: (){imageSourceChoiceDialog(context);},
      child: Icon(Icons.image, color: Colors.white,),
      backgroundColor: Colors.blueAccent,
      ),
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          File img = File(filePath);
          predictImage(img);
          setState(() {
            imageFile = img;
          });

        }
      }
    });
  }



  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/by_living_arts';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }
}
