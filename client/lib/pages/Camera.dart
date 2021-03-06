import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:localstorage/localstorage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/MenuNavigation.dart';
import 'package:tflite/tflite.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

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
  Plant _predictedPlant;
  bool _busy = false;
  bool storageReady = false;
  final LocalStorage storage = new LocalStorage('by_living_art.json');
  File predictionResultPlantImage;
  final List<String> plantNames = <String>["croton", "dracaena_lemon_lime", "peace_lily", "pothos", "snake_plant"];
  List<CameraDescription> cameras = [];
  int activeCameraItem = 0;
  String predictionCardMessage = "\n\nLoading.....";
  ApiConnection con = new ApiConnection();

  PageController _controller = PageController(
    initialPage: 0,
  );


  @override
  void initState() {
    super.initState();

    initCamera();

    _busy = true;

    storage.ready.then((_){
      setState(() {
        storageReady = _;
      });
    });

    WidgetsBinding.instance.addObserver(this);

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  openGallery(BuildContext context) async {
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
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    onNewCameraSelected(cameras.first);
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget selectedImageView(){
    if(imageFile == null){
      return Text(" ");
    }else{
      return  Image.file(imageFile,width: 150, height: 150,);
    }
  }

  Widget predictionView(){

    if(_recognitions == null){
      double width = MediaQuery.of(context).size.width;
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              height: 150,
              width: width,
              child: Text(predictionCardMessage, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
            ),
          ),]);
    }else{
      var plantId = int.parse(_recognitions.map((res){ return res["label"];}).toList()[0]);
      String plantName = _predictedPlant.name;
      double waterAmount = _predictedPlant.waterNumber;
      double sunAmount = _predictedPlant.sunNumber;

      return
        GestureDetector(
          onTap: () => {
            Navigator.pushNamed(context, '/camera-plant-detail',
              arguments:
                {
                  "plant": new Plant(
                      id: plantId,
                      name: plantName,
                      imageName: 'assets/images/'+plantId.toString()+'.jpg',
                      description: _predictedPlant.description,
                      waterText: _predictedPlant.waterText,
                      sunText: _predictedPlant.sunText,
                      waterScale: waterAmount,
                      sunScale: sunAmount
                  ),
                  "plantImage": imageFile,
                }

            )
          },
          child: Container(
            child: predictionCard( plantName,waterAmount.toInt(),sunAmount.toInt(),plantId))
          );
    }

  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
          model: "assets/m6.100.90.tflite", labels: "assets/label.txt");
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future plantModel(File image) async {
    var predictedPlant;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 0.5862695229738148,
      imageStd: 0.35730469350527,
    );
    print("----------------------------------------------------");
    print(recognitions);
    if (!await DataConnectionChecker().hasConnection){
      print("no Internet connection");
      setState((){
      predictionCardMessage = "\n\nNo internet connection";
      });
    }else {
      try{
        var predictedLabel = int.parse(recognitions.map((res) {return res["label"];}).toList()[0]);
        if (predictedLabel == -1){
          setState((){
            predictionCardMessage = "\n\nNo plants detected";
          });
        }else{
          predictedPlant = await con.fetchPlant(predictedLabel);
          setState((){
            _predictedPlant = predictedPlant;
            _recognitions = recognitions;
          });
        }
      } on Exception catch(e){
        setState((){
          predictionCardMessage = "\n\nUnable to connect to server";
        });
      }
    }


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

  Widget _dottedLines() {
    return
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () => {
                    setState(() {
                      _controller.jumpToPage(0);
                    })
                  },
                  child: new Container(
                    margin: const EdgeInsets.all(2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.page == 0
                          ? Colors.grey[850]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    setState(() {
                      _controller.jumpToPage(1);
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
                      _controller.jumpToPage(2);
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
                      _controller.jumpToPage(3);
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
                      _controller.jumpToPage(4);
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
                      _controller.jumpToPage(5);
                      storage.setItem("first_time_usage", true);
                    });

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
            );
  }

  List<Widget> cameraUsage() {
    return [
      AlertDialog(
        title: Text("Camera gebruik"),
        content: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Image.asset(
                        "assets/images/camera/usage-of-camera.jpg",
                        height: 250,
                        fit: BoxFit.scaleDown,
                      )),
                ],
              ),
            ),
            Expanded (
              child: Text(
                "De eerste stap is het maken van een foto die "
                  "gebruikt kan worden voor het toevoegen van "
                  "een plant aan de gebruikers plantenlijst. "
                  "Dit kan gedaan worden vanuit de gallerij of "
                  "door direct een foto te maken.",
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),
            _dottedLines()
          ],
        ),
      ),
      AlertDialog(
        title: Text("Camera gebruik"),
        content: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Image.asset(
                        "assets/images/camera/probable-plants.jpg",
                        height: 250,
                        fit: BoxFit.scaleDown,
                      )),
                ],
              ),
            ),
            Expanded (
              child: Text(
                "De tweede stap is de plant die de gebruiker "
                  "heeft uit de lijst van planten "
                  "selecteren, deze lijst heeft de meest "
                  "overeenkomende planten van de plant van "
                  "de gebruiker. ",
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),
            _dottedLines()
          ],
        ),
      ),
      AlertDialog(
        title: Text("Camera gebruik"),
        content: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Image.asset(
                        "assets/images/camera/add-plant.jpg",
                        height: 250,
                        fit: BoxFit.scaleDown,
                      )),
                ],
              ),
            ),
            Expanded (
              child: Text(
                "De derde stap is kijken naar meer "
                  "informatie over de plant die in de "
                  "eerste stap geselecteerd is, bij "
                  "dit scherm kan de plant ook "
                  "geselecteerd worden om toe te voegen"
                  " aan de gebruikers plantenlijst. "
                    "de gebruiker. ",
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),
            _dottedLines()
          ],
        ),
      ),
      AlertDialog(
        title: Text("Camera gebruik"),
        content: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Image.asset(
                        "assets/images/camera/custom-plant.jpg",
                        height: 250,
                        fit: BoxFit.scaleDown,
                      )),
                ],
              ),
            ),
            Expanded (
              child: Text(
                "De vierde stap is het toevoegen van "
                  "planten aan de plantenlijst, dit"
                  " wordt gedaan door een aantal "
                  "gegevens die van belang voor de "
                  "plant zijn in te vullen. ",
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),
            _dottedLines()
          ],
        ),
      ),
      AlertDialog(
        title: Text("Camera gebruik"),
        content: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Image.asset(
                        "assets/images/camera/swipe-to-hide.jpg",
                        height: 250,
                        fit: BoxFit.scaleDown,
                      )),
                ],
              ),
            ),
            Expanded (
              child: Text(
                "Swipe naar links of druk op de laatste "
                  "cirkel om de uitleg af te sluitern. ",
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),
            _dottedLines()
          ],
        ),
      ),
      Row()
    ];
  }

  Widget getIcon( String title, int numberOfStars, String icon) {
    var res = <Widget>[Container(child: Text(title))];
    for (int i = 0; i < numberOfStars; i++) {
      res.add(Container(child: Text(icon)));
    }

    return Container(child: Row(children: res,));
  }

  Widget getData(String plantName, int waterAmount, int sunAmount) {

    return plantCardDetails(plantName,  waterAmount,  sunAmount);
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
          child: Text("Confidence : "+_recognitions.map((res){ return res["confidence"];}).toList()[0].toStringAsFixed(2).toString()),
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

  Widget predictionCard(String plantName, int waterAmount, int sunAmount,int plantId){
     var res = Row(

      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            child: getData(plantName,waterAmount,sunAmount),
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
              image: AssetImage('assets/images/'+plantId.toString()+'.jpg'),
            ),
          ),
        )
      ],
    );
     return res;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget>  builder = [];

    if(storageReady && storage.getItem("first_time_usage") == null ){
      print(storage.getItem("first_time_usage") );
      builder.addAll(cameraUsage());
    }

    if(storageReady && imageFile == null && storage.getItem("first_time_usage") == true){
      var size = MediaQuery.of(context).size.width;

      builder.add(
        Container(
          child: Stack(
            children: <Widget>[
              !controller.value.isInitialized ? Container() : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FittedBox(
                  child: Container(
                    width: size,
                    height: size / controller.value.aspectRatio,
                    child: _cameraPreviewWidget()
                  ),
                  fit: BoxFit.cover,
                )

              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _captureControlRowWidget()
                ),
              )
            ],
          ),
        )
      );
    } else if(storageReady && imageFile != null && storage.getItem("first_time_usage") == true) {
      builder.add(
        Container(
          child: Column(
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
        ),
      );
    }

    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          drawer: MenuNavigation(),
          bottomNavigationBar: BottomNavigation(),
          appBar: AppBar(
            title: Text("Camera", style: TextStyle(fontFamily: 'Libre Baskerville')),
            centerTitle: true,
          ),
          body: PageView(
            controller: _controller,
            onPageChanged: (int page) {
              setState(() {
                activeCameraItem = page;

                if(page == 5)
                  storage.setItem("first_time_usage", true);

              });
            },
            children: storageReady ? builder : <Widget>[],
          ),
        ),
    );
  }


  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(controller);
    }
  }

  /// Check if the user pops the scpe, e.g. when the user uses the back button, if in camera mode, allow the creation/selection of a new image
  Future<bool> _onWillPop() async {
    if(imageFile != null){
      setState(() {
        imageFile = null;
      });
      return false;
    }

    return true;
  }



  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[

          Opacity(
            opacity: 0,
              child: FloatingActionButton(
              onPressed: null,
              heroTag: "invisibleButton",
            ),
          ),

          FloatingActionButton(
            onPressed: controller != null && controller.value.isInitialized ? onTakePictureButtonPressed : null,
            child: Icon(Icons.camera_alt),
            heroTag: "cameraButton",
          ),

          FloatingActionButton(
            onPressed: (){openGallery(context);},
            child: Icon(
              Icons.image
            ),
            heroTag: "galleryButton",
          )

          
        ],
      );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
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
}