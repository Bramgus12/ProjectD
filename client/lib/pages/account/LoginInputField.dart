import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obfuscated;
  final bool enabled;
  final String Function(String) validator;
  final TextInputType keyboardType;
  final Type inputType;

  LoginInputField(this.controller, {this.hintText="", this.obfuscated=false, this.enabled=true, this.validator, this.keyboardType=TextInputType.text, this.inputType=String });
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        
        keyboardType: keyboardType,
        enabled: enabled,
        controller: controller,
        validator: (value) => this.validator == null ? null : this.validator(value),
        decoration: InputDecoration(
          filled: !enabled,
          fillColor: theme.disabledColor,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.accentColor
            )
          ),
          hintText: hintText
        ),
        inputFormatters: inputType == int ? <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly] : null,
        obscureText: obfuscated,
      ),
    );
  }

}

class LoginDatePicker extends StatefulWidget {
  @override
  _LoginDatePickerState createState() => _LoginDatePickerState();
}

class _LoginDatePickerState extends State<LoginDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: OutlineButton(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Geboorte Datum",
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
            ),
            borderSide: BorderSide(
              color: Colors.grey
            ),
            onPressed: () {  },
          ),
        ),
      ],
    );
  }

  // TODO: implement date picker button functionality
}


