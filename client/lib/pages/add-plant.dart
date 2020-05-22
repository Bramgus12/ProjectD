import 'dart:io';

import 'package:flutter/material.dart';
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
  final _distanceToWindowText = <String>[
    '2 meter of meer',
    'Maximaal 1,5 meter',
    'Maximaal 1 meter',
    'Tussen 30 cm en 1 meter',
    '30 cm of minder'
  ];

  String selectedImagePath;
  DateTime selectedDate;
  TimeOfDay selectedTime;
  int minTemp;
  int maxTemp;

  // make date + time picker optional
  bool hideDatePicker = false;
  bool showFutureTimeWarning = false;
  bool allowedToSubmit = false;

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
    // TODO: invalidate if given lastWaterDate is null and showFutureTimeWarning is true
    if (this._formKey.currentState.validate() && allowedToSubmit) {
      _formKey.currentState.save();
      newPlant.imageName = selectedImagePath;
      User.plants.add(newPlant);
      Navigator.pushNamed(context, '/my-plants');
    }
  }

  void pickDate(BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 1, 1, 1),
        lastDate: DateTime.now());

    if (picked != null) {
      setState(() => {selectedDate = picked});
      print('picked date: $selectedDate');
      _combinePickedDateAndTime();
    }
  }

  void pickTime(BuildContext context) async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => {selectedTime = picked});
      print('picked time: $selectedTime');
      _combinePickedDateAndTime();
    }
  }

  void _combinePickedDateAndTime() {
    if (selectedDate == null || selectedTime == null) {
      return;
    }

    var pickedDateTime = new DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, selectedTime.hour, selectedTime.minute, 0);

    if (pickedDateTime.isAfter(DateTime.now())) {
      print('can\'t select future date');
      newPlant.lastWaterDate = null;
      showFutureTimeWarning = true;
      allowedToSubmit = false;
      return;
    }

    showFutureTimeWarning = false;
    allowedToSubmit = true;
    newPlant.lastWaterDate = pickedDateTime;
    print('lastTimeWater = ${formatDate(newPlant.lastWaterDate)}');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: change all colors to theme colors
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
                // TODO: also validate onChanged instead of on submit to make the form more 'user-friendly'
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
                                                onTap: () =>
                                                    selectImageFromSource(
                                                        context,
                                                        ImageSource.camera),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(10.0),
                                              ),
                                              GestureDetector(
                                                child: Text("Galerij"),
                                                onTap: () =>
                                                    selectImageFromSource(
                                                        context,
                                                        ImageSource.gallery),
                                              ),
                                            ],
                                          ),
                                        ));
                                  }),
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
                        label: 'Inhoud pot',
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
                            child: Text(
                                'Wanneer heeft de plant voor het laatst water gekregen?'),
                          ),
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: <Widget>[
                                Text('Niet van toepassing'),
                                Checkbox(
                                  value: hideDatePicker,
                                  onChanged: (bool value) {
                                    hideDatePicker = value;
                                    // FIXME: find a more maintainable way to enable/disable the submit button
                                    if (hideDatePicker) {
                                      allowedToSubmit = true;
                                    }
                                    else {
                                      allowedToSubmit = false;
                                    }
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 20),
                      // TODO: make layout more 'user-friendly'
                      () {
                        if (!hideDatePicker) {
                          return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      FlatButton(
                                        child: Icon(Icons.date_range),
                                        onPressed: () => pickDate(context),
                                        color: Colors.blue,
                                      ),
                                      SizedBox(height: 10),
                                      Text(selectedDate != null
                                          ? '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}'
                                          : '')
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      FlatButton(
                                        child: Icon(Icons.timer),
                                        onPressed: () => pickTime(context),
                                        color: Colors.blue,
                                      ),
                                      SizedBox(height: 10),
                                      () {
                                        if (!showFutureTimeWarning) {
                                          return Text(selectedTime != null
                                              ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                                              : '');
                                        }

                                        return Text(
                                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                                            '\n\nDe gekozen tijd is in de toekomst.',
                                            style:
                                                TextStyle(color: Colors.red));
                                      }()
                                    ],
                                  ),
                                ),
                              ]);
                        } else {
                          return SizedBox(height: 20);
                        }
                      }(),

                      // AddPlantTextField(
                      SizedBox(height: 50),
                      Text('Afstand tot het raam'),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_distanceToWindowText[
                              (newPlant.distanceToWindow != null &&
                                      newPlant.distanceToWindow > 0)
                                  ? newPlant.distanceToWindow.toInt() - 1
                                  : 0]),
                          Slider(
                            value: newPlant.distanceToWindow ?? 1,
                            onChanged: (double value) {
                              setState(() {
                                newPlant.distanceToWindow = value;
                              });
                              print(newPlant.distanceToWindow);
                            },
                            min: 1,
                            max: 5,
                            // label: newPlant.distanceToWindow.toString(),
                            activeColor: Colors.blue,
                            divisions: 4,
                          ),
                        ],
                      ),
                      SizedBox(height: 25),

                      Row(children: <Widget>[
                        Expanded(
                            flex: 9,
                            child: AddPlantTextField(
                              label: 'Minimale temperatuur in de kamer',
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
                            flex: 9,
                            child: AddPlantTextField(
                              label: 'Maximale temperatuur in de kamer',
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
                      // TODO: allow submission if all required fields are filled
                      RaisedButton(
                        child: Text('Voeg toe'),
                        onPressed: allowedToSubmit ? submit : null,
                        disabledColor: Colors.grey[700],
                        disabledTextColor: Colors.black,
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
            height: 20,
          )
        ],
      ),
    );
  }
}
