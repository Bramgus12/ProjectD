import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';

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

  DateTime selectedDate;
  TimeOfDay selectedTime;

  // make date + time picker optional
  // TODO: server doesn't accept null DateTimes as of 2020-27-05
  bool hideDatePicker = false;
  bool showFutureTimeWarning = false;
  bool formSubmitted = false;
  // failing to fetch plants from the server
  bool failedFetchPlants = false;

  // used in FutureBuilder
  Future<List<Plant>> _fetchedPlants;
  // save the selected name of the plant type (built-in dropdown only saves the selected value)
  String plantTypeName;

  void selectImageFromSource(BuildContext context, ImageSource source) async {
    var pickedImage = await ImagePicker.pickImage(source: source);
    Navigator.of(context).pop();

    setState(() {
      // keep the previous image if no image is selected
      if (pickedImage == null && newPlant.imageName != null) {
        return;
      }

      newPlant.imageName = pickedImage?.path;
    });
  }

  void submit() async {
    print(newPlant);

    if (this._formKey.currentState.validate() && _checkAllowedToSubmit()) {
      formSubmitted = true;
      // disable the submit button
      setState(() {});
      _formKey.currentState.save();
      var result;
      ThemeData theme = Theme.of(context);
      String errorMessage;

      try {
        result = PlantenApi.instance.connection.postUserPlant(newPlant, File(newPlant.imageName));
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                    color: theme.accentColor,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height / 4,
                    child: Center(
                      child: CircularProgressIndicator(backgroundColor: Colors.white),
                    )
                ),
              );
            }
        );
        await result;
      } on ApiConnectionException catch (e) {
        errorMessage = 'Fout bij het verbinden van de server';
        result = null;
        print(e);
      } on TimeoutException catch (e) {
        print(e);
      }
      on SocketException catch (e) {
        errorMessage = 'Fout bij het verbinden van de server';
        result = null;
        print(e);
      }
      on InvalidCredentialsException catch (e) {
        errorMessage = 'Je moet ingelogd zijn om planten te kunnen toevoegen';
        result = null;
        print(e);
      }
      on StatusCodeException catch (e) {
        print(e);
      }

      if (result == null) {
        // SocketException occurs before the loading dialog is shown,
        // use try catch to prevent `The getter 'focusScopeNode' was called on null`
        try {
          Navigator.pop(context);
        }
        on NoSuchMethodError catch (e) {

        }

        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                    color: Colors.red,
                    height: MediaQuery.of(context).size.height / 4,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                            errorMessage ?? 'Kon niet worden toegevoegd',
                            style: TextStyle(color: Colors.white, fontSize: 16)
                        )
                      )
                    )
                ),
              );
            }
        );
        formSubmitted = false;
        // enable the submit button
        setState(() {});
        return;
      }

      print(result);

      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                child: Container(
                  color: theme.accentColor,
                  height: MediaQuery.of(context).size.height / 4,
                  child: Center(
                    child: Text('Succesvol toegevoegd', style: TextStyle(color: Colors.white, fontSize: 16)),
                  )
                ),
            );
          }
      );

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
      return;
    }

    showFutureTimeWarning = false;
    newPlant.lastWaterDate = pickedDateTime;
    print('lastTimeWater = ${formatDate(newPlant.lastWaterDate)}');
  }

  // check if all required fields are filled
  bool _checkAllowedToSubmit() {
    print('_checkAllowedToSubmit() $newPlant');
    bool allowed = !formSubmitted && (newPlant.imageName != null
          && (hideDatePicker || newPlant.lastWaterDate != null)
          && newPlant.nickname != null
          && newPlant.potVolume != null
          && (newPlant.minTemp != null && newPlant.maxTemp != null)
        );

    print('_checkAllowedToSubmit() $allowed');
    return allowed;
  }

  // FIXME: use this function instad of the one in `Utility.dart`
  Future<List<Plant>> _fetchPlants() async {
    var plants;

    try {
      plants = await PlantenApi.instance.connection.fetchPlants();
    } on ApiConnectionException catch (e) {
      print(e);
      failedFetchPlants = true;
    } on TimeoutException catch (e) {
      print(e);
      failedFetchPlants = true;
    }

    return plants;
  }

  @override
  void initState() {
    super.initState();
    // prevent fetching plants twice
    _fetchedPlants = _fetchPlants();
    newPlant.distanceToWindow = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      drawer: MenuNavigation(),
      // bottomNavigationBar: BottomNavigation(),
      appBar: AppBar(
        title: Text("Plant toevoegen",
            style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: Container(
        child: DefaultTextStyle(
            style:
                TextStyle(fontFamily: 'Libre Baskerville', color: Colors.black),
            child: Padding(
                padding: EdgeInsets.all(15.0),
                // TODO: also validate onChanged instead of on submit to make the form more 'user-friendly'
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Text('Plantsoort'),
                      SizedBox(height: 10),
                      FutureBuilder(
                        future: _fetchedPlants,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Plant>> snapshot) {
                          var items = <DropdownMenuItem>[
                            DropdownMenuItem(
                              child: Text('Planten worden opgehaald...'),
                              value: null,
                            )
                          ];

                          if (snapshot.hasData) {
                            items = snapshot.data
                                .map((p) => DropdownMenuItem(
                                    child: Text(p.name), value: p.id))
                                .toList();
                          }
                          // hasError doesn't work on caught exceptions
                          else if (snapshot.hasError || failedFetchPlants) {
                            items[0] = DropdownMenuItem(
                              child:
                                  Text('Planten konden niet worden opgehaald'),
                              value: null,
                            );
                          }

                          return DropdownButtonFormField(
                            items: items,
                            hint: Text(plantTypeName ?? 'Kies het soort plant.'),
                            onChanged: (value) {
                              Text t = items.where((item) => item.value == value).elementAt(0).child;
                              plantTypeName = t.data;
                              print('selected $value $plantTypeName');
                              newPlant.plantId = value;
                              setState(() {});
                            },
                            value: null,
                          );
                        },
                      ),
                      SizedBox(height: 20),

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
                                  if (newPlant.imageName != null && File(newPlant.imageName).existsSync()) {
                                    // TODO: not all images are .jpeg
                                    return Image.file(
                                      File(newPlant.imageName),
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
                        onChanged: (String value) {
                          newPlant.nickname = value;
                        },
                        initialValue: newPlant.nickname ?? ''
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
                        onChanged: (String value) {
                          newPlant.potVolume = double.tryParse(value);
                        },
                        initialValue: newPlant.potVolume?.toString() ?? ''
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
                                        child: Icon(Icons.date_range,
                                            color: Colors.white),
                                        onPressed: () => pickDate(context),
                                        color: theme.accentColor,
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
                                        child: Icon(Icons.timer,
                                            color: Colors.white),
                                        onPressed: () => pickTime(context),
                                        color: theme.accentColor,
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
                            activeColor: theme.accentColor,
                            inactiveColor: theme.disabledColor,
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

                                if (newPlant.maxTemp != null && newPlant.maxTemp < temp) {
                                  return 'Mag niet hoger zijn\n dan de maximale temperatuur.';
                                }

                                newPlant.minTemp = temp;
                                return null;
                              },
                              onSaved: (String value) {
                                newPlant.minTemp = int.parse(value);
                              },
                              onChanged: (String value) {
                                newPlant.minTemp = int.tryParse(value);
                              },
                              initialValue: newPlant.minTemp?.toString() ?? ''
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

                                if (newPlant.minTemp != null && newPlant.minTemp > temp) {
                                  return 'Mag niet lager zijn\n dan de minimale temperatuur';
                                }

                                newPlant.maxTemp = temp;
                                return null;
                              },
                              onSaved: (String value) {
                                newPlant.maxTemp = int.parse(value);
                              },
                              onChanged: (String value) {
                                newPlant.maxTemp = int.tryParse(value);
                              },
                              initialValue: newPlant.maxTemp?.toString() ?? ''
                            ))
                      ]),
                      // TODO: allow submission if all required fields are filled
                      RaisedButton(
                        child: Text('Voeg toe',
                            style: theme.accentTextTheme.button),
                        onPressed: _checkAllowedToSubmit() ? submit : null,
                        color: theme.accentColor,
                        disabledColor: theme.disabledColor,
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
  final String initialValue;
  final TextInputType keyboardType;
  final Function(String) validator;
  final Function(String) onSaved;
  final Function(String) onChanged;

  AddPlantTextField(
      {this.label, this.initialValue = '', this.keyboardType, this.validator, this.onSaved, this.onChanged});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label),
          SizedBox(height: 10),
          TextFormField(
            initialValue: this.initialValue,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.accentColor),
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor)),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: this.keyboardType ?? TextInputType.text,
            validator: this.validator,
            onSaved: this.onSaved,
            onChanged: this.onChanged
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
