import 'package:flutter/material.dart';

class LoginInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obfuscated;
  final bool enabled;

  LoginInputField(this.controller, {this.hintText="", this.obfuscated=false, this.enabled=true});
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        enabled: enabled,
        controller: controller,
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
        obscureText: this.obfuscated,
      ),
    );
  }

}