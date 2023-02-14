import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LoginProvider extends ChangeNotifier {
  final _fb = FirebaseAuth.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  bool _incorrectInfo = false;
  bool _incorrectInput = false;

  void login(Function push) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _incorrectInfo = await submit(_email!, _password!);
      if (_incorrectInfo) {
        formKey.currentState!.validate();
      } else {
        push();
      }
    }
    notifyListeners();
  }

  void passwordSaved(String? value) {
    _password = value;
    notifyListeners();
  }

  void _onChanged(String? value) {
    if (_incorrectInfo || _incorrectInput) {
      _incorrectInfo = false;
      _incorrectInput = false;
      formKey.currentState!.validate();
      notifyListeners();
    }
  }

  void passwordChanged(String? value) {
    _onChanged(value);
  }

  void emailChanged(String value) {
    _onChanged(value);
  }

  String? passwordValidator(String? value) {
    _incorrectInput = true;
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (_incorrectInfo) {
      return "Incorrect email or password.";
    }

    _incorrectInput = false;
    return null;
  }

  String? emailValidator(String? value) {
    _incorrectInput = true;
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    } else if (_incorrectInfo) {
      return "";
    }

    _incorrectInput = false;
    return null;
  }

  void emailSaved(String? value) {
    _email = value;
    notifyListeners();
  }

  Future<bool> submit(String email, String password) async {
    try {
      await _fb.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      return true; //isIncorrect
    }

    return false; //isGood
  }
}
