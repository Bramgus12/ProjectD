import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../MenuNavigation.dart';
import 'plant-list.dart';

class AddPlant extends StatefulWidget {
  @override
  _AddPlant createState() => _AddPlant();
}

class CustomPlant {
  String nickName;
  int volumeInMM;
  DateTime lastTimeWater;
  int sunLightNeeded;
  int minTempLocation;
  int maxTempLocation;
}

class _AddPlant extends State<AddPlant> {
  final _formKey = GlobalKey<FormState>();
  final CustomPlant newPlant = new CustomPlant();

  void submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      print(newPlant.nickName);
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
        color: Colors.black,
        child: DefaultTextStyle(
            style:
                TextStyle(fontFamily: 'Libre Baskerville', color: Colors.white),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    AddPlantTextField(
                      label: 'Naam',
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Leeg';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        newPlant.nickName = value;
                      },
                    ),
                    AddPlantTextField(
                        label: 'Inhoud bak',
                        keyboardType: TextInputType.number,
                        validator: (String value) {
                          int a = int.tryParse(value);

                          if (a == null) {
                            return 'NaN';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          newPlant.volumeInMM = int.parse(value);
                        },
                    ),
                    IconButton(
                      icon: Icon(Icons.date_range, color: Colors.blue,),
                      onPressed: () => DatePicker.showDateTimePicker(
                        context,
                        minTime: DateTime(DateTime.now().year, 1, 1),
                        maxTime: DateTime.now(),
                        onConfirm: (date) {
                          newPlant.lastTimeWater = date;
                        }
                      ),
                    ),
                    AddPlantTextField(
                        label: 'Hoeveelheid zonlicht',
                        keyboardType: TextInputType.number,
                        validator: (String value) {
                          int a = int.tryParse(value);

                          if (a == null) {
                            return 'NaN';
                          }

                          return null;
                        },
                        onSaved: (String value) {
                          newPlant.sunLightNeeded = int.parse(value);
                        },
                    ),
                    Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: AddPlantTextField(
                            label: 'Min temperatuur',
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              int a = int.tryParse(value);

                              if (a == null) {
                                return 'NaN';
                              }

                              return null;
                            },
                            onSaved: (String value) {
                              newPlant.minTempLocation = int.parse(value);
                            },
                        )
                      ),
                      Expanded(
                        flex: 4,
                        child: AddPlantTextField(
                            label: 'Max temperatuur',
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              int a = int.tryParse(value);

                              if (a == null) {
                                return 'NaN';
                              }

                              return null;
                            },
                            onSaved: (String value) {
                              newPlant.maxTempLocation = int.parse(value);
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
              ),
            )),
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
          SizedBox(height: 5),
          TextFormField(
            decoration: InputDecoration(
//              hintText: this.label,
//              hintStyle: TextStyle(color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)
              ),
            ),
            keyboardType:
            this.keyboardType == null ? TextInputType.text : this.keyboardType,
            validator: this.validator,
            onSaved: this.onSaved,
          ),
          SizedBox(height: 10,)
        ],
      ),
    );

  }
}
