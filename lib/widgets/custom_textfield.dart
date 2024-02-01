import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final TextInputType keyType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    this.validator,
    required this.labelText,
    required this.controller,
    this.keyType = TextInputType.name,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        validator: validator,
        keyboardType: keyType,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: color.primary,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          errorBorder: border(Colors.red),
          enabledBorder: border(Colors.grey),
          focusedErrorBorder: border(Colors.red),
          focusedBorder: border(color.primary),
          suffixIcon: Icon(Icons.edit, color: color.primary),
          contentPadding: const EdgeInsets.only(right: 10, bottom: 10, top: 10),
        ),
        style: TextStyle(color: color.onBackground, fontSize: 16.0),
      ),
    );
  }

  UnderlineInputBorder border(Color color) {
    return UnderlineInputBorder(borderSide: BorderSide(color: color));
  }
}
