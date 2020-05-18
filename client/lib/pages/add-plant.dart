import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantexpert/api/User.dart';
import 'package:plantexpert/api/UserPlant.dart';

import '../MenuNavigation.dart';

class AddPlant extends StatefulWidget {
  @override
  _AddPlant createState() => _AddPlant();
}

class _AddPlant extends State<AddPlant> {
  final _formKey = GlobalKey<FormState>();
  final UserPlant newPlant = new UserPlant();
  int minTemp;
  int maxTemp;

  // dd-MM-yyyy HH:mm
  String formatDate(DateTime date) {
    if (date == null) {
      throw new ArgumentError('date is null');
    }
    
    return '${newPlant.lastWaterDate.month.toString().padLeft(2, '0')}-${newPlant.lastWaterDate.day.toString().padLeft(2, '0')}-${newPlant.lastWaterDate.year} ${newPlant.lastWaterDate.hour.toString().padLeft(2, '0')}:${newPlant.lastWaterDate.minute.toString().padLeft(2, '0')}';
  }

  void selectFromSource(BuildContext context, ImageSource source) async {
    setState(() {
      newPlant.imageName = null;
    });

    var pickedImage = await ImagePicker.pickImage(source: source);

    setState(() {
      newPlant.imageName = pickedImage != null ? pickedImage.path : null;
    });
  }

  void submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      print(newPlant);
      User.plants.add(newPlant);
      Navigator.pushNamed(context, '/my-plants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuNavigation(),
      // bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Plant toevoegen",
            style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[900],
        child: DefaultTextStyle(
            style:
                TextStyle(fontFamily: 'Libre Baskerville', color: Colors.white),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Text('Afbeelding'),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  () { 
                                      if(newPlant.imageName != null){
                                        return Image.file(
                                          File(newPlant.imageName),
                                          width: 150,
                                          height: 150,
                                        );
                                      } 
                                      else {
                                        return SizedBox();
                                      }
                                    }()
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.image),
                                    onPressed: () => selectFromSource(context, ImageSource.gallery),
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.camera_alt),
                                    onPressed: () => selectFromSource(context, ImageSource.camera),
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        AddPlantTextField(
                          label: 'Bijnaam',
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Mag niet leeg zijn.';
                            }

                            return null;
                          },
                          onSaved: (String value) {
                            newPlant.nickname = value;
                          },
                        ),
                        AddPlantTextField(
                            label: 'Inhoud bak',
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              double temp = double.tryParse(value);

                              if (temp == null) {
                                return 'Moet een getal zijn.';
                              }

                              return null;
                            },
                            onSaved: (String value) {
                              newPlant.potVolume = double.parse(value);
                            },
                        ),
                            Text('Wanneer heeft de plant voor\nhetlaatst water gekregen?'),
                            SizedBox(height: 10),
                            Text(
                              newPlant.lastWaterDate != null 
                                ? formatDate(newPlant.lastWaterDate) 
                                : ''
                            ),
                            IconButton(
                              icon: Icon(Icons.date_range, color: Colors.blue,),
                              onPressed: () => DatePicker.showDateTimePicker(
                                context,
                                minTime: DateTime(DateTime.now().year, 1, 1),
                                maxTime: DateTime.now(),
                                currentTime: newPlant.lastWaterDate ?? DateTime.now(),
                                onConfirm: (DateTime date) {
                                  newPlant.lastWaterDate = date;
                                  setState(() {});
                                },
                              ),
                            ),
                        AddPlantTextField(
                            label: 'Hoeveelheid zonlicht',
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              double temp = double.tryParse(value);

                              if (temp == null) {
                                return 'Moet een getal zijn.';
                              }

                              return null;
                            },
                            onSaved: (String value) {
                              newPlant.distanceToWindow = double.parse(value);
                            },
                        ),
                        Row(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: AddPlantTextField(
                                label: 'Minimale temperatuur kamer',
                                keyboardType: TextInputType.number,
                                validator: (String value) {
                                  int temp = int.tryParse(value);

                                  if (temp == null) {
                                    return 'Moet een getal zijn.';
                                  }

                                  if (maxTemp != null && maxTemp < temp) {
                                    return 'Mag niet hoger zijn\n dan max temp.';
                                  }

                                  minTemp = temp;
                                  return null;
                                },
                                onSaved: (String value) {
                                  newPlant.minTemp = minTemp;
                                },
                            )
                          ),
                          Expanded(
                            flex: 2,
                            child: SizedBox(),
                          ),
                          Expanded(
                            flex: 4,
                            child: AddPlantTextField(
                                label: 'Maximale temperatuur kamer',
                                keyboardType: TextInputType.number,
                                validator: (String value) {
                                  int temp = int.tryParse(value);

                                  if (temp == null) {
                                    return 'NaN';
                                  }

                                  if (minTemp != null && minTemp > temp) {
                                    return 'Mag niet lager zijn\n dan min temp.';
                                  }

                                  maxTemp = temp;
                                  return null;
                                },
                                onSaved: (String value) {
                                  newPlant.maxTemp = maxTemp;
                                },
                            )
                          )
                        ]),
                        RaisedButton(
                          child: Text('Voeg toe'),
                          onPressed: submit,
                        )
                      ],
                    ),
              )
            )
            ),
      ),
    );
  }
}

class AddPlantTextField extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final Function(String) validator;
  final Function(String) onSaved;

  AddPlantTextField({this.label, this.keyboardType, this.validator, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label),
          SizedBox(height: 10),
          TextFormField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: this.keyboardType ?? TextInputType.text,
            validator: this.validator,
            onSaved: this.onSaved,
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}
