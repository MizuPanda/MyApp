import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class MyUser {
  static final FirebaseAuth _fb = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? getUser() {
    return _fb.currentUser;
  }

  static void setDeviceId() {

  }


  static Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  static Future<String?> createUserWithEmailAndPassword(String email, String password,
      String name, String username, String country) async {
    try {
      UserCredential result = await _fb.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      debugPrint("Successfully created user: ${user!.uid}");
      _registerUserData(name, username, country);
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      return e.code;
    }

    return null;
  }

  static Future<void> _registerUserData(
      String name, String username, String countryCode) async {
    final userInfo = <String, dynamic>{
      "name": name,
      "username": username,
      "country": countryCode,

      "requests": [],
      "friends": []
    };

    _db
        .collection("users")
        .doc(_fb.currentUser!.uid)
        .set(userInfo)
        .whenComplete(
            () => debugPrint("Successfully added the data to user: $username"))
        .onError((e, _) => debugPrint("Error writing document: $e"));
  }
}
