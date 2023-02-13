import 'package:firebase_auth/firebase_auth.dart';

class MyUser {
  FirebaseAuth fb = FirebaseAuth.instance;

  User? getUser() {
    return fb.currentUser;
  }
}