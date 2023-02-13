import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


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

  Future<String?> createUserWithEmailAndPassword(
      String email, String password, String name, String username, String country) async {
    try {
      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,

      );
      User? user = result.user;
      debugPrint("Successfully created user: ${user!.uid}");
      _registerUserData(name, username, country);
    } on FirebaseAuthException catch(e) {
      debugPrint(e.code);
      return e.code;
    }

    return null;

  }

  Future<void> _registerUserData(
      String name, String username, String country) async {
    final userInfo = <String, dynamic>{
      "name": name,
      "username": username,
      "country": country,
      "requests": [],
      "friends": []
    };

    db
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .set(userInfo)
    .whenComplete(() => debugPrint("Successfully added the data to user: $username"))
    .onError((e, _) => debugPrint("Error writing document: $e"));
        
  }
}
