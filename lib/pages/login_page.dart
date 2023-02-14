import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/password.dart';

import '../providers/login_provider.dart';
import '../styles/input_deco.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginProvider provider = LoginProvider();

  @override
  Widget build(BuildContext context) {
    pushMain() {
      context.pushReplacement('/main');
    }

    pushRegister() {
      context.go('/signup');
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
            animation: provider,
            builder: (BuildContext context, Widget? child) {
              return Form(
                key: provider.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: MyDecorations.registerDeco('Email'),
                      onSaved: provider.emailSaved,
                      validator: provider.emailValidator,
                      onChanged: provider.emailChanged,
                    ),
                    const SizedBox(height: 16),
                    PasswordWidget(
                      label: 'Password',
                      onSaved: provider.passwordSaved,
                      onChanged: provider.passwordChanged,
                      validator: provider.passwordValidator,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        LogButton(
                            onPressed: pushRegister,
                            label: 'Create an account'),
                        const Spacer(),
                        LogButton(
                          onPressed: () {
                            provider.login(pushMain);
                          },
                          label: 'Login',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class LogButton extends StatelessWidget {
  final Function()? onPressed;
  final String label;
  const LogButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ))),
      child: Text(label),
    );
  }
}
