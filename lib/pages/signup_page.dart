import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:myapp/providers/sign_provider.dart';

import '../styles/input_deco.dart';
import '../widgets/password.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _provider = SignProvider();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  Country? _country;
  late String _name, _username, _email, _password = "";

  bool _showNameAndUsername = true;
  bool _showEmailAndCountry = false;
  bool _showPassword = false;

  late AnimationController _controller;

  bool _usernameTaken = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _showLastSection() {
    setState(() {
      if (_showPassword) {
        _showPassword = false;
        _showEmailAndCountry = true;
      } else if (_showEmailAndCountry) {
        _showEmailAndCountry = false;
        _showNameAndUsername = true;
      }
    });
  }

  void _showNextSection() {
    setState(() {
      if (_showNameAndUsername) {
        _showNameAndUsername = false;
        _showEmailAndCountry = true;
      } else if (_showEmailAndCountry) {
        _showEmailAndCountry = false;
        _showPassword = true;
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [
              IconButton(onPressed: () {_provider.backToLogin(context);},
              icon: const Icon(Icons.arrow_back, color: Colors.white,)),
              const Text("Already have an account", style: TextStyle(color: Colors.white),),
            ],
          )
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(left: 35, right: 35),
        child: Center(
          child: SizedBox(
            height: 300,
            child: Stack(
              children: [
                SizedBox(
                  height: _showNameAndUsername ? null : 0,
                  child: Form(
                    key: _formKey1,
                    child: AnimatedOpacity(
                      opacity: _showNameAndUsername ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: MyDecorations.registerDeco('Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your name";
                              }
                              return null;
                            },
                            onSaved: (value) => _name = value!,
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          TextFormField(
                            decoration: MyDecorations.registerDeco('Username'),
                            onChanged: (value) async {
                              if(_usernameTaken) {
                                _usernameTaken = false;
                                _formKey1.currentState!.validate();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your username";
                              }
                              if(_usernameTaken) {
                                return "This username is already taken";
                              }
                              return null;
                            },
                            onSaved: (value) => _username = value!,
                          ),
                          const SizedBox(height: 20.0),
                          NextButton(() async {
                            _usernameTaken = await _provider.isUsernameTaken(_username);
                            if(_formKey1.currentState!.validate()) {
                              _showNextSection();
                            }
                          }, _formKey1)
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: _showEmailAndCountry ? null : 0,
                  child: Form(
                    key: _formKey2,
                    child: AnimatedOpacity(
                      opacity: _showEmailAndCountry ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: MyDecorations.registerDeco('Email'),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return "Please enter your email";
                              } else if (_country == null) {
                                return "Please select a country";
                              }
                              return null;
                            },
                            onSaved: (value) => _email = value!,
                          ),
                          TextButton(
                            onPressed: () {
                              showCountryPicker(
                                context: context,
                                showSearch: false,
                                showPhoneCode:
                                    false, // optional. Shows phone code before the country name.
                                onSelect: (Country country) {
                                  setState(() {
                                    _country = country;
                                  });
                                  debugPrint(
                                      'Select country: ${country.displayName}');
                                },
                              );
                            },
                            child: Text(
                              _country != null
                                  ? "${_country!.name}  ${_country!.flagEmoji}"
                                  : "Country",
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            children: [
                              BackButton(function: _showLastSection),
                              Expanded(
                                child: NextButton(_showNextSection, _formKey2),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: _showPassword ? null : 0,
                  child: Form(
                    key: _formKey3,
                    child: AnimatedOpacity(
                      opacity: _showPassword ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          PasswordWidget(
                            onSaved: (value) {
                              _password = value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }
                              return null;
                            },
                            label: 'Password',
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          PasswordWidget(
                            label: "Confirm password",
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value != _password) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            children: [
                              BackButton(function: _showLastSection),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _formKey3.currentState!.save();
                                      if (_formKey3.currentState!.validate()) {
                                        _provider
                                            .createUserWithEmailAndPassword(
                                                _email, _password, _name, _username, _country!.countryCode);
                                      }
                                    },
                                    child: const Text("Sign Up"),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  final Function function;

  const BackButton({super.key, required this.function});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () {
          function();
        },
        child: const Text("Back"),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function function;

  const NextButton(this.function, this.formKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            function();
          }
        },
        child: const Text("Next"),
      ),
    );
  }
}
