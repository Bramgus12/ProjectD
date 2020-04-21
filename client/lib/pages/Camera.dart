import 'dart:io';

import 'package:flutter/material.dart';

import '../MenuNavigation.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {

  File imageFile;

  openGallary( BuildContext context) async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState((){
      imageFile = img;
    });
    Navigator.of(context).pop();

  }
  openCamera(BuildContext context) async{
    var img = await ImagePicker.pickImage(source: ImageSource.camera);
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
      return Text("No image Selected!");
    }else{
      return  Image.file(imageFile,width: 400, height: 400,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuNavigation(),
      bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Camera", style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedImageView(),
            Text(
              'Camera',
            ),
            Padding(padding: EdgeInsets.all(8.0),),
            FloatingActionButton(onPressed: (){

              imageSourceChoiceDialog(context);
            },
              child: Icon(Icons.image, color: Colors.white,),
              backgroundColor: Colors.blueAccent,
            ),
          ],
        ),


      ),

    );
  }
}


