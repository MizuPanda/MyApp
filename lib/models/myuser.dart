import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/models/user_data.dart';

class MyUser {
  static final FirebaseAuth _fb = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Player? _instance;

  static Future<Player> getInstance() async {
    if (_instance == null) {
      DocumentSnapshot docs = await UserData.getData();
      String data = docs.data().toString();
      _instance = Player(
        username: data.contains('username') ? docs.get('username') : '',
        friendsID:
            data.contains('friends') ? docs.get('friends') : List.empty(),
        counter: data.contains('counter') ? docs.get('counter') : -1,
        palaceName: data.contains('palaceName') ? docs.get('palaceName') : '',
      );
    }

    return _instance!;
  }

  static void refreshPlayer() {
    _instance == null;
  }

  static String id() {
    return _fb.currentUser!.uid;
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

  static Future<String?> createUserWithEmailAndPassword(String email,
      String password, String name, String username, String country) async {
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
    await _db
        .collection('data')
        .doc('numbers')
        .update({'counter': FieldValue.increment(1)});

    DocumentSnapshot docs = await _db.collection('data').doc('numbers').get();

    int counter =
        docs.data().toString().contains('counter') ? docs.get('counter') : 0;

    final userInfo = <String, dynamic>{
      "name": name,
      "username": username,
      'counter': counter,
      "country": countryCode,
      'palaceName': '',
      "power": 0,
      "requestId": '',
      "friends": [],
      'linked': []
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
  int counter;
  String palaceName;

  Player(
      {required this.username,
      required this.friendsID,
      required this.counter,
      required this.palaceName});
}
