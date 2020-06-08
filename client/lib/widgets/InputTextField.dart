import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputTextField extends StatelessWidget {
  final String title;
  final String label;
  final String initialValue;
  final Type inputType;
  final TextInputType keyboardType;
  final Function(String) validator;
  final Function(String) onSaved;
  final Function(String) onChanged;
  final Key key;
  final bool showSpacing;
  final String labelText;

  InputTextField(
      {this.key,
      this.title,
      this.label,
      this.initialValue = '',
      this.keyboardType,
      this.inputType,
      this.validator,
      this.onSaved,
      this.onChanged,
      this.showSpacing = true,
      this.labelText = ''});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          () {
            if (title.length > 0)
              return Text(title, style: TextStyle(color: theme.accentColor, fontSize: 18));

            return SizedBox.shrink();
          }(),
          () {
            if (label.length > 0)
              return Text(label);

            return SizedBox.shrink();
          }(),
          () {
            if (showSpacing) {
             return SizedBox(height: 10);
            }
            return SizedBox.shrink();
          }(),
          TextFormField(
              key: key,
              initialValue: this.initialValue,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.accentColor)),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                filled: true,
                fillColor: Colors.white,
                labelText: this.labelText
              ),
              keyboardType: this.keyboardType ?? TextInputType.text,
              inputFormatters: inputType == int
                  ? <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(2),
                      WhitelistingTextInputFormatter.digitsOnly
                    ]
                  : inputType == String
                      ? <TextInputFormatter>[
                          WhitelistingTextInputFormatter(
                              RegExp('^[a-zA-Z0-9 -\'\"]+'))
                        ]
                      : inputType == double
                          ? // a regex that will check if there is a double precent, max numers is 2(,|.)2 = 5 characters
                          <TextInputFormatter>[
                              WhitelistingTextInputFormatter(RegExp(
                                  r'^([0-9]{1,2})(((,|\.))(([0-9]{0,2})?))?'))
                            ]
                          : null,
              validator: this.validator,
              onSaved: this.onSaved,
              onChanged: this.onChanged),
            () {
              if (showSpacing) {
                return SizedBox(
                  height: 20,
                );
              }
              return SizedBox.shrink();
            }()
        ],
      ),
    );
  }
}
