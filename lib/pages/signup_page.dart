import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    _provider.initController(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _provider,
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Already have an account",
                style: TextStyle(color: Colors.white),
              ),
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
                        height: _provider.showNameAndUsername ? null : 0,
                        child: Form(
                          key: _provider.formKey1,
                          child: AnimatedOpacity(
                            opacity: _provider.showNameAndUsername ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration:
                                      MyDecorations.registerDeco('Name'),
                                  validator: _provider.nameValidator,
                                  onSaved: _provider.nameSaved,
                                ),
                                const Padding(padding: EdgeInsets.all(5)),
                                TextFormField(
                                  decoration:
                                      MyDecorations.registerDeco('Username'),
                                  onChanged: _provider.usernameChanged,
                                  validator: _provider.usernameValidator,
                                  onSaved: _provider.usernameSaved,
                                ),
                                const SizedBox(height: 20.0),
                                NextButton(
                                    _provider.nextUsername, _provider.formKey1)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: _provider.showEmailAndCountry ? null : 0,
                        child: Form(
                          key: _provider.formKey2,
                          child: AnimatedOpacity(
                            opacity: _provider.showEmailAndCountry ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration:
                                      MyDecorations.registerDeco('Email'),
                                  onChanged: _provider.emailChanged,
                                  validator: _provider.emailValidator,
                                  onSaved: _provider.emailSaved,
                                ),
                                const SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    BackButton(
                                        function: _provider.showLastSection),
                                    Expanded(
                                      child: NextButton(
                                          _provider.showNextSection,
                                          _provider.formKey2),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: _provider.showPassword ? null : 0,
                        child: Form(
                          key: _provider.formKey3,
                          child: AnimatedOpacity(
                            opacity: _provider.showPassword ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              children: [
                                PasswordWidget(
                                  onSaved: _provider.passwordSaved,
                                  onChanged: _provider.passwordChanged,
                                  validator: _provider.passwordValidator,
                                  label: 'Password',
                                ),
                                const Padding(padding: EdgeInsets.all(5)),
                                PasswordWidget(
                                  label: "Confirm password",
                                  validator: _provider.passwordConfirmValidator,
                                ),
                                const SizedBox(height: 20.0),
                                Row(
                                  children: [
                                    BackButton(
                                        function: _provider.showLastSection),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _provider.signUp();
                                            context.pushReplacement('main');
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
        });
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
