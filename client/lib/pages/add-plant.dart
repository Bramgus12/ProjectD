import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantexpert/api/ApiConnection.dart';
import 'package:plantexpert/api/ApiConnectionException.dart';
import 'package:plantexpert/api/Plant.dart';
import 'package:plantexpert/api/UserPlant.dart';
import 'package:plantexpert/Utility.dart';
import 'package:plantexpert/widgets/InputTextField.dart';

import '../MenuNavigation.dart';

class AddPlant extends StatefulWidget {

  final UserPlant plant;
  final File file;

  AddPlant({this.plant, this.file});

  @override
  _AddPlant createState() => _AddPlant();
}

class _AddPlant extends State<AddPlant> {
  final _formKey = GlobalKey<FormState>();

  ApiConnection apiConnection = new ApiConnection();

  UserPlant newPlant;

  final _distanceToWindowText = <String>[
    '2 meter of meer',
    'Tussen 1,50 meter en 2 meter',
    'Tussen 1 meter en 1,50 meter',
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
  bool noImageSelected = false;

  // used in FutureBuilder
  Future<List<Plant>> _fetchedPlants;
  // save the selected name of the plant type (built-in dropdown only saves the selected value)
  String plantTypeName;

  int optimalPlantTemperature;

  List<Plant> listOfPlants;
  String _serverErrorMessage;
  String _plantFetchErrorMessage;

  File pickedImage;

  @override
  void initState() {
    super.initState();
    // prevent fetching plants twice
    _fetchedPlants = _fetchPlants();
    pickedImage = widget.file;
    newPlant = widget.plant == null ? new UserPlant() : widget.plant;
    newPlant.distanceToWindow = 3;
    print(newPlant);
   }

  void selectImageFromSource(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    Navigator.of(context).pop();

    // check if image is selected or keep the previous image if no image is selected
    if(image == null || (image == null && newPlant.imageName != null))
      return;

    setState(() {
      newPlant.imageName = image.path;
      pickedImage = image;
    });
  }

  void submit() async {

    if (this._formKey.currentState.validate() && _checkAllowedToSubmit()) {
      _formKey.currentState.save();
      var result;
      ThemeData theme = Theme.of(context);

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

      try {
        result = await apiConnection.postUserPlant(newPlant, pickedImage);
      } on ApiConnectionException catch (e) {
        setState(() {
          _serverErrorMessage = 'Er is wat fout gegaan bij het aanmaken van uw plant, controleer uw internet en probeer het later nog een keer.';
          result = null;
        });
        print(e);

      }
      on InvalidCredentialsException catch (e) {
        setState(() {
          _serverErrorMessage = 'U moet ingelogd zijn voordat u planten toe kunt voegen.';
          result = null;
        });
        print(e);
      }

      Navigator.pop(context);

      if (result != null) {
        // SocketException occurs before the loading dialog is shown,
        // use try catch to prevent `The getter 'focusScopeNode' was called on null`
        Navigator.pop(context, "addedPlant");

      }
    } else {
        setState(() {
          _serverErrorMessage = "Een of meer velden zijn niet goed ingevuld.";
        });
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
      pickTime(context);
    }
  }

  void pickTime(BuildContext context) async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },

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

    setState(() {
      noImageSelected = pickedImage != null ? false : true;
    });

    print('_checkAllowedToSubmit() $newPlant');
    bool allowed = !formSubmitted && (pickedImage != null
          && newPlant.plantId != null
          && (hideDatePicker || newPlant.lastWaterDate != null)
          && newPlant.nickname != null
          && newPlant.potVolume != null
          && (newPlant.minTemp != null && newPlant.maxTemp != null)
        );

          print('_checkAllowedToSubmit() $allowed');
    return allowed;
  }

  Future<List<Plant>> _fetchPlants() async {
    var plants;
    setState(() {
      failedFetchPlants = false;
      _plantFetchErrorMessage = null;
    });

    try {
      plants = await apiConnection.fetchPlants();

      setState(() {
        listOfPlants = plants;
      });
    } on ApiConnectionException catch (e) {
      print(e);
      setState(() {
        failedFetchPlants = true;
        _plantFetchErrorMessage = "Planten konden niet worden opgehaald";
      });
    } on TimeoutException catch (e) {
      print(e);
      setState(() {
        failedFetchPlants = true;
        _plantFetchErrorMessage = "Planten konden niet worden opgehaald";
      });
    }

    return plants;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
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
            // TODO: also validate onChanged instead of on submit to make the form more 'user-friendly'
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: <Widget>[

                  Text('Plantsoort', style: TextStyle(color: theme.accentColor, fontSize: 18),),
                  SizedBox(height: 10),
                  (){

                    String plantHint = plantTypeName ?? 'Kies de plantensoort.';
                    return DropdownButtonFormField(
                          items: listOfPlants != null ? listOfPlants.map((e) => DropdownMenuItem(
                                child: Text(e.name), value: e.id)
                                ).toList() : [],
                          hint: Text(_plantFetchErrorMessage ?? plantHint),
                          onChanged: (value) {
                            var plant =  listOfPlants.firstWhere((item) => item.id == value);
                            print('selected $value ${plant.name}');
                            if(value != null)
                              setState(() {
                                optimalPlantTemperature = plant.optimalTemp;
                                newPlant.plantId = value;
                              });
                          },
                          value: newPlant.plantId,
                        );
                  }(),

                  SizedBox(height: 20),

                  Text('Afbeelding', style: TextStyle(color: theme.accentColor, fontSize: 18)),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: pickedImage != null ? Image.file(
                                pickedImage,
                                width: 150,
                                height: 150,
                              )
                            : Image.asset("assets/images/image-placeholder.png")
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
                  (){
                    if(noImageSelected)
                      return Text("U moet een afbeelding mee sturen. ", style: TextStyle(color: Colors.red),);
                    return SizedBox();
                  }(),
                  SizedBox(height: 20),
                  InputTextField(
                    title: "Bijnaam",
                    label: 'Dit is de bijnaam die uw plant in de applicatie krijgt. ',
                    inputType: String,

                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Mag niet leeg zijn.';
                      }

                      return null;
                    },
                    onSaved: (String value) {
                      setState(() {
                        newPlant.nickname = value;
                      });
                    },
                    onChanged: (String value) {
                      setState(() {
                        newPlant.nickname = value;
                      });
                    },
                    initialValue: newPlant.nickname ?? ''
                  ),
                  InputTextField(
                    title: "Inhoud plantenpot",
                    label: 'Dit is de inhoud van uw plantenpot in liters. ',
                    inputType: double,
                    keyboardType: TextInputType.number,
                    validator: (String value) {
                      double temp = double.tryParse(value);

                      if (temp == null) {
                        return 'Moet een getal zijn.';
                      }

                      return null;
                    },
                    onSaved: (String value) {
                      setState(() {
                        newPlant.potVolume = double.parse(value);
                      });
                    },
                    onChanged: (String value) {
                      setState(() {
                        newPlant.potVolume = double.parse(value);
                      });
                    },
                    initialValue: newPlant.potVolume?.toString() ?? ''
                  ),
                  Text(
                      'Wanneer heeft de plant voor het laatst water gekregen?',
                      style: TextStyle(color: theme.accentColor, fontSize: 18)),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: <Widget>[
                            Text('Niet van toepassing'),
                            Checkbox(
                              value: hideDatePicker,
                              onChanged: (bool value) {
                                setState(() {
                                  hideDatePicker = value;
                                  if(value)
                                    newPlant.lastWaterDate = DateTime.fromMillisecondsSinceEpoch(0);
                                  else
                                    _combinePickedDateAndTime();
                                });
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
                                  RawMaterialButton(
                                    onPressed: () { pickDate(context); },
                                    elevation: 2.0,
                                    fillColor: theme.accentColor,
                                    child: Icon(
                                      Icons.date_range,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.all(15.0),
                                    shape: CircleBorder(),
                                  ),
                                  SizedBox(height: 10),
                                  Text(selectedDate != null
                                      ? 'Datum: ${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}'
                                      : ''),
                                  () {
                                    if (!showFutureTimeWarning) {
                                      return Text(selectedTime != null
                                          ? 'Tijd: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
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

                  SizedBox(height: 50),
                  Text('Afstand tot het raam', style: TextStyle(color: theme.accentColor, fontSize: 18)),
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
                  InputTextField(
                      title: "Minimale temperatuur",
                      label: 'Minimale temperatuur in de kamer in celsius.',
                      keyboardType: TextInputType.number,
                      inputType: double,
                      validator: (String value) {
                        int temp = int.tryParse(value);

                        if (temp == null) {
                          return 'De waarde moet een posiftief getal zijn.';
                        } else if (newPlant.maxTemp != null && newPlant.maxTemp < temp) {
                          return 'Mag niet hoger zijn dan de maximale temperatuur.';
                        }

                        newPlant.minTemp = temp;
                        return null;
                      },
                      onSaved: (String value) {
                        print(this);
                        setState(() {
                          newPlant.minTemp = int.parse(value);
                        });
                      },
                      onChanged: (String value) {
                        setState(() {
                          newPlant.minTemp = int.parse(value);
                        });
                      },
                      initialValue: newPlant.minTemp?.toString() ?? ''
                  ),
                  SizedBox(height: 20),
                  InputTextField(
                      title: "Maximale temperatuur",
                      label: 'Maximale temperatuur in de kamer, in celsius. ',
                      keyboardType: TextInputType.number,
                      inputType: double,
                      validator: (String value) {
                        int temp = int.tryParse(value);

                        if (temp == null) {
                          return 'Moet een getal zijn.';
                        }

                        if (newPlant.minTemp != null && newPlant.minTemp > temp) {
                          return 'Mag niet lager zijn dan de minimale temperatuur';
                        }

                        newPlant.maxTemp = temp;
                        return null;
                      },
                      onSaved: (String value) {
                        setState(() {
                          newPlant.maxTemp = int.parse(value);
                        });
                      },
                      onChanged: (String value) {
                        setState(() {
                          newPlant.maxTemp = int.parse(value);
                        });
                      },
                      initialValue: newPlant.maxTemp?.toString() ?? ''
                  ),

                  (){
                    if(optimalPlantTemperature != null)
                      return Text("Let Op: De gemiddelde temperatuur voor de plant is rond de $optimalPlantTemperature℃.");
                    return SizedBox();
                  }(),
                  () {
                    if(_serverErrorMessage != null)
                      return Container(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.orange[300],
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              )
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(_serverErrorMessage, style: TextStyle(fontSize: 16),),
                          ),
                        ),
                      );

                    return SizedBox();
                  }(),
                  SizedBox(height: 20),

                  // TODO: allow submission if all required fields are filled
                  FlatButton(
                    child: Text('Aanmaken',
                      style: theme.accentTextTheme.button),
                    onPressed: submit,
                    color: theme.accentColor,
                    disabledColor: theme.disabledColor,
                  )
                ],
            ))),
      ),
    );
  }
}

