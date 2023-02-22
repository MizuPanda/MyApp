import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class MyUser {
  static final FirebaseAuth _fb = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Player? _instance;

    static Future<DocumentSnapshot?> getUserByCounter(int counterValue) async {
      final collectionRef = _db.collection('users');
      final querySnapshot = await collectionRef.where('counter', isEqualTo: counterValue).get();
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        return userDoc;
      } else {
        return null;
      }


  }
  static Future<DocumentSnapshot> getUserData(String id) async {
    DocumentSnapshot docs = await _db.collection('users').doc(id).get();

    return docs;
  }

  static Future<Player> getInstance() async {
    if(_instance == null) {
      DocumentSnapshot userData = await getUserData(getUser()!.uid);
      String username = userData.get('username');
      List<dynamic> friendsID = userData.get('friends');
      int id = userData.get('counter');
      _instance = Player(username: username, friendsID:  friendsID, id: id);
    }
    return _instance!;
  }

  static User? getUser() {
    return _fb.currentUser;
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
    DocumentReference numberReference = _db
        .collection('data')
        .doc('numbers');

    DocumentSnapshot numberDocs = await numberReference.get();
    int counter = numberDocs.get('counter');
    final newCounter = <String, dynamic> {
      'counter': counter+1
    };
    numberReference.set(newCounter);

    final userInfo = <String, dynamic>{
      "name": name,
      "username": username,
      'counter': counter,
      "country": countryCode,
      "socialLevel": 0,
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

class Player {
  String username;
  List<dynamic> friendsID;
  int id;

  Player({required this.username, required this.friendsID, required this.id});
}
