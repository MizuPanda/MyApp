import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/myuser.dart';

class SignProvider extends ChangeNotifier {
  final MyUser _myUser = MyUser();

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  Country? _country;
  late String _name, _username, _email, _password = "";

  bool showNameAndUsername = true;
  bool showEmailAndCountry = false;
  bool showPassword = false;

  late AnimationController _controller;

  bool _usernameTaken = false;

  String? _error;
  bool _hasError = false;

  void signUp(Function goToMain) async {
    formKey3.currentState!.save();
    if (formKey3.currentState!.validate()) {
      _error = await _myUser.createUserWithEmailAndPassword(
          _email, _password, _name, _username, _country!.countryCode);
      notifyListeners();
      if (_error == null) {
        goToMain();
      } else {
        if (!formKey1.currentState!.validate()) {
        } else if (!formKey2.currentState!.validate()) {
        } else {
          formKey3.currentState!.validate();
        }
        notifyListeners();
      }
    }
  }

  void nextUsername() async {
    _usernameTaken = await _myUser.isUsernameTaken(_username);
    notifyListeners();

    if (formKey1.currentState!.validate()) {
      showNextSection();
    }
  }

  String getCountryText() {
    return _country != null
        ? "${_country!.name}  ${_country!.flagEmoji}"
        : "Country";
  }

  void selectCountry(Country? country) {
    _country = country;
    notifyListeners();
  }

  void passwordChanged(String? value) {
    if (_hasError) {
      _hasError = false;
      _error = null;
      formKey3.currentState!.validate();
      notifyListeners();
    }
  }

  void emailChanged(String? value) {
    if (_hasError) {
      _error = null;
      _hasError = false;
      formKey2.currentState!.validate();
      notifyListeners();
    }
  }

  void usernameChanged(String? value) {
    if (_usernameTaken) {
      _usernameTaken = false;
      formKey1.currentState!.validate();
      notifyListeners();
    }
  }

  void passwordSaved(String? value) {
    _password = value!;
    notifyListeners();
  }

  void emailSaved(String? value) {
    _email = value!;
    notifyListeners();
  }

  void usernameSaved(String? value) {
    _username = value!;
    notifyListeners();
  }

  void nameSaved(String? value) {
    _name = value!;
    notifyListeners();
  }

  String? passwordConfirmValidator(String? value) {
    if (value == null || value.isEmpty || value != _password) {
      return "Passwords do not match";
    }

    return null;
  }

  String? passwordValidator(String? value) {
    _hasError = true;
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    } else if (_error == 'weak-password') {
      return "Please enter a stronger password.";
    }
    _hasError = false;
    notifyListeners();
    return null;
  }

  String? emailValidator(String? value) {
    _hasError = true;

    if (value == null || value.isEmpty || !value.contains('@')) {
      _showEmail();
      return "Please enter your email";
    } else if (_country == null) {
      _showEmail();
      return "Please select a country";
    } else if (_error == 'email-already-in-use') {
      _showEmail();
      return "This email is already in use.";
    }

    _hasError = false;
    notifyListeners();
    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      _showName();
      return "Please enter your username";
    }
    if (_usernameTaken) {
      return "This username is already taken";
    }
    return null;
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      _showName();
      return "Please enter your name";
    }
    return null;
  }

  void initController(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    notifyListeners();
  }

  void _showName() {
    showNameAndUsername = true;
    showEmailAndCountry = false;
    showPassword = false;
    notifyListeners();
  }

  void _showEmail() {
    showNameAndUsername = false;
    showEmailAndCountry = true;
    showPassword = false;
    notifyListeners();
  }

  void showLastSection() {
    if (showPassword) {
      showPassword = false;
      showEmailAndCountry = true;
    } else if (showEmailAndCountry) {
      showEmailAndCountry = false;
      showNameAndUsername = true;
    }
    _controller.reverse();
    notifyListeners();
  }

  void showNextSection() {
    if (showNameAndUsername) {
      showNameAndUsername = false;
      showEmailAndCountry = true;
    } else if (showEmailAndCountry) {
      showEmailAndCountry = false;
      showPassword = true;
    }
    _controller.forward();
    notifyListeners();
  }
}
