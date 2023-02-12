import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class LoginProvider {
  final fb = FirebaseAuth.instance;

  Future<bool> submit(String email, String password) async {
      try {
        await fb
            .signInWithEmailAndPassword(
            email: email,
            password: password);
      } on FirebaseAuthException {
        return true; //isIncorrect
      }

      return false; //isGood
    }
  void pushToMain(BuildContext context) {
    context.push('/main');
  }
  }


