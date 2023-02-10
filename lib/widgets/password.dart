import 'package:flutter/material.dart';

class PasswordWidget extends StatefulWidget {
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final String? label;

  const PasswordWidget({super.key, this.onSaved, this.validator, required this.label});

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        suffixIcon: IconButton(
      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    ),

        labelText: widget.label,
      ),
      validator: widget.validator,
      onSaved: widget.onSaved,
      obscureText: _obscureText,
    );
  }
}