import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;


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
