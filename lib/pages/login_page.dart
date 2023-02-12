import 'package:flutter/material.dart';
import 'package:myapp/widgets/password.dart';

import '../providers/login_provider.dart';
import '../styles/input_deco.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? email;
  String? password;

  bool incorrectInfo = false;
  final provider = LoginProvider();

  @override
  Widget build(BuildContext context) {
    push() {
      provider.pushToMain(context);
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: MyDecorations.registerDeco('Email'),
                onSaved: (value) => email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  } else if (incorrectInfo) {
                    return "";
                  }
                  return null;
                },
                onChanged: (value) {
                  if(incorrectInfo) {
                    incorrectInfo = false;
                    _formKey.currentState!.validate();
                  }
                },
              ),
              const SizedBox(height: 16),
              PasswordWidget(
                  label: 'Password',
                onSaved: (value) => password = value,
                onChanged: (value) {
                  if(incorrectInfo) {
                    incorrectInfo = false;
                    _formKey.currentState!.validate();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  } else if (incorrectInfo) {
                    return "Incorrect email or password.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if(_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    incorrectInfo = await provider.submit(email!, password!);
                    if(incorrectInfo) {
                      _formKey.currentState!.validate();
                    } else {
                      push();
                    }
                  }
                },
                style: ButtonStyle(shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ))),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

