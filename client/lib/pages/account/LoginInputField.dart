import 'package:flutter/material.dart';
import 'package:plantexpert/Theme.dart';

class LoginInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obfuscated;
  final bool enabled;

  LoginInputField(this.controller, {this.hintText="", this.obfuscated=false, this.enabled=true});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          filled: !enabled,
          fillColor: ThemeColors.disabledInputField,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ThemeColors.selected
            )
          ),
          hintText: hintText
        ),
        obscureText: this.obfuscated,
      ),
    );
  }

}