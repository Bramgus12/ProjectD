import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../MenuNavigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {

  File imageFile;
  List _recognitions;
  bool _busy = false;

  openGallary( BuildContext context) async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    predictImage(img);
    this.setState((){
      imageFile = img;
    });
    Navigator.of(context).pop();

  }
  openCamera(BuildContext context) async{
    var img = await ImagePicker.pickImage(source: ImageSource.camera);
    predictImage(img);
    this.setState((){
      imageFile = img;
    });
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
                      openGallary(context);
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
      return Text("No image Selected!", textAlign: TextAlign.center);
    }else{
      return  Image.file(imageFile,width: 400, height: 400,);
    }
  }
  Widget predictionView(){

    if(_recognitions == null){
      return Text("prediction: ......", textAlign: TextAlign.center);
    }else{

      return Text(
          _recognitions.map((res){ return "Prediction: ${res["label"]}: Confidence: ${res["confidence"].toStringAsFixed(3)}";}).toList()[0].toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          background: Paint()..color = Colors.white,
        ),
      );

  }
  }


  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
          model: "assets/m0_0.81.tflite",
          labels: "assets/label.txt");
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
        binary: imageToByteListFloat32(image, 200, 0.4526901778594428, 0.3290300460265408),// required
        numResults: 6,    // defaults to 5
        threshold: 0.05,  // defaults to 0.1
        asynch: true      // defaults to true
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
        title: Text("Camera", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body:
          Container(

            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                selectedImageView(),
                predictionView()
              ],
            ),

          ),


//
    floatingActionButton:FloatingActionButton(
      onPressed: (){imageSourceChoiceDialog(context);},
      child: Icon(Icons.image, color: Colors.white,),
      backgroundColor: Colors.blueAccent,
      ),
    );
  }
}


