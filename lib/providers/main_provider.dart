import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/main_page.dart';
import 'package:myapp/pages/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider {
  static const String firstKey = "firstTime";
  FirebaseAuth fb = FirebaseAuth.instance;


  Future<User?> getUser() async {
    return fb.currentUser;
  }

  Future<bool?> getFirst() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isFirst = prefs.getBool(firstKey);

    return isFirst;
  }
}
