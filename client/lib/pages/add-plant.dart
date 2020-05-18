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
  String selectedImagePath;
  bool hideDatePicker = false;
  DateTime selectedDate;
  TimeOfDay selectedTime;
  int minTemp;
  int maxTemp;

  // dd-MM-yyyy HH:mm
  String formatDate(DateTime date) {
    if (date == null) {
      throw new ArgumentError('date is null');
    }

    var year = newPlant.lastWaterDate.year;
    var month = newPlant.lastWaterDate.month.toString().padLeft(2, '0');
    var day = newPlant.lastWaterDate.day.toString().padLeft(2, '0');
    var hour = newPlant.lastWaterDate.hour.toString().padLeft(2, '0');
    var minute = newPlant.lastWaterDate.minute.toString().padLeft(2, '0');

    return '$day-$month-$year $hour:$minute';
  }

  void selectImageFromSource(BuildContext context, ImageSource source) async {
    var pickedImage = await ImagePicker.pickImage(source: source);
    Navigator.of(context).pop();
    
    setState(() {
      // keep the previous image if no image is selected
      if (pickedImage == null && selectedImagePath != null) {
        return;
      }

      selectedImagePath = pickedImage != null ? pickedImage.path : null;
    });
  }

  void submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      newPlant.imageName = selectedImagePath;
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
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                () {
                                  if (selectedImagePath != null) {
                                    return Image.file(
                                      File(selectedImagePath),
                                      width: 150,
                                      height: 150,
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                }()
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: FloatingActionButton(
                              child: Icon(Icons.image),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Maak een keuze"),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            GestureDetector(
                                              child: Text("Camera"),
                                              onTap: () => selectImageFromSource(context, ImageSource.camera),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10.0),
                                            ),
                                            GestureDetector(
                                              child: Text("Galerij"),
                                              onTap: () => selectImageFromSource(context, ImageSource.gallery),
                                            ),
                                          ],
                                        ),
                                      )
                                    );
                                  }
                              ),
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
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child:  Text('Wanneer heeft de plant voor het laatst water gekregen?'),
                          ),
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: <Widget>[
                                Text("Weet ik niet"),
                                Checkbox(
                                  value: hideDatePicker,
                                  onChanged: (bool value) {
                                    print(value);
                                    hideDatePicker = value;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      () {
                        if (!hideDatePicker) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 20),
                              Text(newPlant.lastWaterDate != null
                                  ? formatDate(newPlant.lastWaterDate)
                                  : ''),

                              // TODO: make 2 fields, date and time
                              // TODO: make a checkbox when date + time is not needed
                              IconButton(
                                icon: Icon(
                                  Icons.date_range,
                                  color: Colors.blue,
                                ),
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
                            ],
                          );
                        }
                        else {
                          return SizedBox.shrink();
                        }
                      }(),
                      

                      // TODO: make a slider (1-5) to make it user-friendly
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
                      // TODO: add space between the fields
                      Row(children: <Widget>[
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
                                  return 'Mag niet hoger zijn\n dan de maximale temperatuur.';
                                }

                                minTemp = temp;
                                return null;
                              },
                              onSaved: (String value) {
                                newPlant.minTemp = minTemp;
                              },
                            )),
                        Expanded(
                          flex: 2,
                          child: SizedBox.shrink(),
                        ),
                        Expanded(
                            flex: 4,
                            child: AddPlantTextField(
                              label: 'Maximale temperatuur kamer',
                              keyboardType: TextInputType.number,
                              validator: (String value) {
                                int temp = int.tryParse(value);

                                if (temp == null) {
                                  return 'Moet een getal zijn.';
                                }

                                if (minTemp != null && minTemp > temp) {
                                  return 'Mag niet lager zijn\n dan de minimale temperatuur';
                                }

                                maxTemp = temp;
                                return null;
                              },
                              onSaved: (String value) {
                                newPlant.maxTemp = maxTemp;
                              },
                            ))
                      ]),
                      RaisedButton(
                        child: Text('Voeg toe'),
                        onPressed: submit,
                      )
                    ],
                  ),
                ))),
      ),
    );
  }
}

class AddPlantTextField extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final Function(String) validator;
  final Function(String) onSaved;

  AddPlantTextField(
      {this.label, this.keyboardType, this.validator, this.onSaved});

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
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: this.keyboardType ?? TextInputType.text,
            validator: this.validator,
            onSaved: this.onSaved,
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
