import 'package:flutter/material.dart';

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
      bottomNavigationBar: BottomNavigation(),
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
                      hintText: 'Naam',
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
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Inhoud bak',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        keyboardType: TextInputType.number),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Datum laatste keer water',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        keyboardType: TextInputType.datetime),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Hoeveel zonlicht nodig (1-5)',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        keyboardType: TextInputType.number),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Min temperatuur',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        keyboardType: TextInputType.number),
                    TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Max temperatuur',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        keyboardType: TextInputType.number),
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
  final String hintText;
  final TextInputType keyboardType;
  final Function(String) validator;
  final Function(String) onSaved;

  AddPlantTextField({this.hintText, this.keyboardType, this.validator, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: this.hintText,
        hintStyle: TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)
        ),
      ),
      keyboardType: keyboardType,
      validator: this.validator,
      onSaved: this.onSaved,
    );
  }
}
