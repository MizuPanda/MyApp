import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDecorations {

  static InputDecoration registerDeco(String? label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
