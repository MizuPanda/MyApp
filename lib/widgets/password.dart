import 'package:flutter/material.dart';

class PasswordWidget extends StatefulWidget {
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? label;


  const PasswordWidget({super.key, this.onSaved, this.validator, required this.label, this.onChanged});

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
    );
  }
}