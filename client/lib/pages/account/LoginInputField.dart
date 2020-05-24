import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  final String label;
  final void Function(DateTime) dateTimeCallback;
  final bool validationError;
  final String validationMessage;

  LoginDatePicker(this.dateTimeCallback, {this.label, this.validationError=false, this.validationMessage=""});

  @override
  _LoginDatePickerState createState() => _LoginDatePickerState();
}

class _LoginDatePickerState extends State<LoginDatePicker> {
  DateTime pickedDate;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              OutlineButton(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    pickedDate == null ? widget.label : DateFormat('dd-MM-yyyy').format(pickedDate),
                    style: TextStyle(
                      color: theme.textTheme.headline.color,
                      fontWeight: theme.textTheme.body2.fontWeight,
                      fontSize: 16.0,
                      fontFamily: theme.textTheme.body2.fontFamily
                    ),
                  ),
                ),
                borderSide: BorderSide(
                  color: widget.validationError ? theme.errorColor : Colors.grey
                ),
                onPressed: (){ pickDate(context); },
              ),
              Visibility(
                visible: widget.validationError,
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                  child: Text(
                    widget.validationMessage,
                    style: theme.textTheme.caption.apply(
                      color: theme.errorColor
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime date = await showDatePicker(
      context: context, 
      initialDate: pickedDate == null ? DateTime.now() : pickedDate, 
      firstDate: DateTime(1900, 1, 1), 
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      //fieldLabelText: this.widget.label,
    );
    if(date == null) return;

    setState(() {
      pickedDate = date;
    });

    widget.dateTimeCallback(date);

  }
}


