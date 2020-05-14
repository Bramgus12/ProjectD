import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../MenuNavigation.dart';
import '../Plants.dart';

class AddPlant extends StatefulWidget {
  @override
  _AddPlant createState() => _AddPlant();
}

class _AddPlant extends State<AddPlant> {
  final _formKey = GlobalKey<FormState>();
  final UserPlant newPlant = new UserPlant();
  int minTemp;
  int maxTemp;

  void submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      User.plants.add(newPlant);
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
              child: ListView(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Text('Afbeelding'),
                        IconButton(
                          icon: Icon(Icons.image),
                          onPressed: () => {},
                          color: Colors.blue,
                        ),
                        SizedBox(height: 5),
                        AddPlantTextField(
                          label: 'Naam',
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Mag niet leeg zijn.';
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
                                return 'Moet een getal zijn.';
                              }

                              return null;
                            },
                            onSaved: (String value) {
                              newPlant.volumeInMM = int.parse(value);
                            },
                        ),
                        Row(
                          children: <Widget>[
                            Text('Datum laatste keer water'),
                            IconButton(
                              icon: Icon(Icons.date_range, color: Colors.blue,),
                              onPressed: () => DatePicker.showDateTimePicker(
                                context,
                                minTime: DateTime(DateTime.now().year, 1, 1),
                                maxTime: DateTime.now(),
                                onConfirm: (DateTime date) {
                                  newPlant.lastTimeWater = date;
                                }
                              ),
                            ),
                          ],
                        ),
                        AddPlantTextField(
                            label: 'Hoeveelheid zonlicht',
                            keyboardType: TextInputType.number,
                            validator: (String value) {
                              int temp = int.tryParse(value);

                              if (temp == null) {
                                return 'Moet een getal zijn.';
                              }

                              return null;
                            },
                            onSaved: (String value) {
                              newPlant.sunLightAmount = int.parse(value);
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
                            flex: 4,
                            child: AddPlantTextField(
                                label: 'Max temperatuur',
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
                  ),
                ],
              )
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
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)
              )
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
