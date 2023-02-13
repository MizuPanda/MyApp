import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'friendships.dart';

class Friend {
  final String id;
  late String name;
  late String username;
  late ImageProvider photo;
  late Friendship friendship;

  final FirebaseAuth fb = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Friend({required this.id}) {
    photo = const NetworkImage('https://picsum.photos/200');
    var ids = [fb.currentUser!.uid, id];
    ids.sort();
    friendship = Friendship(ids: ids);
  }

  Future<String> getName() async {
    DocumentSnapshot docs = await getUserData(id);

    name = docs.get('name');
    username = docs.get('username');

    return name;
  }

  void setUserInfo(String id) async {
    DocumentSnapshot docs = await getUserData(id);

    name = docs.get('name');
    username = docs.get('username');

  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    DocumentSnapshot docs =
    await db.collection('users')
    .doc(uid)
    .get();

    return docs;
  }
}
