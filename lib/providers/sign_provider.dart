import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_provider.dart';

class SignProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result = await db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return  documents.isNotEmpty;
  }

  void setFirst() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(MainProvider.firstKey, false);
  }

  void backToLogin(BuildContext buildContext) {
    buildContext.push('/login');
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.black;
    }
    return Colors.white;
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String name, String username, String country) async {
    try {
      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,

      );
      User? user = result.user;
      debugPrint("Successfully created user: ${user!.uid}");
      registerUserData(name, username, country);
      setFirst();
    } catch (e) {
      debugPrint("Error creating user: $e");
    }

  }

  Future<void> registerUserData(
      String name, String username, String country) async {
    final userInfo = <String, String>{
      "name": name,
      "username": username,
      "country": country
    };

    db
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .set(userInfo)
    .whenComplete(() => debugPrint("Successfully added the data to user: $username"))
    .onError((e, _) => debugPrint("Error writing document: $e"));
        
  }
}
