
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  late String _name, _username, _email, _country, _password;

  bool _showNameAndUsername = true;
  bool _showEmailAndCountry = false;
  bool _showPassword = false;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _showNextSection() {
    debugPrint("Next1234");

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
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey1,
              child: AnimatedOpacity(
                opacity: _showNameAndUsername ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Name",),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value!,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Username",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your username";
                        }
                        return null;
                      },
                      onSaved: (value) => _username = value!,
                    ),
                    const SizedBox(height: 20.0),
                    NextButton(_showNextSection, _formKey1),
                  ],
                ),
              ),
            ),
            Center(
              child: Form(
                key: _formKey2,
                child: AnimatedOpacity(
                  opacity: _showEmailAndCountry ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return "Please enter your email";
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Country",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your country";
                          }
                          return null;
                        },
                        onSaved: (value) => _country = value!,
                      ),
                      const SizedBox(height: 20.0),
          NextButton(_showNextSection, _formKey2),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Form(
                key: _formKey3,
                child: AnimatedOpacity(
                  opacity: _showPassword ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Password",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                        obscureText: true,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value != _password) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey3.currentState!.validate()) {
                            _formKey3.currentState!.save();
                            // Sign up the user using Firebase here
                            _submit();
                          }
                        },
                        child: const Text("Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
      // Sign up with Firebase using _email, _password
  }
}

class NextButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function function;

  const NextButton(this.function, this.formKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        function();
        debugPrint("Validated");
      } else {
        debugPrint("Non validate");
      }
    },
      child: const Text("Next"),
    );
  }
}